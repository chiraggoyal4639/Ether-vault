//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {EtherVault} from "../src/EtherVault.sol";

contract TestEtherVault is Test {
    EtherVault vault;
    address user = makeAddr("user");
    address user1 = makeAddr("user1");
    uint256 minETH;
    uint256 depositAmount;
    uint256 withdrawAmount;
    uint64 cooldown;
    address immutable owner;

    constructor() {
        owner = msg.sender;
    }

    event Deposited(address indexed funder, uint256 amount);
    event Withdrawn(address indexed withdrawer, uint256 amount);
    event Paused(address indexed _owner, string _massage);

    function setUp() external {
        vm.deal(user, 100 ether);
        vm.deal(user1, 100 ether);
        vm.startBroadcast();
        vault = new EtherVault();
        vm.stopBroadcast();
        minETH = vault.getMinimumETH();
        depositAmount = minETH + 0.1 ether;
        withdrawAmount = 0.02 ether;
        cooldown = uint64(vault.depositCooldown());
    }

    function simulateDeposit(address _user, uint256 _amount) public {
        vm.prank(_user);
        vault.deposit{value: _amount}();
    }

    function testDeposit() external {
        vm.expectEmit(true, false, false, true);
        emit Deposited(user, depositAmount);
        simulateDeposit(user, depositAmount);
        assertEq(vault.getBalance(user), depositAmount);
    }

    function testWithdraw() external {
        simulateDeposit(user, depositAmount);
        assertEq(vault.getBalance(user), depositAmount);

        vm.warp(block.timestamp + cooldown);
        uint256 newBalance = vault.getBalance(user);
        vm.prank(user);
        vm.expectEmit(true, true, false, true);
        emit Withdrawn(user, withdrawAmount);
        vault.withdraw(withdrawAmount);
        uint256 expectedBalance = (newBalance - withdrawAmount);
        assertEq(vault.getBalance(user), expectedBalance);
    }

    function testDepositRevertsForLowDeposit() external {
        uint256 _depositAmount = (minETH - 0.00001 ether);
        vm.expectRevert();
        simulateDeposit(user, _depositAmount);
    }

    function testWithdrawRevertsForInsufficientBalance() external {
        simulateDeposit(user, depositAmount);
        vm.expectRevert();
        vm.prank(user);
        vault.withdraw(depositAmount + 1 ether);
    }

    function testPausePreventsDeposits() external {
        vm.prank(msg.sender);
        vault.pause();
        vm.expectRevert();
        simulateDeposit(user, depositAmount);
    }

    function testFrequentDeposits() external {
        simulateDeposit(user, depositAmount);
        vm.expectRevert();
        simulateDeposit(user, depositAmount);
    }

    function testEmergencyModeAllowsUserWithdrawal() external {
        simulateDeposit(user, depositAmount);
        vm.startPrank(owner);
        vault.pause();
        vault.changeEmergency(50 seconds);
        vm.stopPrank();
        vm.warp(block.timestamp + cooldown);
        vm.prank(user);
        vault.withdraw(withdrawAmount);
    }

    function testOwnerEmergencyWithdrawAfterTimeout() external {
        simulateDeposit(user, depositAmount);
        simulateDeposit(user1, depositAmount);
        vm.startPrank(owner);
        vault.changeEmergency(50 seconds);
        vm.warp(block.timestamp + 50 seconds);
        vault.ownerEmergencyWithdraw();
        assertEq(address(vault).balance, 0);
    }

    function testReceiveFunction() public {
        uint256 sendAmount = 1 ether;
        vm.prank(user);
        (bool success,) = address(vault).call{value: sendAmount}("");
        require(success, "ETH transfer failed");
        assertEq(address(vault).balance, sendAmount);
        assertEq(vault.getBalance(user), 0);
    }

    function testBlacklistPreventsDeposit() public {
        vm.prank(owner);
        vault.blackList(user);
        vm.expectRevert();
        simulateDeposit(user, depositAmount);
    }

    function testWhitelistAllowsDepositAfterBlacklist() public {
        vm.startPrank(owner);
        vault.blackList(user);
        vault.whiteList(user);
        vm.stopPrank();
        simulateDeposit(user, depositAmount);
        assertEq(vault.getBalance(user), depositAmount);
    }

    function testOwnerCanNotWithdrawBeforeDeadline() public {
        simulateDeposit(user, depositAmount);
        vm.startPrank(msg.sender);
        vault.changeEmergency(1 hours);
        vm.expectRevert();
        vault.ownerEmergencyWithdraw();
        vm.stopPrank();
    }

    function testWithdrawRevertsWhenPaused() public {
        simulateDeposit(user, depositAmount);
        vm.warp(block.timestamp + cooldown);
        vm.prank(msg.sender);
        vault.pause();
        vm.expectRevert();
        vm.prank(user);
        vault.withdraw(withdrawAmount);
    }

    function testOwnerCannotWithdrawUserFunds() public {
        simulateDeposit(user, depositAmount);
        vm.warp(block.timestamp + cooldown);
        vm.prank(owner);
        vm.expectRevert();
        vault.withdraw(withdrawAmount);
    }
}
