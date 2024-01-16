const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Project Contract", function () {
  let Project;
  let project;
  let MyGovToken;
  let myGovToken;
  let USDStablecoin;
  let usdStableCoin;
  let Membership;
  let membership;
  let deployer;
  let user1;
  let user2;

  before(async function () {
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

    // Deploy Project
    Project = await ethers.getContractFactory("Project");
    project = await Project.connect(deployer).deploy(
      membership.address,
      myGovToken.address,
      usdStableCoin.address
    );
  });

  it("should submit a new project proposal", async function () {
    const ipfsHash = "your_ipfs_hash_here";
    const voteDeadline = Math.floor(Date.now() / 1000) + 86400; // 24 hours from now
    const paymentAmounts = [10, 20, 30];
    const paySchedule = [
      voteDeadline + 86400,
      voteDeadline + 172800,
      voteDeadline + 259200,
    ];

    await myGovToken.connect(user1).mint(user1.address, 100);
    await usdStableCoin.connect(user1).mint(user1.address, 100);

    await myGovToken.connect(user1).approve(project.address, 5);
    await usdStableCoin.connect(user1).approve(project.address, 50);

    await project
      .connect(user1)
      .submitProjectProposal(
        ipfsHash,
        voteDeadline,
        paymentAmounts,
        paySchedule
      );

    const projectInfo = await project.connect(user1).getProjectInfo(0);
    expect(projectInfo.ipfsHash).to.equal(ipfsHash);
    expect(projectInfo.voteDeadline).to.equal(voteDeadline);
    expect(projectInfo.paymentAmounts).to.eql(paymentAmounts);
    expect(projectInfo.paySchedule).to.eql(paySchedule);
  });

  it("should vote for a project proposal", async function () {
    const projectId = 0;

    await project.connect(user2).delegateVoteTo(user1.address, projectId);

    await project.connect(user1).voteForProjectProposal(projectId, true);

    const projectVotes = await project
      .connect(user1)
      .projectVotes(projectId, user1.address);
    expect(projectVotes).to.equal(true);
  });

  it("should reserve funding for a project proposal", async function () {
    const projectId = 0;

    await project.connect(user1).reserveProjectGrant(projectId);

    const projectFunded = await project.connect(user1).projectFunded(projectId);
    expect(projectFunded).to.equal(true);
  });

  it("should vote for project payments", async function () {
    const projectId = 0;
    const choicePay = [true, false, true]; // Example choices, adjust based on your use case

    await project.connect(user1).voteForProjectPayments(projectId, choicePay);

    const projectVotes = await project
      .connect(user1)
      .projectVotes(projectId, user1.address);
    expect(projectVotes).to.equal(true);
  });

  it("should withdraw project payments if reserved", async function () {
    const projectId = 0;

    await project.connect(user1).withdrawProjectPayments(projectId);

    // Check the withdrawal event or updated balance to verify the withdrawal
    // Example: const balance = await usdStableCoin.balanceOf(user1.address);
    // expect(balance).to.equal(expectedBalance);
  });
});
