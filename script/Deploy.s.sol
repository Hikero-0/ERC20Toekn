// SPDX-License-Identifier: MIT

pragma solidity ^0.8.21;

import {Script} from "forge-std/Script.sol";
import {ERC20Token} from "../src/ERC20Token.sol";

contract Deploy is Script {
    uint256 initialSupply = 100000;

    function run() external {
        vm.startBroadcast();
        ERC20Token erc20Token = new ERC20Token(initialSupply);
        vm.stopBroadcast();
    }
}
