// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "hardhat/console.sol";




// MyGov contract for MG Token
contract MyGovToken is ERC20 {


    constructor() ERC20("MyGov Token", "MG") {
        uint tokensupply = 20000000;
        _mint(msg.sender, tokensupply);
    }
 
}
