const HDWalletProvider = require("@truffle/hdwallet-provider");
require("dotenv").config(); // Load .env file

module.exports = {
  networks: {
    // For Ganache, your personal blockchain
    development: {
      host: "127.0.0.1", // Localhost (default: none)
      port: 8545, // Standard Ethereum port
      network_id: "*", // Any network (default: none)
    },
  },
  contracts_directory: "./contracts/", // Path to smart contracts
  contracts_build_directory: "./src/abis/", // Path to ABIs
  compilers: {
    solc: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
};
