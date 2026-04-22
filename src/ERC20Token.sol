// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.21;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract ERC20Token is ERC20, Ownable {
    uint256 initialSupply;
    uint256 valueLimit = 10000;
    mapping(address => uint256) lastTransferTimeRecord;
    mapping(address => uint256) dayTotalLimit;

    constructor(uint256 initialSupply_) ERC20("NewBee", "NB") Ownable(msg.sender) {
        initialSupply = initialSupply_;
        _mint(msg.sender, initialSupply * 10 ** decimals());
    }

    /* modifier safeChecker(address ,uint256 value) {
         if (block.timestamp - lastTransferTimeRecord[msg.sender] > 1 days ) {
             dayTotalLimit[msg.sender] = 0;
         }
         require(
             value <= valueLimit && dayTotalLimit[msg.sender] + value <= 20000, "Limited Transfer"
         );
         _;
     }*/

    function transfer(address to, uint256 value) public override /*safeChecker(msg.sender ,value)*/  returns (bool) {
        if (block.timestamp - lastTransferTimeRecord[msg.sender] > 1 days) {
            dayTotalLimit[msg.sender] = 0;
        }
        require(value <= valueLimit && dayTotalLimit[msg.sender] + value <= 20000, "Limited Transfer");

        address owner = _msgSender();
        _transfer(owner, to, value);
        lastTransferTimeRecord[msg.sender] = block.timestamp; //update last transfer time.
        dayTotalLimit[msg.sender] += value;
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public override returns (bool) {
        if (block.timestamp - lastTransferTimeRecord[from] > 1 days) {
            dayTotalLimit[from] = 0;
        }

        require(value <= valueLimit && dayTotalLimit[from] + value <= 20000, "Limited Transfer");

        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        lastTransferTimeRecord[from] = block.timestamp; //update last transfer time.
        dayTotalLimit[from] += value;
        return true;
    }

    function mint(uint256 amount) internal onlyOwner {
        _mint(msg.sender, amount);
    }

    function burn(address account, uint256 value) internal onlyOwner {
        _burn(account, value);
    }
}
