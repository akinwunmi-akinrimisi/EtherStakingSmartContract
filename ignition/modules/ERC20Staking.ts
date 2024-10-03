const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("ERC20StakingModule", (m) => {
  const eRC20Staking = m.contract(
    "ERC20Staking",
    ["0x6103EEb7370076C1C59aB7C073C2ed6C6D9528FE"],
    {}
  );

  return { eRC20Staking };
});

// Deployed Addresses

// EtherStakingModule#EtherStaking - 0x6103EEb7370076C1C59aB7C073C2ed6C6D9528FE
// ERC20StakingModule#ERC20Staking - 0x926CB8C0531B8da1af28feEA5626613850099a47
