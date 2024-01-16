const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Surveys Contract", function () {
  let Surveys;
  let surveys;
  let MyGovToken;
  let myGovToken;
  let USDStablecoin;
  let usdStableCoin;
  let Membership;
  let membership;
  let deployer;
  let user1;
  let user2;

  beforeEach(async function () {
    [deployer, user1, user2] = await ethers.getSigners();

    // Deploy MyGovToken
    MyGovToken = await ethers.getContractFactory("MyGovToken");
    myGovToken = await MyGovToken.connect(deployer).deploy();

    // Deploy USDStablecoin
    USDStablecoin = await ethers.getContractFactory("USDStablecoin");
    usdStableCoin = await USDStablecoin.connect(deployer).deploy();

    // Deploy Membership
    Membership = await ethers.getContractFactory("Membership");
    membership = await Membership.connect(deployer).deploy(
      myGovToken.address,
      usdStableCoin.address
    );

    // Deploy Surveys
    Surveys = await ethers.getContractFactory("Surveys");
    surveys = await Surveys.connect(deployer).deploy(
      membership.address,
      myGovToken.address,
      usdStableCoin.address
    );
  });

  it("should submit a new survey", async function () {
    const ipfsHash = "your_ipfs_hash_here";
    const surveyDeadline = Math.floor(Date.now() / 1000) + 86400; // 24 hours from now
    const numChoices = 3;
    const atMostChoice = 2;

    await myGovToken.connect(user1).mint(user1.address, 10);
    await usdStableCoin.connect(user1).mint(user1.address, 50);

    await myGovToken.connect(user1).approve(surveys.address, 2);
    await usdStableCoin.connect(user1).approve(surveys.address, 5);

    await surveys
      .connect(user1)
      .submitSurvey(ipfsHash, surveyDeadline, numChoices, atMostChoice);

    const surveyInfo = await surveys.connect(user1).getSurveyInfo(0);
    expect(surveyInfo.ipfsHash).to.equal(ipfsHash);
    expect(surveyInfo.surveyDeadline).to.equal(surveyDeadline);
    expect(surveyInfo.numChoices).to.equal(numChoices);
    expect(surveyInfo.atMostChoice).to.equal(atMostChoice);
  });

  it("should take a survey", async function () {
    const surveyId = 0;
    const choices = [0, 2]; // Example choices, adjust based on your use case

    await surveys.connect(user2).takeSurvey(surveyId, choices);

    const surveyResults = await surveys
      .connect(user1)
      .getSurveyResults(surveyId);
    expect(surveyResults.numTaken).to.equal(1);
    expect(surveyResults.results).to.eql([1, 0, 1]); // Expected results based on choices
  });

  it("should get survey information", async function () {
    const surveyId = 0;

    const surveyOwner = await surveys.connect(user1).getSurveyOwner(surveyId);
    expect(surveyOwner).to.equal(user1.address);

    const surveyInfo = await surveys.connect(user1).getSurveyInfo(surveyId);
    expect(surveyInfo.ipfsHash).to.be.a("string");
    expect(surveyInfo.surveyDeadline).to.be.a("number");
    expect(surveyInfo.numChoices).to.be.a("number");
    expect(surveyInfo.atMostChoice).to.be.a("number");
  });

  it("should get the number of surveys", async function () {
    const numSurveys = await surveys.getNoOfSurveys();
    expect(numSurveys).to.equal(1);
  });
});
