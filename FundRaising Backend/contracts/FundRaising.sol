// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract FundRaising {
    enum TokenType { ETH, USDT, BUSD, TUSD }

    struct Campaign {
        address creator;
        string title;
        string description;
        uint256 targetAmount;
        uint256 minimumDonation;
        uint256 deadline;
        address tokenAddress; // address(0) for ETH
        TokenType tokenType;
        uint256 totalDonated;
        bool withdrawn;
        bool failed;
        mapping(address => uint256) donations;
    }

    uint256 public campaignCount;
    mapping(uint256 => Campaign) public campaigns;

    event CampaignCreated(uint256 campaignId, address creator, TokenType tokenType);
    event DonationReceived(uint256 campaignId, address donor, uint256 amount);
    event Withdrawn(uint256 campaignId, uint256 amount);
    event Refunded(uint256 campaignId, address donor, uint256 amount);

    function createCampaign(
        string memory _title,
        string memory _description,
        uint256 _targetAmount,
        uint256 _minimumDonation,
        uint256 _durationInSeconds,
        address _tokenAddress,
        TokenType _tokenType
    ) public {
        require(_targetAmount > 0, "Target must be > 0");
        require(_tokenType == TokenType.ETH || _tokenAddress != address(0), "Token address required");

        Campaign storage newCampaign = campaigns[campaignCount];
        newCampaign.creator = msg.sender;
        newCampaign.title = _title;
        newCampaign.description = _description;
        newCampaign.targetAmount = _targetAmount;
        newCampaign.minimumDonation = _minimumDonation;
        newCampaign.deadline = block.timestamp + _durationInSeconds;
        newCampaign.tokenAddress = _tokenAddress;
        newCampaign.tokenType = _tokenType;

        emit CampaignCreated(campaignCount, msg.sender, _tokenType);
        campaignCount++;
    }

    function donate(uint256 _campaignId, uint256 _amount) public payable {
        Campaign storage campaign = campaigns[_campaignId];
        require(block.timestamp <= campaign.deadline, "Deadline passed");
        require(!campaign.withdrawn, "Already withdrawn");

        if (campaign.tokenType == TokenType.ETH) {
            require(msg.value >= campaign.minimumDonation, "Below minimum");
            require(msg.value == _amount, "Mismatch amount");

            campaign.totalDonated += msg.value;
            campaign.donations[msg.sender] += msg.value;
        } else {
            require(_amount >= campaign.minimumDonation, "Below minimum");
            IERC20 token = IERC20(campaign.tokenAddress);
            require(token.transferFrom(msg.sender, address(this), _amount), "Transfer failed");

            campaign.totalDonated += _amount;
            campaign.donations[msg.sender] += _amount;
        }

        emit DonationReceived(_campaignId, msg.sender, _amount);
    }

    function withdraw(uint256 _campaignId) public {
        Campaign storage campaign = campaigns[_campaignId];
        require(msg.sender == campaign.creator, "Only creator");
        require(block.timestamp <= campaign.deadline, "Deadline passed");
        require(campaign.totalDonated >= campaign.targetAmount, "Target not met");
        require(!campaign.withdrawn, "Already withdrawn");

        campaign.withdrawn = true;

        if (campaign.tokenType == TokenType.ETH) {
            payable(campaign.creator).transfer(campaign.totalDonated);
        } else {
            IERC20 token = IERC20(campaign.tokenAddress);
            require(token.transfer(campaign.creator, campaign.totalDonated), "Withdraw failed");
        }

        emit Withdrawn(_campaignId, campaign.totalDonated);
    }

    function markFailed(uint256 _campaignId) public {
        Campaign storage campaign = campaigns[_campaignId];
        require(block.timestamp > campaign.deadline, "Deadline not passed");
        require(campaign.totalDonated < campaign.targetAmount, "Target was met");

        campaign.failed = true;
    }

    function claimRefund(uint256 _campaignId) public {
        Campaign storage campaign = campaigns[_campaignId];
        require(campaign.failed, "Not marked failed");

        uint256 amount = campaign.donations[msg.sender];
        require(amount > 0, "No donation");

        campaign.donations[msg.sender] = 0;

        if (campaign.tokenType == TokenType.ETH) {
            payable(msg.sender).transfer(amount);
        } else {
            IERC20 token = IERC20(campaign.tokenAddress);
            require(token.transfer(msg.sender, amount), "Refund failed");
        }

        emit Refunded(_campaignId, msg.sender, amount);
    }

    function getDonation(uint256 _campaignId, address _donor) public view returns (uint256) {
        return campaigns[_campaignId].donations[_donor];
    }
    function getCampaign(uint256 _campaignId) public view returns (
        address creator,
        string memory title,
        string memory description,
        uint256 targetAmount,
        uint256 minimumDonation,
        uint256 deadline,
        address tokenAddress,
        TokenType tokenType,
        uint256 totalDonated,
        bool withdrawn,
        bool failed
    ) {
       Campaign storage c = campaigns[_campaignId];
      return (
          c.creator,
          c.title,
          c.description,
          c.targetAmount,
          c.minimumDonation,
          c.deadline,
          c.tokenAddress,
          c.tokenType,
          c.totalDonated,
          c.withdrawn,
          c.failed
      );
    }

}
