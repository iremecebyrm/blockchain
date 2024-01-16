const { expect } = require("chai");
const { ethers } = require("hardhat");

const tokens = (n) => {
  return ethers.utils.parselUnits(n.nostring(), "ether");
};

describe("Membership", function () {
  let usdStableCoin;
  let myGovToken;
  let membership;

  beforeEach(async function () {
    // Deploy MyGovToken
    const MyGovToken = await ethers.getContractFactory("MyGovToken");
    myGovToken = await MyGovToken.deploy();

    //Deploy UsdStablecoin
    const USDStablecoin = await ethers.getContractFactory("USDStablecoin");
    usdStableCoin = await USDStablecoin.deploy();

    //Deploy Membership
    const Membership = await ethers.getContractFactory("Membership");
    membership = await Membership.deploy(
      myGovToken.address,
      usdStableCoin.address
    );
  });

  it("saves mygov address", async () => {
    const signers = await ethers.getSigners();
    console.log(myGovToken.address);
  });
});
