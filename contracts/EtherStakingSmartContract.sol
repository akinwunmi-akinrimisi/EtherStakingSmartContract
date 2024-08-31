// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EtherStaking {

    // State Variables
    address public owner; // Owner Address
    uint256 public rewardRate30Days; // Reward Rate for 30 days
    uint256 public rewardRate90Days; // Reward Rate for 90 days
    uint256 public rewardRate1Year;  // Reward Rate for 1 year
    uint256 public totalStaked; // Total Staked Ether

    // Struct for Staker Information
    struct Staker {
        uint256 stakedAmount;       // The amount of Ether staked by the user
        uint256 stakingTimestamp;   // The timestamp when the Ether was staked
        uint256 stakingDuration;    // The selected staking duration (in days)
        uint256 rewards;            // The calculated rewards for the staker
        bool hasStaked;             // Whether the user has an active stake
        bool isRewardWithdrawn;     // Whether the rewards have been withdrawn
        bool isStakeWithdrawn;      // Whether the staked Ether has been withdrawn
    }

    // Mapping to store stakers' information
    mapping(address => Staker) public stakers;

    // Constructor to initialize contract
    constructor(uint256 _rewardRate30Days, uint256 _rewardRate90Days, uint256 _rewardRate1Year) payable {
        owner = msg.sender; // Set the owner of the contract to the deployer
        rewardRate30Days = _rewardRate30Days; // Initialize reward rate for 30 days
        rewardRate90Days = _rewardRate90Days; // Initialize reward rate for 90 days
        rewardRate1Year = _rewardRate1Year;   // Initialize reward rate for 1 year

        // Ensure the contract starts with a non-zero balance
        require(msg.value > 0, "Initial funding must be greater than zero.");
    }

    // Event declaration
    event Staked(address indexed user, uint256 amount, uint256 duration);



    
    // Stake Function
    function stake(uint256 _duration) public payable {
        //Validate Staking Amount
        require(msg.value > 0, "Staking amount must be greater than zero.");

        //Validate Staking Duration
        require(
            _duration == 30 days || _duration == 90 days || _duration == 365 days,
            "Invalid staking duration. Choose 30 days, 90 days, or 1 year."
        );

        //Check for Existing Active Stake
        require(!stakers[msg.sender].hasStaked, "Already have an active stake.");

        //Update Staking Information
        stakers[msg.sender] = Staker({
            stakedAmount: msg.value,
            stakingTimestamp: block.timestamp,
            stakingDuration: _duration,
            rewards: 0,
            hasStaked: true,
            isRewardWithdrawn: false,
            isStakeWithdrawn: false
        });

        // Update total staked Ether
        totalStaked += msg.value;

        // Emit Event
        emit Staked(msg.sender, msg.value, _duration);
    }

}
