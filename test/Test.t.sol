// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {ERC20Token} from "../src/ERC20Token.sol";
import {Test, console} from "forge-std/Test.sol";

contract TestERC20Token is Test {
    ERC20Token token;
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    uint256 initialSupply = 100000;

    function setUp() public {
        token = new ERC20Token(initialSupply);
    }

    function testTransfer() public {
        uint256 amount1 = 6000;
        uint256 amount2 = 15000;
        uint256 aliceOverLimit = 10000;

        token.transfer(alice, amount1);
        bool aliceSuccess = token.transfer(alice, amount1);
        assertTrue(aliceSuccess);

        vm.expectRevert("Limited Transfer");
        token.transfer(alice, aliceOverLimit);

        vm.warp(block.timestamp + 1 days + 1);
        bool aliceDayGapSuccess = token.transfer(alice, aliceOverLimit);
        assertTrue(aliceDayGapSuccess);

        vm.expectRevert("Limited Transfer");
        token.transfer(bob, amount2);
    }

    function testTransferFrom() public {
        uint256 fundAliceAmount = 20000;
        uint256 amount1 = 5000;
        uint256 amount2 = 10000;
        uint256 overValueLimit = 10001;
        uint256 exceedDailyLimit = 6000;
        uint256 nextDayAmount = 5000;

        bool success1 = token.transfer(alice, 10000);
        assertTrue(success1);

        bool success2 = token.transfer(alice, 10000);
        assertTrue(success2);

        assertEq(token.balanceOf(alice), fundAliceAmount);

        // alice 授权给 bob
        vm.prank(alice);
        token.approve(bob, fundAliceAmount);

        // 第一次 transferFrom: 5000，成功
        vm.prank(bob);
        bool firstSuccess = token.transferFrom(alice, bob, amount1);
        assertTrue(firstSuccess);

        // 第二次 transferFrom: 10000，成功
        // 此时 alice 当天累计 = 15000
        vm.prank(bob);
        bool secondSuccess = token.transferFrom(alice, bob, amount2);
        assertTrue(secondSuccess);

        assertEq(token.balanceOf(alice), 5000);
        assertEq(token.balanceOf(bob), 15000);

        // 单笔超过 10000，失败
        vm.prank(bob);
        vm.expectRevert("Limited Transfer");
        token.transferFrom(alice, bob, overValueLimit);

        // 当天累计超过 20000，失败
        // 当前累计 15000，再转 6000 => 21000
        vm.prank(bob);
        vm.expectRevert("Limited Transfer");
        token.transferFrom(alice, bob, exceedDailyLimit);

        // 到第二天，额度应重置
        vm.warp(block.timestamp + 1 days + 1);

        vm.prank(bob);
        bool nextDaySuccess = token.transferFrom(alice, bob, nextDayAmount);
        assertTrue(nextDaySuccess);

        assertEq(token.balanceOf(alice), 0);
        assertEq(token.balanceOf(bob), 20000);
    }
}

