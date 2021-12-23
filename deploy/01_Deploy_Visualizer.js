let { networkConfig } = require("../helper-hardhat-config");
const fs = require("fs");

module.exports = async ({ getNamedAccounts, deployments, getChainId }) => {
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();

  log("----------------------------------------------------");
  const SVGNFT = await deploy("SaveDateVisualiser", {
    from: deployer,
    log: true,
  });
  log(`You have deployed an NFT contract to ${SVGNFT.address}`);
  const svgNFTContract = await ethers.getContractFactory("SaveDateVisualiser");
  const accounts = await hre.ethers.getSigners();
  const signer = accounts[0];
  const svgNFT = new ethers.Contract(
    SVGNFT.address,
    svgNFTContract.interface,
    signer
  );
  const networkName = networkConfig[chainId]["name"];

  log(
    `Verify with:\n npx hardhat verify --network ${networkName} ${svgNFT.address}`
  );
};

module.exports.tags = ["all", "vis"];
