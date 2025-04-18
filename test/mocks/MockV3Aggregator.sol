// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract MockV3Aggregator {
    uint256 ETHprice;
    uint256 Decimals;
    int128 answer;
    uint80 roundId;
    uint128 startedAt;
    uint128 updatedAt;
    uint80 answeredInRound;

    constructor(uint8 decimals, int128 initialAnswer) {
        Decimals = decimals;
        answer = initialAnswer;
        roundId = 1;
        startedAt = uint128(block.timestamp);
        answeredInRound = roundId;
    }

    function latestRoundData() external view returns (uint80, int128, uint128, uint128, uint80) {
        return (roundId, answer, startedAt, updatedAt, answeredInRound);
    }

    function updateAnswer(int128 _newAnswer) external {
        answer = _newAnswer;
        updatedAt = uint128(block.timestamp);
        answeredInRound++;
        roundId++;
    }
}
