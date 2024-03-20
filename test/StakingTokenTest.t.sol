// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {StakingToken} from "../src/StakingToken.sol";
import {Test, console} from "forge-std/Test.sol";
import {DeployStakingToken} from "../script/DeployStakingToken.s.sol";

contract StakingTokenTest is Test {

    StakingToken public token;
    DeployStakingToken public deployer;

    // Addresses
    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    // Balances for the addresses above
    uint256 public constant BOB_STARTING_BALANCE = 100 ether;
    uint256 public constant ALICE_STARTING_BALANCE = 100 ether;

    function setUp() public {
        deployer = new DeployStakingToken();
        token = deployer.run();

        vm.prank(msg.sender);
        token.transfer(bob, BOB_STARTING_BALANCE);

        vm.prank(msg.sender);
        token.transfer(alice, ALICE_STARTING_BALANCE);
    }

    function testBalance() public view {
        assertEq(token.balanceOf(bob), BOB_STARTING_BALANCE);
    }

    function testBurnFunction() public {
        uint256 burnAmount = 50 ether;
        vm.prank(bob);
        token.transfer(bob, BOB_STARTING_BALANCE);
        token.burn(bob, burnAmount);
        assertEq(token.balanceOf(bob), BOB_STARTING_BALANCE - burnAmount);
        vm.stopPrank();
    }

    function testMintFunction() public {
        uint256 mintAmount = 50 ether;
        vm.prank(bob);
        token.transfer(bob, BOB_STARTING_BALANCE);
        token.mint(bob, mintAmount);
        assertEq(token.balanceOf(bob), BOB_STARTING_BALANCE + mintAmount);
        vm.stopPrank();
    }

    function testTransferFromFailsInsufficientAllowance() public {
        uint256 mintAmount = 100 ether; 
        uint256 transferAmount = 50 ether; 
        vm.prank(bob);
        token.mint(bob, mintAmount);
        vm.expectRevert();
        token.transferFrom(address(this), bob, transferAmount);
        vm.stopPrank();
    }

    function testAllowances() public {
        uint256 initialAllowance = 100 ether; 
        vm.prank(bob);
        token.approve(alice, initialAllowance);  
        uint256 transferAmount = 50 ether; 
        vm.prank(alice);
        token.transferFrom(bob, alice, transferAmount); 
        assertEq(token.balanceOf(alice), ALICE_STARTING_BALANCE + transferAmount);
        assertEq(token.balanceOf(bob), BOB_STARTING_BALANCE - transferAmount);
        vm.stopPrank();
    }

    function testStakeZeroAmount() public {
        vm.prank(bob);
        uint256 stakeAmount = 0 ether;
        vm.expectRevert();
        token.stake(stakeAmount);
        vm.stopPrank();
    }

    function testStakeAndUnstake() public {
        vm.prank(bob);
        uint256 stakeAmount = 20 ether;
        token.stake(stakeAmount);
        assertEq(token.getStakedBalance(bob), stakeAmount);
        assertTrue(token.getStakeStatus(bob));
        vm.stopPrank();
    }

    function testUnstakeAfter30Days() public {
        vm.prank(bob);
        uint256 stakeAmount = 20 ether;
        uint256 bonusOrBurnAmount = (stakeAmount * 20 / 100);
        token.stake(stakeAmount);
        assertEq(token.getStakedBalance(bob), stakeAmount);
        assertTrue(token.getStakeStatus(bob));
        vm.warp(50 days);
        vm.prank(bob);
        token.unstake();
        uint256 actualBalanceAfterStaking = token.balanceOf(bob) + stakeAmount + bonusOrBurnAmount;
        uint256 expectedBalance = 104 ether;
        assertEq(actualBalanceAfterStaking, expectedBalance);
        vm.stopPrank();
    }

    function testUnstakingWithZeroBalance() public {
        vm.prank(bob);
        vm.expectRevert();
        token.unstake();
        vm.stopPrank();
    }
}