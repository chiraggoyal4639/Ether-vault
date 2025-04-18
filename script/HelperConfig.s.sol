//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";
import {Script} from "../lib/forge-std/src/Script.sol";

contract HelperConfig is Script {
    address active_network;
    uint64 immutable chainid;
    uint8 immutable decimals;
    int128 immutable answer;

    constructor() {
        chainid = uint64(block.chainid);
        decimals = 8;
        answer = 2000e8;
    }

    function run() external returns (address) {
        if (chainid == 1) active_network = mainnet();
        else if (chainid == 11155111) active_network = sepolia();
        else active_network = anvil();
        return active_network;
    }

    function sepolia() private pure returns (address) {
        return 0x694AA1769357215DE4FAC081bf1f309aDC325306;
    }

    function mainnet() private pure returns (address) {
        return 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
    }

    function anvil() private returns (address) {
        if (active_network != address(0)) return active_network;
        MockV3Aggregator mockAggregator = new MockV3Aggregator(decimals, answer);
        return address(mockAggregator);
    }
}
