// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./Membership.sol";
import "./USDStablecoin.sol";
import "./MyGovToken.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "hardhat/console.sol";

contract Surveys is Membership {
    // Contract addresses for external tokens
    address myGovTokenAddress;
    address usdStableCoinAddress;

    constructor(
        address _myGovTokenAddress,
        address _usdStableCoinAddress
    ) Membership(_myGovTokenAddress, _usdStableCoinAddress) {
        myGovTokenAddress = _myGovTokenAddress;
        usdStableCoinAddress = _usdStableCoinAddress;
    }

    //--------------------------------------------------SURVEY PART--------------------------------------------------
    // Structure to represent a Survey
    struct Survey {
        string ipfsHash;
        uint surveyDeadline;
        uint numChoices;
        uint atMostChoice;
        uint[] results;
        address owner;
        uint takersCount;
    }

    // Array to store all surveys
    Survey[] public surveys;

    // Events for Survey actions
    event SurveySubmitted(uint indexed surveyId, address indexed surveyOwner);
    event SurveyTaken(
        uint indexed surveyId,
        address indexed surveyTaker,
        uint[] choices
    );

    // Function to submit a new survey
    function submitSurvey(
        string memory ipfsHash,
        uint surveyDeadline,
        uint numChoices,
        uint atMostChoice
    ) public returns (uint surveyId) {
        require(
            block.timestamp < surveyDeadline &&
                numChoices >= 2 &&
                atMostChoice >= 1 &&
                numChoices >= atMostChoice &&
                myGovToken.balanceOf(msg.sender) >= 2 &&
                usdStableCoin.balanceOf(msg.sender) >= 5
        );

        // Deduct tokens  and USD for survey submission
        myGovToken.transferFrom(msg.sender, address(this), 2);

        usdStableCoin.transferFrom(msg.sender, address(this), 5);

        Survey memory newSurvey = Survey({
            ipfsHash: ipfsHash,
            surveyDeadline: surveyDeadline,
            numChoices: numChoices,
            atMostChoice: atMostChoice,
            results: new uint[](numChoices),
            owner: msg.sender,
            takersCount: 0
        });

        surveys.push(newSurvey);
        surveyId = surveys.length - 1;
        emit SurveySubmitted(surveyId, msg.sender);

        return surveyId;
    }

    // Mapping to store whether an address has taken a specific survey
    mapping(address => mapping(uint => bool)) public hasTakenSurvey;

    // Function to take a survey
    function takeSurvey(uint surveyId, uint[] memory choices) public {
        require(surveyId < surveys.length); // "Invalid survey ID"
        Survey storage survey = surveys[surveyId];

        require(
            block.timestamp <= survey.surveyDeadline &&
                survey.owner != msg.sender &&
                !hasTakenSurvey[msg.sender][surveyId] &&
                choices.length > 0 &&
                choices.length <= survey.atMostChoice
        );

        // Update survey results based on the choices
        for (uint i = 0; i < choices.length; i++) {
            survey.results[choices[i]]++;
        }

        // Update survey takers count
        survey.takersCount++;

        // Mark the survey as taken by the sender
        hasTakenSurvey[msg.sender][surveyId] = true;
        emit SurveyTaken(surveyId, msg.sender, choices);
    }

    // Function to get survey results
    function getSurveyResults(
        uint surveyId
    ) public view returns (uint numTaken, uint[] memory results) {
        require(surveyId < surveys.length); // "Invalid survey ID"
        return (surveys[surveyId].takersCount, surveys[surveyId].results);
    }

    // Function to get survey information
    function getSurveyInfo(
        uint surveyId
    )
        public
        view
        returns (
            string memory ipfsHash,
            uint surveyDeadline,
            uint numChoices,
            uint atMostChoice
        )
    {
        require(surveyId < surveys.length); // "Invalid survey ID"
        return (
            surveys[surveyId].ipfsHash,
            surveys[surveyId].surveyDeadline,
            surveys[surveyId].numChoices,
            surveys[surveyId].atMostChoice
        );
    }

    // Function to get survey owner
    function getSurveyOwner(
        uint surveyId
    ) public view returns (address surveyOwner) {
        require(surveyId < surveys.length); // "Invalid survey ID"
        return surveys[surveyId].owner;
    }

    // Function to get the number of surveys
    function getNoOfSurveys() public view returns (uint numSurveys) {
        return surveys.length;
    }
}
