// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  //Deploy USDStablecoin

  const USDStablecoin = await ethers.getContractFactory("USDStablecoin");
  usdStableCoin = await USDStablecoin.deploy();
  await usdStableCoin.deyloyed();

  //Deploy MyGovToken
  const MyGovToken = await ethers.getContractFactory("MyGovToken");
  myGovToken = await MyGovToken.deploy();
  await myGovToken.deployed();

  //Deploy Membership
  const Membership = await ethers.getContractFactory("Membership");
  membership = await Membership.deploy();
  await membership.deployed();

  //Deploy Survey
  const Survey = await ethers.getContractFactory("Survey");
  survey = await Survey.deploy();
  await survey.deployed();

  //Deploy Project
  const Project = await ethers.getContractFactory("Project");
  project = await Project.deploy();
  await project.deployed();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
