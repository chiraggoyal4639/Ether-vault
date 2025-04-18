// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

/// @title EtherVault - A secure ETH deposit and withdrawal contract
/// @author Chirag
/// @notice You can deposit and withdraw ETH securely
/// @dev All function calls are currently implemented without side effects

contract EtherVault is PriceConverter {
    address immutable owner;
    bool pausedState;
    uint256 public immutable MINIMUM_USD;
    bool private isEmergency;
    uint64 emergencyStartedAt;
    uint64 emergencyDuration;
    uint256 public constant maxDepositPerUser = 15 ether;
    uint256 public constant depositCooldown = 20 seconds;

    mapping(address => uint256) userBalance;
    mapping(address => bool) isSpam;
    mapping(address => uint256) public lastDepositAt;

    modifier onlyOwner() {
        if (msg.sender != owner) revert("You are not owner");
        _;
    }

    modifier notPaused() {
        if (pausedState == true && isEmergency == false) revert contractPaused(pausedState);
        _;
    }

    modifier checkSpam() {
        if (isSpam[msg.sender] == true) revert flaggedSpam("you are flagged as spam");
        _;
    }

    modifier outOfTime() {
        if (isEmergency == true && block.timestamp >= emergencyStartedAt + emergencyDuration) {
            revert timeError("Out of time");
        }
        _;
    }

    modifier earlyWithdraw() {
        if (lastDepositAt[msg.sender] != 0) {
            require(
                block.timestamp >= lastDepositAt[msg.sender] + depositCooldown, "You are not eligible to withdraw now"
            );
        }
        _;
    }

    modifier maxDeposit() {
        require(userBalance[msg.sender] + msg.value <= maxDepositPerUser, "Deposit exceeds max limit per user");
        _;
    }

    modifier noFrequentDeposit() {
        if (lastDepositAt[msg.sender] != 0) {
            require(block.timestamp >= lastDepositAt[msg.sender] + depositCooldown, "Wait before next deposit");
        }
        _;
    }

    event Deposited(address indexed funder, uint256 amount);
    event Withdrawn(address indexed withdrawer, uint256 amount);
    event Paused(address indexed _owner, string _massage);
    event Unpaused(address indexed _owner, string _massage);
    event emergency(bool _isEmergency, uint64 _emergencyStartedAt);
    event ownerWithdrewMoney(string _massage);
    event Received(address indexed sender, uint256 amount);

    error lowDeposit(uint256 amount);
    error outOfBalance(uint256 accountBalance, uint256 amount);
    error contractPaused(bool pausedState);
    error flaggedSpam(string massage);
    error timeError(string massage);

    constructor() {
        owner = msg.sender;
        MINIMUM_USD = 10;
    }
    /// @return amount of minimum ETH a user can deposit

    function getMinimumETH() external view returns (uint256) {
        uint256 minETH = USDtoETH(MINIMUM_USD);
        return minETH;
    }
    /// @return user address who deployed the contract

    function getOwner() external view returns (address) {
        return owner;
    }
    /// @notice tells user's account balance

    function getBalance(address _user) external view returns (uint256) {
        return userBalance[_user];
    }
    /// @notice by using this you can deposit ETH in your account
    /// @dev it checks contract pausness, spam, notFrequentDeposit & amount is not less than minimum amount setted

    function deposit() public payable notPaused checkSpam maxDeposit noFrequentDeposit {
        uint128 fundInUSD = uint128(getConversionRate(msg.value));
        if (fundInUSD < MINIMUM_USD) revert lowDeposit(fundInUSD);
        userBalance[msg.sender] += msg.value;
        lastDepositAt[msg.sender] = block.timestamp;
        emit Deposited(msg.sender, msg.value);
    }
    /// @notice by using this you can withdraw your ETH from your account
    /// @dev it checks contract pausness according to emergency too and not instant withdraw after deposit

    function withdraw(uint256 _amount) public earlyWithdraw notPaused {
        if (userBalance[msg.sender] < _amount) revert outOfBalance(userBalance[msg.sender], _amount);
        userBalance[msg.sender] -= _amount;
        (bool sent,) = payable(msg.sender).call{value: _amount}("");
        require(sent, "Withdrawal failed");
        emit Withdrawn(msg.sender, _amount);
    }
    /// @dev owner can pause contract by this

    function pause() public onlyOwner {
        pausedState = true;
        emit Paused(owner, "contract is pause for sometime");
    }
    /// @dev owner can unpause contract by this

    function unpause() public onlyOwner {
        pausedState = false;
        emit Unpaused(owner, "contract has unpaused and is ready to use");
    }
    /// @dev owner can mark anyone as spammer by this

    function blackList(address spammer) public onlyOwner {
        isSpam[spammer] = true;
    }
    /// @dev owner can unmark again as spammer by this

    function whiteList(address spammer) public onlyOwner {
        isSpam[spammer] = false;
    }

    /// @dev owner can announce and get back emergency by this
    function changeEmergency(uint64 _emergencyDuration) public onlyOwner {
        if (isEmergency == true) {
            isEmergency = false;
        } else {
            isEmergency = true;
            emergencyStartedAt = uint64(block.timestamp);
            emergencyDuration = _emergencyDuration;
            emit emergency(isEmergency, emergencyStartedAt);
        }
    }
    /// @dev owner can withdraw after deadline during emergency by this

    function ownerEmergencyWithdraw() public onlyOwner {
        if (isEmergency == true && block.timestamp >= emergencyStartedAt + emergencyDuration) {
            (bool sent,) = payable(owner).call{value: address(this).balance}("");
            require(sent, "Withdrawal failed");
        } else {
            revert timeError("withdrawal not allowed till now");
        }
    }
    /// @dev if anyone send a transaction without using a function then tells him that he sent a transaction

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
}
