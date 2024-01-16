// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "hardhat/console.sol";


// ERC20 contract for USD stable coin
contract USDStablecoin is ERC20 {
    constructor() ERC20("USD Stablecoin", "USD") {
        _mint(msg.sender, 10000000);
    }
}
