require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config()

/** @type import('hardhat/config').HardhatUserConfig */
const{AlCHEMY_API_KEY,SEPOLIA_PRIVATE_KEY}=process.env
module.exports = {
  solidity: "0.8.28",
  networks:{
    sepolia:{
      url:`https://eth-sepolia.g.alchemy.com/v2/${AlCHEMY_API_KEY}`,
      accounts:[`${SEPOLIA_PRIVATE_KEY}`]
    }
  }
};