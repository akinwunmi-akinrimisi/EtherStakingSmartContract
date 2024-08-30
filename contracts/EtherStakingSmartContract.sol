// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;


contract EtherStakingSmartContract{
    uint256 time_01 = 30 days;
    uint256 time_02 = 90 days;
    uint256 time_03 = 365 days;

    uint256 rate_01 = 3/100;
    uint256 rate_02 = 4/100;
    uint256 rate_03 = 5/100;

    // details of stakers
    struct stakers{
        address payable userAddress;
        uint256 stakingAmount;
        uint256 stakingDuration;
    }

    stakers[] public listOfStakers;
    mapping(address => uint) stakingAmount;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner(){
        require(owner == msg.sender, "you don't have permission");
        _;
    }



// function to register a new staker
// user needs to supply: amount to stake, duration, address to receive profit and principal
    function registerStaker(address _userAddress, uint256 _amount, uint256 _stakingDuration) external {
        stakers memory newStaker = stakers(_userAddress, _amount, stakingDuration);
        listOfStakers.push(newStaker);
    }

    // function stakeEther(type name) external {
        
    // }

}