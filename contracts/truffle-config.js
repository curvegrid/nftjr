// pull in environment variables, potentially from a .env file
require('dotenv').config()

const privateKey = process.env.NFTJR_DEPLOYER_PRIVATE_KEY;
const networkID = process.env.NFTJR_NETWORK_ID;

// For using MultiBaas proxy
const { Provider } = require("truffle-multibaas-plugin");
const MultiBaasDeploymentID = process.env.NFTJR_MULTIBAAS_DEPLOYMENT_ID;

module.exports = {
  networks: {
    development: {
      provider: new Provider(privateKey, MultiBaasDeploymentID),
      network_id: networkID,
    },
    gas: 8000000, // gas limit for each transaction (default: ~6700000)
    gasPrice: 1, // 1 wei (default: 100 gwei)
  },

  // Configure your compilers
  compilers: {
    solc: {
      version: "0.6.8",
      settings: {
        // this is critical otherwise most of the contracts will exceed the 24 KB limit
        // on smart contract size
        optimizer: {
          enabled: true,
          runs: 200,
        },
      },
    },
  },

  // MultiBaas deployment
  multibaasDeployer: {
    apiKeySource: "env",
    deploymentID: MultiBaasDeploymentID,
    allowUpdateAddress: ["development"],
  },
};
