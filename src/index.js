import { ethers } from "./ethers-5.1.esm.min.js";

//import "./abis/USDStablecoinAbi.json";
//import "./abis/MyGovTokenAbi.json";
//import "./abis/MembershipAbi.json";
//import "./abis/SurveyAbi.json";
//import "./abis/ProjectAbi.json";
//import "./config.json";

const connectButton = document.getElementById("connectButton");
connectButton.onclick = connectWallet;
const donationButton = document.getElementById("donationButton");
donationButton.onclick = faucet;

async function connectWallet() {
  if (typeof window.ethereum !== "undefined") {
    try {
      await ethereum.request({ method: "eth_requestAccounts" });
    } catch (error) {
      console.log(error);
    }
    connectButton.innerHTML = "Connected";
    const accounts = await ethereum.request({ method: "eth_accounts" });
    console.log(accounts);
  } else {
    connectButton.innerHTML = "Please install MetaMask";
  }
}

function faucet() {
  rc = web3js.eth.faucet(function (error, result) {
    if (!error) {
      document.getElementById("donationButton").innerHTML = "Token is Taken";
    } else {
      console.error(error);
    }
  });
}

function donateMyGovToken() {
  var fromamount = document.getElementById("donations-mygov-input").value;
  rc = web3js.eth.donateMyGovToken(fromamount, function (error, result) {
    if (!error) {
      console.log(result);
    } else {
      console.error(error);
    }
  });
}

function donateUSD() {
  var fromamount = document.getElementById("donations-usd-input").value;
  rc = web3js.eth.donateUSD(fromamount, function (error, result) {
    if (!error) {
      console.log(result);
    } else {
      console.error(error);
    }
  });
}

function submitSurvey() {
  var fromhash = document.getElementById("ipfHash-survey").value;
  var fromdatetime = document.getElementById("deadline-survey").value;
  var fromnumchoice = document.getElementById("numchoice").value;
  var fromatmostchoice = document.getElementById("atmostchoice").value;

  rc = web3js.eth.submitSurvey(
    fromhash,
    fromdatetime,
    fromnumchoice,
    fromatmostchoice,
    function (error, result) {
      if (!error) {
        var surveyid = result;
        document.getElementById("submit-survey-return-id").innerHTML =
          "Survey Id:" + surveyid;
      } else {
        console.error(error);
      }
    }
  );
}

function getSurveyInfo() {
  var fromid = document.getElementById("surveyid-getinfo").value;
  rc = web3js.eth.getSurveyInfo(fromid, function (error, result) {
    if (!error) {
      var results = result;
      document.getElementById("get-survey-info-return-ipfHash").innerHTML =
        "Survey ipfHash:" + results[0];
      document.getElementById("get-survey-info-return-datetime").innerHTML =
        "Survey DateTime:" + results[1];
      document.getElementById("get-survey-info-return-numchoice").innerHTML =
        "Survey Num Cohice:" + results[2];
      document.getElementById("get-survey-info-return-atmostchoice").innerHTML =
        "Survey At Most Choice:" + results[3];
    } else {
      console.error(error);
    }
  });
}

function takeSurvey() {
  var fromid = document.getElementById("surveyid-takesurvey").value;
  var fromchoices = document.getElementById("choices-takesurvey").value;
  rc = web3js.eth.takeSurvey(fromid, fromchoices, function (error, result) {
    if (!error) {
      console.log(result);
    } else {
      console.error(error);
    }
  });
}

function getSurveyResults() {
  var fromid = document.getElementById("surveyid-getsurveyresults").value;
  rc = web3js.eth.getSurveyResults(fromid, function (error, result) {
    if (!error) {
      var results = result;
      document.getElementById(
        "get-survey-result-return-Taken-Count"
      ).innerHTML = "Survey Taken Num:" + results[0];
      document.getElementById("get-survey-result-return-results").innerHTML =
        "Survey Results:" + results[1];
    } else {
      console.error(error);
    }
  });
}

function getSurveyOwner() {
  var fromid = document.getElementById("surveyid-getsurveyowner").value;
  rc = web3js.eth.getSurveyOwner(fromid, function (error, result) {
    if (!error) {
      var fromowner = result;
      document.getElementById("get-survey-owner-return-owner").innerHTML =
        "Survey Owner:" + fromowner;
    } else {
      console.error(error);
    }
  });
}

function getNoOfSurveys() {
  var fromid = document.getElementById("surveyid-getnoofsurveys").value;
  rc = web3js.eth.getNoOfSurveys(fromid, function (error, result) {
    if (!error) {
      var fromnosurvey = result;
      document.getElementById("get-survey-return-numberofsurveys").innerHTML =
        "Survey Num:" + fromnosurvey;
    } else {
      console.error(error);
    }
  });
}

function submitProjectProposal() {
  var fromhash = document.getElementById("ipfHash-project").value;
  var fromdatetime = document.getElementById("deadline-project").value;
  var frompayamounts = document.getElementById("paymentamounts-projec").value;
  var frompaydeadline = document.getElementById(
    "paymentdeadlines-project"
  ).value;
  rc = web3js.eth.submitProjectProposal(
    fromhash,
    fromdatetime,
    frompayamounts,
    frompaydeadline,
    function (error, result) {
      if (!error) {
        var projectid = result;
        document.getElementById("submit-project-return-id").innerHTML =
          "Project Id:" + projectid;
      } else {
        console.error(error);
      }
    }
  );
}

function delegateVoteTo() {
  var fromid = document.getElementById("projectid-delegatevote").value;
  var fromadr = document.getElementById("address-delegatevote").value;
  rc = web3js.eth.delegateVoteTo(fromid, fromadr, function (error, result) {
    if (!error) {
      console.log(result);
    } else {
      console.error(error);
    }
  });
}

function showyesnobuttons() {
  rc = web3js.eth.showyesnobuttons(function (error, result) {
    if (!error) {
      console.log(result);
      document.getElementById("vote-for-project-yes-button").style.visibility =
        "visible";
      document.getElementById("vote-for-project-no-button").style.visibility =
        "visible";
    } else {
      console.error(error);
    }
  });
}

function voteForProjectProposalyes() {
  var fromid = document.getElementById(
    "projectid-voteforprojectproposal"
  ).value;
  rc = web3js.eth.voteForProjectProposal(
    fromid,
    true,
    function (error, result) {
      if (!error) {
        console.log(result);
      } else {
        console.error(error);
      }
    }
  );
}

function voteForProjectProposalno() {
  var fromid = document.getElementById(
    "projectid-voteforprojectproposal"
  ).value;
  rc = web3js.eth.voteForProjectProposal(
    fromid,
    false,
    function (error, result) {
      if (!error) {
        console.log(result);
      } else {
        console.error(error);
      }
    }
  );
}

function getIsProjectFunded() {
  var fromid = document.getElementById("projectid-funded").value;

  if (
    web3js.eth.getIsProjectFunded(fromid, function (error, result) {
      if (!error) {
        document.getElementById("isfunded-project-return-funded").innerHTML =
          "Funded Status: Funded";
      } else {
        console.error(error);
      }
    })
  );
  else if (
    !web3js.eth.getIsProjectFunded(fromid, function (error, result) {
      if (!error) {
        document.getElementById("isfunded-project-return-funded").innerHTML =
          "Funded Status: Not Funded";
      } else {
        console.error(error);
      }
    })
  );
}

function reserveProjectGrant() {
  var fromid = document.getElementById("projectid-reserve").value;
  rc = web3js.eth.reserveProjectGrant(fromid, function (error, result) {
    if (!error) {
      console.log("reserved");
    } else {
      console.error(error);
    }
  });
}

function voteForProjectPaymentsyes_() {
  var fromid = document.getElementById("projectid-voteforpayment").value;
  rc = web3js.eth.voteForProjectPayments(
    fromid,
    true,
    function (error, result) {
      if (!error) {
        console.log(result);
      } else {
        console.error(error);
      }
    }
  );
}

function voteForProjectPaymentsno_() {
  var fromid = document.getElementById("projectid-voteforpayment").value;
  rc = web3js.eth.voteForProjectPayments(
    fromid,
    false,
    function (error, result) {
      if (!error) {
        console.log(result);
      } else {
        console.error(error);
      }
    }
  );
}

function showyesnobuttons_() {
  rc = web3js.eth.showyesnobuttons_(function (error, result) {
    if (!error) {
      console.log(result);
      document.getElementById(
        "vote-for-project-payment-yes-button"
      ).style.visibility = "visible";
      document.getElementById(
        "vote-for-project-payment-no-button"
      ).style.visibility = "visible";
    } else {
      console.error(error);
    }
  });
}

function getProjectNextPayment() {
  var fromid = document.getElementById("projectid-nexttimepayment").value;
  rc = web3js.eth.getProjectNextPayment(fromid, function (error, result) {
    if (!error) {
      var frompay = result;
      document.getElementById("get-project-return-nextpay").innerHTML =
        "Next Payment:" + frompay;
    } else {
      console.error(error);
    }
  });
}

function withdrawProjectPayments() {
  var fromid = document.getElementById("projectid-witdraw").value;
  rc = web3js.eth.withdrawProjectPayments(fromid, function (error, result) {
    if (!error) {
      console.log(result);
    } else {
      console.error(error);
    }
  });
}

function getProjectInfo() {
  var fromid = document.getElementById("projectid-projectinfo").value;
  rc = web3js.eth.getProjectInfo(fromid, function (error, result) {
    if (!error) {
      var fromresults = result;
      document.getElementById("get-project-return-ipfhash").innerHTML =
        "Project ipfhash :" + fromresults[0];
      document.getElementById("get-project-return-datetime").innerHTML =
        "Project datetime:" + fromresults[1];
      document.getElementById("get-project-return-paymentamount").innerHTML =
        "Project paymentamount :" + fromresults[2];
      document.getElementById("get-project-return-paymentdeadline").innerHTML =
        "Project paymentdeadline :" + fromresults[3];
    } else {
      console.error(error);
    }
  });
}

function getProjectOwner() {
  var fromid = document.getElementById("projectid-getprojectowner").value;
  rc = web3js.eth.getProjectOwner(fromid, function (error, result) {
    if (!error) {
      var fromowner = result;
      document.getElementById("get-project-return-owner").innerHTML =
        "Project Owner:" + fromowner;
    } else {
      console.error(error);
    }
  });
}

function getUSDReceivedByProject() {
  var fromid = document.getElementById("projectid-getnoofusd").value;
  rc = web3js.eth.getUSDReceivedByProject(fromid, function (error, result) {
    if (!error) {
      var fromusd = result;
      document.getElementById("get-project-return-usdrecived").innerHTML =
        "USD Received By The Project:" + fromusd;
    } else {
      console.error(error);
    }
  });
}

function getNoOfFundedProjects() {
  rc = web3js.eth.getNoOfFundedProjects(function (error, result) {
    if (!error) {
      var fromfundno = web3js.eth.getNoOfFundedProjects();
      document.getElementById("get-project-return-nooffunded").innerHTML =
        "No Of Funded Projects:" + fromfundno;
    } else {
      console.error(error);
    }
  });
}

function getNoOfProjectProposals() {
  rc = web3js.eth.getNoOfProjectProposals(function (error, result) {
    if (!error) {
      var fromnopro = web3js.eth.getNoOfProjectProposals();
      document.getElementById("get-project-return-noofproject").innerHTML =
        "No Of Funded Projects:" + fromnopro;
    } else {
      console.error(error);
    }
  });
}
