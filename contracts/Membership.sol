// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./MyGovToken.sol";
import "./USDStablecoin.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "hardhat/console.sol";

contract Membership is ERC20 {
    MyGovToken public myGovToken;
    USDStablecoin public usdStableCoin;

    // Mapping to store MyGov token balances
    mapping(address => uint) private myGovBalances;

    // Mapping to store USD stablecoin balances
    mapping(address => uint) private usdBalances;

    constructor(
        address _myGovAddress,
        address _usdAddress
    ) ERC20("MyGov Token", "MG") {
        myGovToken = MyGovToken(_myGovAddress);
        usdStableCoin = USDStablecoin(_usdAddress);
    }

    // Function to get MyGov token balance of an address
    function myGovBalanceOf(address account) public view returns (uint) {
        return myGovBalances[account];
    }

    // Function to get USD stablecoin balance of an address
    function usdBalanceOf(address account) public view returns (uint) {
        return usdBalances[account];
    }

    // Internal function to transfer MyGov tokens
    function _transferMyGov(
        address sender,
        address recipient,
        uint mygovamount
    ) public payable {
        require(
            myGovBalances[sender] >= mygovamount,
            "Insufficient MyGov balance"
        );
        myGovBalances[sender] -= mygovamount;
        myGovBalances[recipient] += mygovamount;
        myGovToken.transferFrom(sender, recipient, mygovamount);
    }

    // Internal function to transfer USD stablecoin
    function _transferUSD(
        address sender,
        address recipient,
        uint usdamount
    ) public payable {
        require(usdBalances[sender] >= usdamount, "Insufficient USD balance");
        usdBalances[sender] -= usdamount;
        usdBalances[recipient] += usdamount;
        // Assuming you have a transfer function in the ERC20 contract for USD
        usdStableCoin.transferFrom(sender, recipient, usdamount);
    }

    // Override transfer function to handle MyGov and USD transfers
    function transferAll(
        address sender,
        address recipient,
        uint usdamount,
        uint mygovamount
    ) public {
        sender = msg.sender;
        _transferMyGov(sender, recipient, mygovamount);
        _transferUSD(sender, recipient, usdamount);
    }

    //------------------------------- MEMBERSHIP STATUS PART-------------------------------------------------------------------
    //All the addresses in the contract
    address[] public allAddresses;

    // Mapping to store whether an address is a member
    mapping(address => bool) public memberstatus;

    // Update member status and get total member count
    function updateAndGetTotalMembers() public returns (uint totalMembers) {
        for (uint i = 0; i < allAddresses.length; i++) {
            if (balanceOf(allAddresses[i]) >= 1) {
                memberstatus[allAddresses[i]] = true;
                totalMembers++;
            } else {
                memberstatus[allAddresses[i]] = false;
            }
        }
    }

    //------------------------------- DONATIONS AND FAUCET PART---------------------------------------------------------------------

    // Mapping to keep track of addresses that have received tokens from the faucet
    mapping(address => bool) private hasReceivedFromFaucet;

    // Faucet function to distribute MyGov tokens
    function faucet() external {
        require(!hasReceivedFromFaucet[msg.sender]); //"You have already received tokens"
        _mint(msg.sender, 1);
        hasReceivedFromFaucet[msg.sender] = true;
    }

    // Function to donate MyGov tokens to the contract
    function donateMyGovToken(uint amount) public {
        require(amount > 0); // "The Donation Amount must be bigger than 0"
        require(myGovToken.balanceOf(msg.sender) >= amount); // "Insufficient MyGov tokens for donation"
        myGovToken.transferFrom(msg.sender, address(this), amount);
    }

    // Function to donate USD stablecoin to MyGov without sending additional tokens to the sender
    function donateUSD(uint amount) public {
        require(amount > 0); // "Donation amount must be greater than 0"
        require(usdStableCoin.balanceOf(msg.sender) >= amount); // "Insufficient USD allowance"

        // Transfer USD stablecoin from the sender to MyGov contract
        usdStableCoin.transferFrom(msg.sender, address(this), amount);
    }
}
