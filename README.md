# Decentralized Fund-Raising DApp

This is a decentralized crowdfunding platform that allows users to create campaigns, donate using ETH or supported ERC-20 tokens, withdraw funds upon success, and refund donations if the campaign fails.

-------------------------------

## Setup Instructions

1. Prerequisites
Ensure the following are installed:
- Node.js (v18 or later)
- Hardhat
- MetaMask extension in your browser

-------------------------------

2. Install Frontend Dependencies
```bash
npm install
```

-------------------------------

3. Smart Contract Deployment
1. Navigate to or create a `smart-contract` folder.
2. Initialize Hardhat:

```bash
npx hardhat
```
3. Add the smart contract `FundRaising.sol` inside `contracts/`.
4. Create a `scripts/deploy.js` for deployment.
5. Add environment variables in `.env` (RPC URL and Private Key).
6. Update `hardhat.config.js` to include the Sepolia testnet.
7. Deploy the contract using:

```bash
npx hardhat run scripts/deploy.js --network sepolia
```

---------------------------------

4. Configure Frontend
Update `src/utils/constants.js`:
- Replace contract address with the one received after deployment.
- Paste ABI from Hardhat artifacts.

----------------------------------

5. Run Frontend
```bash
npm run dev
```
App runs at: `http://localhost:5173`

----------------------------------

6. Usage Summary
- Connect MetaMask wallet.
- Create a campaign by selecting token type and entering values in Ether units (e.g., 1 = 1 TUSD).
- Use campaign ID to donate.
- View campaigns in real time.
- Withdraw if target met before deadline.
- Refund if campaign failed.

------------------------------------

## Features
- Create campaigns with ETH or supported ERC20 tokens
- Donate to campaigns
- Withdraw funds when target is met
- Refund donations on failed campaigns
- Real-time campaign display
- MetaMask wallet integration
- Clean modular frontend using React + Tailwind CSS
---
## License

MIT License
