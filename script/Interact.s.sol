// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {EtherVault} from "../src/EtherVault.sol";
import {DeployEtherVault} from "./DeployEtherVault.s.sol";

contract Interact is Script {
    EtherVault vault;
    address user;

    function run() external {
        user = msg.sender;
        vault = new DeployEtherVault().run();
        doDeposit(user);
        doPauseTest();
        doUnpauseTest();
        doWithdrawTest(user);
    }

    function doDeposit(address _user) internal {
        vm.startPrank(_user);
        vault.deposit{value: 1 ether}();
        vm.stopPrank();
        console.log("Deposited 1 ETH");
    }

    function doPauseTest() internal {
        vm.startBroadcast();
        vault.pause();
        vm.stopBroadcast();
        vm.startPrank(user);
        try vault.deposit{value: 1 ether}() {
            console.log("Deposit unexpectedly succeeded");
        } catch {
            console.log("Deposit correctly failed during pause");
        }
        vm.stopPrank();
    }

    function doUnpauseTest() internal {
        vm.startBroadcast();
        vault.unpause();
        vm.stopBroadcast();
        vm.startPrank(user);
        vm.warp(vault.lastDepositAt(user) + vault.depositCooldown() + 1);
        try vault.deposit{value: 1 ether}() {
            console.log("Deposit succeeded");
        } catch {
            console.log("Deposit unexpectedly failed");
        }
        vm.stopPrank();
    }

    function doWithdrawTest(address _user) internal {
        uint256 cooldown = vault.depositCooldown();
        vm.warp(block.timestamp + cooldown + 1);
        vm.startPrank(_user);
        vault.withdraw(0.2 ether);
        vm.stopPrank();
        console.log("Withdrawal successful");
    }
}
