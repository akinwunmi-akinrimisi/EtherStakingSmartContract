const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("EtherStakingModule", (m) => {
  const etherStaking = m.contract("EtherStaking", [], {});

  return { etherStaking };
});

// deployed address: 0x6103EEb7370076C1C59aB7C073C2ed6C6D9528FE
