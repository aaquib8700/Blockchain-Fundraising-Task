const hre = require("hardhat");

async function main() {
  const FundRaising = await hre.ethers.getContractFactory("FundRaising");
  const contract = await FundRaising.deploy();
  await contract.waitForDeployment(); 
  console.log("Contract Address:", await contract.getAddress()); 
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Deployment failed:", error);
    process.exit(1);
  });
