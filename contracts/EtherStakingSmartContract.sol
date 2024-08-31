// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EtherStaking {

    // State Variables
    address public owner; // Owner Address
    uint256 public rewardRate60Days; // Reward Rate for 60 days
    uint256 public rewardRate90Days; // Reward Rate for 90 days
    uint256 public rewardRate1Year;  // Reward Rate for 1 year (365 days)
    uint256 public totalStaked; // Total Staked Ether
    uint256 public constant earlyWithdrawalFeePercent = 15; // 15% fee for early withdrawal

    // Struct for Staker Information
    struct Staker {
        uint256 stakedAmount;       // The amount of Ether staked by the user
        uint256 stakingTimestamp;   // The timestamp when the Ether was staked
        uint256 stakingDuration;    // The selected staking duration (in days)
        uint256 rewards;            // The calculated rewards for the staker
        bool hasStaked;             // Whether the user has an active stake
        bool isRewardWithdrawn;     // Whether the rewards have been withdrawn
        bool isStakeWithdrawn;      // Whether the staked Ether has been withdrawn
        bool isRegistered;          // Whether the user is registered
    }

    // Mapping to store stakers' information
    mapping(address => Staker) public stakers;

    // Array to store the list of stakers
    address[] public stakerList;

    // Constructor to initialize contract
    constructor() payable {
        owner = msg.sender; // Set the owner of the contract to the deployer
        rewardRate60Days = 5; // Initialize reward rate for 60 days (5%)
        rewardRate90Days = 15; // Initialize reward rate for 90 days (15%)
        rewardRate1Year = 35;   // Initialize reward rate for 1 year (365 days) (35%)

        // Ensure the contract starts with a non-zero balance
        require(msg.value > 0, "Initial funding must be greater than zero.");
    }

    // Register Function
    function register(uint256 _preferredDuration) public {
        // Ensure the user is not already registered
        require(!stakers[msg.sender].isRegistered, "Already registered.");

        // Ensure a valid duration is selected
        require(
            _preferredDuration == 60 days || _preferredDuration == 90 days || _preferredDuration == 365 days,
            "Invalid staking duration. Choose 60 days, 90 days, or 365 days."
        );

        // Register the user with preferred staking duration
        stakers[msg.sender].stakingDuration = _preferredDuration;
        stakers[msg.sender].isRegistered = true;

        // Add to the list of stakers
        stakerList.push(msg.sender);

        // Emit event for registration
        emit Registered(msg.sender, _preferredDuration);
    }

    // Stake Function
    function stake() public payable {
        // Ensure the user is registered
        require(stakers[msg.sender].isRegistered, "User is not registered.");

        // Validate Staking Amount
        require(msg.value > 0, "Staking amount must be greater than zero.");

        // Check for Existing Active Stake
        require(!stakers[msg.sender].hasStaked, "Already have an active stake.");

        // Update Staking Information
        stakers[msg.sender].stakedAmount = msg.value;
        stakers[msg.sender].stakingTimestamp = block.timestamp;
        stakers[msg.sender].rewards = 0;
        stakers[msg.sender].hasStaked = true;
        stakers[msg.sender].isStakeWithdrawn = false;
        stakers[msg.sender].isRewardWithdrawn = false;

        // Update total staked Ether
        totalStaked += msg.value;

        // Emit Staked Event
        emit Staked(msg.sender, msg.value, stakers[msg.sender].stakingDuration);
    }

    // Function to calculate rewards (Example calculation based on simple interest)
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
            return 0; // Invalid duration, return 0 rewards
        }

        // Calculate the rewards using simple interest formula: (Principal * Rate * Time) / 100
        uint256 rewards = (staker.stakedAmount * rewardRate * staker.stakingDuration) / (100 * 365 days);

        return rewards;
    }

    // Withdraw Function
    function withdraw() public {
        Staker storage staker = stakers[msg.sender];

        // Ensure the user is registered and has staked
        require(staker.isRegistered, "User is not registered.");
        require(staker.hasStaked, "No active stake.");

        // Ensure the staked Ether has not already been withdrawn
        require(!staker.isStakeWithdrawn, "Staked Ether has already been withdrawn.");

        // Calculate rewards
        uint256 rewards = calculateRewards(msg.sender);
        uint256 stakedAmount = staker.stakedAmount;

        // Check if the staking duration has ended
        if (block.timestamp < staker.stakingTimestamp + staker.stakingDuration) {
            // Early withdrawal: apply a 15% fee on the rewards
            uint256 fee = (rewards * earlyWithdrawalFeePercent) / 100;
            rewards -= fee;
        }

        // Update staker's status
        staker.isStakeWithdrawn = true;
        staker.hasStaked = false;

        // Transfer staked Ether and (remaining) rewards back to the user
        uint256 totalPayout = stakedAmount + rewards;
        staker.stakedAmount = 0; // Reset staked amount
        payable(msg.sender).transfer(totalPayout);

        // Emit Withdraw Event
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

    // Event declarations
    event Registered(address indexed user, uint256 preferredDuration);
    event Staked(address indexed user, uint256 amount, uint256 duration);
    event Withdrawn(address indexed user, uint256 stakedAmount, uint256 rewards);
}
