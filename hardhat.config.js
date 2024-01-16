require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.20",

  networks: {
    fuji: {
      url: process.env.QUICKNODE_URL,
      accounts: [`0x` + process.env.PRIVATE_KEY],
      chainId: 43113,
    },
  },
};
