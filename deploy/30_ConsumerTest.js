let {
  networkConfig,
  getNetworkIdFromName,
} = require("../helper-hardhat-config");

module.exports = async ({ getNamedAccounts, deployments, getChainId }) => {
  // const DECIMALS = "18";

  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();

  linkTokenAddress = networkConfig[chainId]["linkToken"];
  console.log("deployer", chainId, deployer);
  // If we are on a local development network, we need to deploy mocks!
  const args = [];
  const Oracle = await deploy("EAConsumer", {
    from: deployer,
    args,
    log: true,
  });
  log(`You have deployed an EAConsumer contract to ${Oracle.address}`);
  const networkName = networkConfig[chainId]["name"];
  log(
    `Verify with:\n npx hardhat verify --network ${networkName} ${
      Oracle.address
    } ${args.toString().replace(/,/g, " ")}`
  );

  // const OracleContract = await ethers.getContractFactory("Oracle");
  // const accounts = await hre.ethers.getSigners();
  // const signer = accounts[0];
  // const oracle = new ethers.Contract(
  //   Oracle.address,
  //   OracleContract.interface,
  //   signer
  // );
  // log(`addding the node [${nodeAddress}]`);
  // const tx = await oracle.setFulfillmentPermission(nodeAddress, true);
  // log("Local network detected! Deploying mocks...");
  // const linkToken = await deploy("LinkToken", { from: deployer, log: true });
  // await deploy("EthUsdAggregator", {
  //   contract: "MockV3Aggregator",
  //   from: deployer,
  //   log: true,
  //   args: [DECIMALS, INITIAL_PRICE],
  // });
  // await deploy("VRFCoordinatorMock", {
  //   from: deployer,
  //   log: true,
  //   args: [linkToken.address],
  // });
  // log("Mocks Deployed!");
  // log("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
  // log(
  //   "You are deploying to a local network, you'll need a local network running to interact"
  // );
  // log(
  //   "Please run `npx hardhat console` to interact with the deployed smart contracts!"
  // );
  // log("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
};
module.exports.tags = ["test"];