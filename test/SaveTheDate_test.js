const { expect } = require("chai");
const chai = require("chai");
const BN = require("bn.js");
const skipIf = require("mocha-skip-if");
chai.use(require("chai-bn")(BN));
const fs = require("fs");
const { deployments, getChainId } = require("hardhat");
const {
  networkConfig,
  developmentChains,
} = require("../helper-hardhat-config");

const todayIsDayFromEpoch = Math.floor(
  (new Date().getTime() / 1000) * 60 * 60 * 24
);
const cheapDay = 5000000 + todayIsDayFromEpoch - 7;
const expensiveDay = 5000000 + todayIsDayFromEpoch - 8;

let priceOfTheDay;
skip
  .if(!developmentChains.includes(network.name))
  .describe("STD Unit Tests", async function () {
    let std;
    let signer;
    before(async () => {
      const accounts = await hre.ethers.getSigners();
      signer = accounts[0];
      await deployments.fixture(["all"]);
      const STD = await deployments.get("TheDate");
      std = await ethers.getContractAt("TheDate", STD.address);
    });

    it("should return the correct Price for high", async () => {
      priceOfTheDay = await std.getAvailability(expensiveDay);
      console.log("__ price: ", priceOfTheDay.toNumber());
      expect(priceOfTheDay.toNumber()).to.equal(10 ** 16); //0.01
    });

    it("should return the correct Price for past", async () => {
      priceOfTheDay = await std.getAvailability(cheapDay);
      console.log("__ price: ", priceOfTheDay.toNumber());
      expect(priceOfTheDay.toNumber()).to.equal(10 ** 18);
    });

    // it("should mint", async () => {
    //   let tx = await std.create(remarkableDay, { value: priceOfTheDay });
    //   reciept = await tx.wait(1);
    //   expect(true).to.be.true;
    // });

    // it("get meta", async () => {
    //   let meta = await std.tokenURI(remarkableDay);
    //   // console.log("meta", meta);
    //   expect(true).to.be.true;
    // });

    // it(" Price for past after mint for existing", async () => {
    //   priceOfTheDay = await std.getAvailability(remarkableDay);
    //   console.log("__ price: ", priceOfTheDay.toNumber());
    //   expect(priceOfTheDay.toNumber()).to.equal(0);
    // });
    // it(" Price for past after mint for past", async () => {
    //   priceOfTheDay = await std.getAvailability(remarkableDay - 1);
    //   console.log("__ price: ", priceOfTheDay.toNumber());
    //   expect(priceOfTheDay.toNumber()).to.equal(110);
    // });

    // it("expensive day no change after mint", async () => {
    //   priceOfTheDay = await std.getAvailability(expensiveDay);
    //   console.log("__ price: ", priceOfTheDay.toNumber());
    //   expect(priceOfTheDay.toNumber()).to.equal(100 * 100 * 100);
    // });
  });
