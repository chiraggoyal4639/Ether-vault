//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {EtherVault} from "../src/EtherVault.sol";
import {Script, console} from "../lib/forge-std/src/Script.sol";

contract DeployEtherVault is Script {
    function run() external returns (EtherVault) {
        vm.startBroadcast();
        console.log("Deploying EtherVault...");
        EtherVault etherVault = new EtherVault();
        console.log("Deployed at:", address(etherVault));
        vm.stopBroadcast();
        vm.roll(block.number + 1);
        console.log("EtherVault contract deployed to: ", address(etherVault));
        return etherVault;
    }
}
