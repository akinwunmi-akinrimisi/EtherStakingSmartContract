// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract EtherStaking is ReentrancyGuard {

    // State Variables
    address public owner;
    uint256 public rewardRate60Days;
    uint256 public rewardRate90Days;
    uint256 public rewardRate1Year;
    uint256 public totalStaked;
    uint256 public totalWithdrawn;
    uint256 public totalRewardsPaid;
    uint256 public earlyWithdrawalFeePercent = 15;
    bool public paused = false;

    struct Staker {
        uint256 stakedAmount;
        uint256 stakingTimestamp;
        uint256 stakingDuration;
        uint256 rewards;
        bool hasStaked;
        bool isRewardWithdrawn;
        bool isStakeWithdrawn;
        bool isRegistered;
        bool autoReinvest;
    }

    mapping(address => Staker) public stakers;
    address[] public stakerList;

    constructor() payable {
        owner = msg.sender;
        rewardRate60Days = 5;
        rewardRate90Days = 15;
        rewardRate1Year = 35;

        require(msg.value > 0, "Initial funding must be greater than zero.");
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    function register(uint256 _preferredDuration) public whenNotPaused {
        require(!stakers[msg.sender].isRegistered, "Already registered.");
        require(_preferredDuration == 60 days || _preferredDuration == 90 days || _preferredDuration == 365 days,
            "Invalid staking duration. Choose 60 days, 90 days, or 365 days.");

        stakers[msg.sender].stakingDuration = _preferredDuration;
        stakers[msg.sender].isRegistered = true;
        stakerList.push(msg.sender);

        emit Registered(msg.sender, _preferredDuration);
    }

    function stake() public payable whenNotPaused nonReentrant {
        require(stakers[msg.sender].isRegistered, "User is not registered.");
        require(msg.value > 0, "Staking amount must be greater than zero.");
        require(!stakers[msg.sender].hasStaked, "Already have an active stake.");

        stakers[msg.sender].stakedAmount = msg.value;
        stakers[msg.sender].stakingTimestamp = block.timestamp;
        stakers[msg.sender].rewards = 0;
        stakers[msg.sender].hasStaked = true;
        stakers[msg.sender].isStakeWithdrawn = false;
        stakers[msg.sender].isRewardWithdrawn = false;
        totalStaked += msg.value;

        emit Staked(msg.sender, msg.value, stakers[msg.sender].stakingDuration);
    }

    function calculateRewards(address _staker) public view returns (uint256) {
        Staker memory staker = stakers[_staker];
        uint256 rewardRate;

        if (staker.stakingDuration == 60 days) {
            rewardRate = rewardRate60Days;
        } else if (staker.stakingDuration == 90 days) {
            rewardRate = rewardRate90Days;
        } else if (staker.stakingDuration == 365 days) {
            rewardRate = rewardRate1Year;
        } else {
            return 0;
        }

        uint256 rewards = (staker.stakedAmount * rewardRate * staker.stakingDuration) / (100 * 365 days);
        return rewards;
    }

    function withdraw() public nonReentrant {
        Staker storage staker = stakers[msg.sender];
        require(staker.isRegistered, "User is not registered.");
        require(staker.hasStaked, "No active stake.");
        require(!staker.isStakeWithdrawn, "Staked Ether has already been withdrawn.");

        uint256 rewards = calculateRewards(msg.sender);
        uint256 stakedAmount = staker.stakedAmount;

        if (block.timestamp < staker.stakingTimestamp + staker.stakingDuration) {
            uint256 fee = (rewards * earlyWithdrawalFeePercent) / 100;
            rewards -= fee;
        }

        staker.isStakeWithdrawn = true;
        staker.hasStaked = false;
        staker.stakedAmount = 0;
        totalWithdrawn += stakedAmount;
        totalRewardsPaid += rewards;
        payable(msg.sender).transfer(stakedAmount + rewards);

        emit Withdrawn(msg.sender, stakedAmount, rewards);
    }

    // Function to get the staker's balance (staked amount and calculated rewards)
    function getStakerBalance(address _staker) public view returns (uint256, uint256) {
        Staker memory staker = stakers[_staker];
        uint256 stakedAmount = staker.stakedAmount;
        uint256 rewards = calculateRewards(_staker);
        return (stakedAmount, rewards);
    }

    // Function to get the contract balance
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }


    event Registered(address indexed user, uint256 preferredDuration);
    event Staked(address indexed user, uint256 amount, uint256 duration);
    event Withdrawn(address indexed user, uint256 stakedAmount, uint256 rewards);
}
