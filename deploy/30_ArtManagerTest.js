let {
  networkConfig,
  getNetworkIdFromName,
} = require("../helper-hardhat-config");

module.exports = async ({ getNamedAccounts, deployments, getChainId }) => {
  // const DECIMALS = "18";
  // const { deploy, log } = deployments;
  // const { deployer } = await getNamedAccounts();
  // const chainId = await getChainId();
  // const args = [];
  // const ArtManager = await deploy("ArtManager", {
  //   from: deployer,
  //   args,
  //   log: true,
  // });
  // log(`You have deployed an ArtManager contract to ${ArtManager.address}`);
  // const networkName = networkConfig[chainId]["name"];
  // log(
  //   `Verify with:\n npx hardhat verify --network ${networkName} ${
  //     ArtManager.address
  //   } ${args.toString().replace(/,/g, " ")}`
  // );
};
module.exports.tags = ["test"];
