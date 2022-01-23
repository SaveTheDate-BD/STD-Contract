let {
  networkConfig,
  getNetworkIdFromName,
} = require("../helper-hardhat-config");
const fs = require("fs");
// module.exports = async ({ getNamedAccounts, deployments, getChainId }) => {};
module.exports = async ({ getNamedAccounts, deployments, getChainId }) => {
  const { deploy, get, log } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();

  args = [];
  log(`Network: ${chainId}`);
  log(`Deployer: ${deployer}`);
  log("----------------------------------------------------");

  const accounts = await ethers.getSigners();
  const signer = accounts[0];

  const MDSContract = await deploy("MetaDataStorage", {
    from: deployer,
    args: args,
    log: true,
  });
  const MDSFactory = await ethers.getContractFactory("MetaDataStorage");
  const MDSSigned = new ethers.Contract(
    MDSContract.address,
    MDSFactory.interface,
    signer
  );

  const DateContract = await deploy("TheDate", {
    from: deployer,
    args: [MDSContract.address],
    log: true,
  });
  const DataFactory = await ethers.getContractFactory("TheDate");
  const DataSigned = new ethers.Contract(
    DateContract.address,
    DataFactory.interface,
    signer
  );
  // const DateSigned = contract.connect(signer);

  log(`You have deployed an NFT contract to ${DateContract.address}`);
  const networkName = networkConfig[chainId]["name"];
  log(
    `Verify with:\n npx hardhat verify --network ${networkName} ${
      DateContract.address
    } ${args.toString().replace(/,/g, " ")}`
  );

  const txHash = await MDSSigned.transferOwnership(DateContract.address);
  await txHash.wait(1);

  const txHash2 = await DataSigned.setPrivateSales(true);
  await txHash2.wait(1);

  //   // fund with ETHs

  // const params = {
  //   to: Contract.address,
  //   value: ethers.utils.parseUnits("0.1", "ether").toHexString(),
  // };
  // const txHash = await signer.sendTransaction(params);
  // console.log("transactionHash is " + txHash);
  // await txHash.wait(1);
  // console.log("Funds [0.1] sent to contract ");

  // // transfer ownership
  // const tx = await contract.transferOwnership(operatorAddress);
  // let receipt = await tx.wait(1);
  // console.log(" >> ", receipt.events[0].topics);

  // log("Let's create an NFT now!");
  //   tx = await randomSVG.dropMint(7000, { gasLimit: 30000000 });
  //   let receipt = await tx.wait(1);
  //   console.log(" >> ", receipt.events[0].topics);
  //   let tokenId = "not yet "; //receipt.events[3].topics[2];
  //   log(`You've made your NFT! This is number ${tokenId}`);
};

module.exports.tags = ["all", "mine", "main"];
