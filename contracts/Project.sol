// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./Membership.sol";
import "./USDStablecoin.sol";
import "./MyGovToken.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "hardhat/console.sol";

contract Project is Membership {
    address myGovTokenAddress;
    address usdStableCoinAddress;

    constructor(
        address _myGovTokenAddress,
        address _usdStableCoinAddress
    ) Membership(_myGovTokenAddress, _usdStableCoinAddress) {
        myGovTokenAddress = _myGovTokenAddress;
        usdStableCoinAddress = _usdStableCoinAddress;
    }

    //--------------------------------------------------PROJECT PART---------------------------------------------------

    // Structure to represent a Project Proposal
    struct ProjectProposal {
        string ipfsHash;
        uint voteDeadline;
        uint[] paymentAmounts;
        uint[] paySchedule;
        bool[] voteForPayments;
        uint[] voteForPay;
        uint[] voteAgainstPay;
        uint votesFor;
        uint votesAgainst;
        bool isFunded;
        bool reserved;
        uint reservedAmount;
        address projectOwner;
        uint usdReceived;
    }

    // Array to store all project proposals
    ProjectProposal[] public projectProposals;

    // Mapping to store whether a member has voted for a project proposal  address -> pId -> voted or not
    mapping(address => mapping(uint => bool)) public memberHasVoted;

    // Mapping to store the number of people who voted for each project proposal  pId -> address -> vote
    mapping(uint => mapping(address => bool)) public projectVotes;

    // Mapping to store whether a project is funded  pId -> funded or not
    mapping(uint => bool) public projectFunded;

    // Events for Project Proposal actions
    event ProjectProposalSubmitted(
        uint indexed projectid,
        address indexed proposalOwner
    );
    event ProjectVoteCasted(
        uint indexed projectid,
        address indexed voter,
        bool choice
    );
    event ProjectPaymentsVoting(
        uint indexed projectid,
        address indexed voter,
        bool[] choicePay
    );
    event ProjectPaymentsDesicion(
        uint indexed projectid,
        bool[] voteForPayments
    );
    event ProjectFundingReserved(
        uint indexed projectid,
        address indexed projectOwner
    );
    event ProjectPaymentWithdrawn(
        uint indexed projectid,
        address indexed projectOwner,
        uint amount
    );

    // Mapping to track delegated votes pId -> address -> delegeted or not
    mapping(uint => mapping(address => bool)) public hasDelegatedVote;
    // Mapping to store the voting impact for each address  pId -> address -> how many votes delegeted to this add
    mapping(uint => mapping(address => uint)) public votingImpact;

    // Function to delegate vote to another address
    function delegateVoteTo(address delegatee, uint projectId) public {
        updateAndGetTotalMembers();
        require(
            projectId < projectProposals.length &&
                memberstatus[delegatee] &&
                !projectVotes[projectId][msg.sender] &&
                !hasDelegatedVote[projectId][msg.sender]
        );

        // Mark that the caller has delegated their vote for this project
        hasDelegatedVote[projectId][msg.sender] = true;

        // Increase the voting impact of the delegatee
        votingImpact[projectId][delegatee]++;
        emit ProjectVoteCasted(projectId, msg.sender, true);
    }

    // Function to submit a new project proposal
    function submitProjectProposal(
        string memory ipfsHash,
        uint voteDeadline,
        uint[] memory paymentAmounts,
        uint[] memory paySchedule
    ) public returns (uint projectId) {
        require(
            voteDeadline > block.timestamp && paySchedule[0] > voteDeadline
        );

        // Check if the provided paySchedules are increasing
        for (uint i = 0; i < paySchedule.length - 1; i++) {
            require(paySchedule[i] < paySchedule[i + 1]);
        }
        // Check if the sender has enough tokens AND usd coin
        require(
            myGovToken.balanceOf(msg.sender) >= 5 &&
                usdStableCoin.balanceOf(msg.sender) >= 50
        );

        // Deduct MyGov tokens for project proposal submission
        myGovToken.transferFrom(msg.sender, address(this), 5);

        // Transfer 50 USD stable coin from the sender to the MyGov contract
        usdStableCoin.transferFrom(msg.sender, address(this), 50);

        uint totalAmount = 0;
        for (uint i = 0; i < paymentAmounts.length; i++) {
            totalAmount += paymentAmounts[i];
        }
        uint rAmount = totalAmount;

        // Create a new project proposal
        ProjectProposal memory newProposal = ProjectProposal({
            ipfsHash: ipfsHash,
            voteDeadline: voteDeadline,
            paymentAmounts: paymentAmounts,
            paySchedule: paySchedule,
            voteForPayments: new bool[](paySchedule.length),
            voteForPay: new uint[](paySchedule.length),
            voteAgainstPay: new uint[](paySchedule.length),
            votesFor: 0,
            votesAgainst: 0,
            isFunded: false,
            reserved: false,
            reservedAmount: rAmount,
            projectOwner: msg.sender,
            usdReceived: 0
        });

        // Store the new proposal in the projectProposals array
        projectProposals.push(newProposal);
        projectId = projectProposals.length - 1;

        emit ProjectProposalSubmitted(projectId, msg.sender);
        return projectId;
    }

    // Function to vote for a project proposal
    function voteForProjectProposal(uint projectid, bool choice) public {
        require(
            projectid < projectProposals.length &&
                myGovToken.balanceOf(msg.sender) >= 1 &&
                block.timestamp <= projectProposals[projectid].voteDeadline &&
                !hasDelegatedVote[projectid][msg.sender] &&
                !projectVotes[projectid][msg.sender]
        );

        // Update the voting impact based on the caller's voting impact
        uint impact = votingImpact[projectid][msg.sender] + 1;

        if (choice) {
            projectProposals[projectid].votesFor += impact;
        } else {
            projectProposals[projectid].votesAgainst += impact;
        }

        projectVotes[projectid][msg.sender] = true;
        emit ProjectVoteCasted(projectid, msg.sender, choice);
    }

    // Function to check if a project is funded or not
    function getIsProjectFunded(uint projectid) public {
        updateAndGetTotalMembers(); // Updating the member status
        require(projectid < projectProposals.length);
        // Checking if the number of votes for the project is sufficient (at least 10% of total members)
        require(
            projectProposals[projectid].votesFor >=
                updateAndGetTotalMembers() / 10
        );
        // Checking if the contract has sufficient USD balance for the reserved amount of the project
        require(
            usdStableCoin.balanceOf(address(this)) >=
                projectProposals[projectid].reservedAmount
        );
        projectProposals[projectid].isFunded = true;
    }

    // Function to calculate the total reserve
    function calculateTotalReserve() internal view returns (uint totalAmount) {
        for (uint i = 0; i < projectProposals.length; i++) {
            require(projectProposals[i].reserved);
            totalAmount += projectProposals[i].reservedAmount;
        }
        return totalAmount;
    }

    // Function to Check Total Reservable Amount
    function totalReservablaAmount() public view returns (uint) {
        uint reservableAmount = usdStableCoin.balanceOf(address(this)) -
            calculateTotalReserve();
        return reservableAmount;
    }

    // Function to reserve funding for a project proposal
    function reserveProjectGrant(uint projectid) public {
        require(
            projectid < projectProposals.length &&
                msg.sender == projectProposals[projectid].projectOwner &&
                block.timestamp <= projectProposals[projectid].voteDeadline &&
                projectProposals[projectid].isFunded &&
                !projectProposals[projectid].reserved
        );

        // Check if there is sufficient USD stablecoin to Reserve in the MyGov contract
        require(
            totalReservablaAmount() >=
                projectProposals[projectid].reservedAmount
        );
        projectProposals[projectid].reserved = true;
        emit ProjectFundingReserved(projectid, msg.sender);
    }

    // Function to vote for project payments
    function voteForProjectPayments(
        uint projectid,
        bool[] memory choicePay
    ) public {
        require(
            projectid < projectProposals.length &&
                balanceOf(msg.sender) >= 1 &&
                block.timestamp > projectProposals[projectid].voteDeadline &&
                !hasDelegatedVote[projectid][msg.sender] &&
                !projectVotes[projectid][msg.sender]
        );

        uint impact = votingImpact[projectid][msg.sender] + 1;
        uint nextPayment = getProjectNextPayment(projectid);

        for (uint i = 0; i <= nextPayment; i++) {
            if (choicePay[i]) {
                projectProposals[projectid].voteForPay[i] += impact;
            } else {
                projectProposals[projectid].voteAgainstPay[i] += impact;
            }
        }

        projectVotes[projectid][msg.sender] = true;
        emit ProjectPaymentsVoting(projectid, msg.sender, choicePay);
    }

    // to calculate the boolean value of each
    function getVoteForPaymentsValue(uint projectid) public {
        updateAndGetTotalMembers();
        for (
            uint i = 0;
            i < projectProposals[projectid].paySchedule.length;
            i++
        ) {
            if (
                projectProposals[projectid].voteForPay[i] >=
                updateAndGetTotalMembers() / 100
            ) {
                projectProposals[projectid].voteForPayments[i] == true;
            } else {
                projectProposals[projectid].voteForPayments[i] == false;
            }
        }
        emit ProjectPaymentsDesicion(
            projectid,
            projectProposals[projectid].voteForPayments
        );
    }

    // Function to get the next payment date for a project
    function getProjectNextPayment(
        uint projectid
    ) public view returns (uint nextPayment) {
        require(projectid < projectProposals.length);

        for (
            uint i = 1;
            i <= projectProposals[projectid].paySchedule.length &&
                projectProposals[projectid].voteForPayments[i - 1] == true;
            i++
        ) {
            if (block.timestamp < projectProposals[projectid].paySchedule[i]) {
                nextPayment = i;
                return i;
            }
        }
        // If all payment dates have passed, return 0
        return 0;
    }

    // Function to withdraw project payments if reserved
    function withdrawProjectPayments(uint projectid) public {
        require(projectid < projectProposals.length);
        require(msg.sender == projectProposals[projectid].projectOwner);
        require(projectProposals[projectid].reserved);

        for (
            uint i = 0;
            i < projectProposals[projectid].paySchedule.length;
            i++
        ) {
            if (
                block.timestamp <= projectProposals[projectid].paySchedule[i] &&
                projectProposals[projectid].voteForPayments[i]
            ) {
                usdStableCoin.transferFrom(
                    address(this),
                    msg.sender,
                    projectProposals[projectid].paymentAmounts[i]
                );
                emit ProjectPaymentWithdrawn(
                    projectid,
                    msg.sender,
                    projectProposals[projectid].paymentAmounts[i]
                );
                projectProposals[projectid].reservedAmount -= projectProposals[
                    projectid
                ].paymentAmounts[i];
                projectProposals[projectid].usdReceived += projectProposals[
                    projectid
                ].paymentAmounts[i];
            }
        }
    }

    // Function to get the owner of a project
    function getProjectOwner(
        uint projectid
    ) public view returns (address projectOwner) {
        require(projectid < projectProposals.length);
        return projectProposals[projectid].projectOwner;
    }

    // Function to get information about a project
    function getProjectInfo(
        uint projectid
    )
        public
        view
        returns (
            string memory ipfsHash,
            uint voteDeadline,
            uint[] memory paymentAmounts,
            uint[] memory paySchedule
        )
    {
        require(projectid < projectProposals.length);
        return (
            projectProposals[projectid].ipfsHash,
            projectProposals[projectid].voteDeadline,
            projectProposals[projectid].paymentAmounts,
            projectProposals[projectid].paySchedule
        );
    }

    // Function to get the number of project proposals
    function getNoOfProjectProposals() public view returns (uint numProposals) {
        return projectProposals.length;
    }

    // Function to get the number of funded projects
    function getNoOfFundedProjects() public view returns (uint numFunded) {
        uint count = 0;
        for (uint i = 0; i < projectProposals.length; i++) {
            if (projectFunded[i]) {
                count++;
            }
        }
        return count;
    }

    // Function to get the amount of USD received by a project
    function getUSDReceivedByProject(
        uint projectid
    ) public view returns (uint amount) {
        require(projectid < projectProposals.length);
        return projectProposals[projectid].usdReceived;
    }
}
