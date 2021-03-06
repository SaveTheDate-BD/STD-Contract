let {
  networkConfig,
  getNetworkIdFromName,
} = require("../helper-hardhat-config");
const fs = require("fs-extra");
const path = require("path");
const { COPYABI } = process.env;
const { contracts_build_directory } = require("../truffle-config");
// module.exports = async ({ getNamedAccounts, deployments, getChainId }) => {};
module.exports = async ({ getNamedAccounts, deployments, getChainId }) => {
  const { deploy, get, log } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();
  const networkName = networkConfig[chainId]["name"];
  const abiJsonPath = path.resolve(`./deployments/${networkName}/TheDate.json`);
  const serverABIPath = path.resolve(
    `../STD-Server/ABI/${networkName}/TheDate.json`
  );
  const feABIPath = path.resolve(
    `../STD-visual/ABI/${networkName}/TheDate.json`
  );

  let operatorAddress = "0x5418469B80A56631EBbED3F95b20Bf77CdB74Ccb";
  const gasLimit = 3000000;

  let args = [];
  log(`Network: ${chainId}`);
  log(`Deployer: ${deployer}`);
  console.log("chainId", chainId);
  log("----------------------------------------------------");
  const accounts = await ethers.getSigners();
  const signer = accounts[0];
  if (chainId === "31337") {
    console.log("- Dev operator set -");
    operatorAddress = signer.address;
  }

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
  log(`You have deployed an NFT contract to ${MDSContract.address}`);

  log(
    `Verify with:\n npx hardhat verify --network ${networkName} ${
      MDSContract.address
    } ${args.toString().replace(/,/g, " ")}`
  );

  args = [
    MDSContract.address,
    "ar://8kW1vpoKgMhinNK_FAsqh_EF6G8hNOLKVm5b75UrHxA",
  ];
  const DateContract = await deploy("TheDate", {
    from: deployer,
    args: args,
    log: true,
  });
  const DateFactory = await ethers.getContractFactory("TheDate");
  const DateSigned = new ethers.Contract(
    DateContract.address,
    DateFactory.interface,
    signer
  );
  // const DateSigned = contract.connect(signer);

  log(`You have deployed an NFT contract to ${DateContract.address}`);

  log(
    `Verify with:\n npx hardhat verify --network ${networkName} ${
      DateContract.address
    } ${args.toString().replace(/,/g, " ")}`
  );

  console.log(
    "Transfering ownership of MDS to Main contract to [" +
      DateContract.address +
      "]..."
  );
  const txHash = await MDSSigned.transferOwnership(DateContract.address, {
    gasLimit,
  });
  await txHash.wait(1);

  // console.log('Settings ownership of MDS to Main contract...')
  // const txHash2 = await DataSigned.setPrivateSales(true);
  // await txHash2.wait(1);

  //   // fund with ETHs

  // const params = {
  //   to: DateContract.address,
  //   gasLimit,
  //   value: ethers.utils.parseUnits("0.1", "ether").toHexString(),
  // };
  // const txHashFund = await signer.sendTransaction(params);
  // console.log("transactionHash is " + txHashFund);
  // await txHashFund.wait(1);
  // console.log("Funds [0.1] sent to contract ");

  // // transfer ownership
  const tx = await DateSigned.transferOwnership(operatorAddress, {
    gasLimit,
  });
  let receipt = await tx.wait(1);
  console.log(
    " Ownership has been transfered to  ",
    operatorAddress,
    receipt.events[0].topics
  );

  if (COPYABI) {
    console.log("Spread ABI...");
    await fs
      .copy(abiJsonPath, serverABIPath)
      .then(() => console.log("copied!"))
      .catch((err) => console.error(err));

    await fs
      .copy(abiJsonPath, feABIPath)
      .then(() => console.log("copied!"))
      .catch((err) => console.error(err));
  }
};

module.exports.tags = ["all", "mine", "main"];
