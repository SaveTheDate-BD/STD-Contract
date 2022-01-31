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
const { contracts_build_directory } = require("../truffle-config");

const todayIsDayFromEpoch = Math.floor(
  new Date().getTime() / (1000 * 60 * 60 * 24)
);
const currentDay = 5000000 + todayIsDayFromEpoch;
const cheapDay = currentDay - 8;
const expensiveDay = currentDay - 7;

let priceOfTheDay;
skip
  .if(!developmentChains.includes(network.name))
  .describe("STD Unit Tests", async function () {
    let std;
    let signer;
    before(async () => {
      console.log("A1");
      const accounts = await hre.ethers.getSigners();
      signer = accounts[0];
      await deployments.fixture(["all"]);
      console.log("A2");
      const STD = await deployments.get("TheDate");
      std = await ethers.getContractAt("TheDate", STD.address);
      const signed = std.connect(signer);
      await std.setPublicSales(true);
      console.log("A3");
    });

    // it("should return the correct current day", async () => {
    //   cd = await std.getCurrentDay();
    //   console.log("__ price: ", cd.toString());
    //   expect(cd.toString()).to.equal(String(currentDay)); //1
    // });

    it("should return the correct Price for high", async () => {
      priceOfTheDay = await std.getAvailability(expensiveDay);
      console.log("__ price: ", priceOfTheDay.toString());
      expect(priceOfTheDay.toString()).to.equal("1000000000000000000"); //1
    });

    it("should return the correct Price for past", async () => {
      priceOfTheDay = await std.getAvailability(cheapDay);
      console.log("__ price: ", priceOfTheDay.toString());
      expect(priceOfTheDay.toString()).to.equal("10000000000000000"); //0.01
    });

    it("should mint public", async () => {
      let tx = await std.mint(cheapDay, { value: priceOfTheDay });
      reciept = await tx.wait(1);
      expect(true).to.be.true;
    });

    it("get meta", async () => {
      let meta = await std.tokenURI(cheapDay);
      console.log("meta", meta);
      expect(true).to.be.true;
    });

    it("update meta", async () => {
      let meta = await std.updateMetadata(
        cheapDay,
        "https://www.ya42.ru",
        false
      );
      console.log("meta updated");
      await meta.wait(1);

      expect(true).to.be.true;
    });

    it("get meta updated", async () => {
      let meta = await std.tokenURI(cheapDay);
      console.log("meta updated:", meta);
      expect(true).to.be.true;
    });

    // it(" Price for past after mint for existing", async () => {
    //   priceOfTheDay = await std.getAvailability(cheapDay);
    //   console.log("__ price: ", priceOfTheDay.toNumber());
    //   expect(priceOfTheDay.toNumber()).to.equal(0);
    // });
    // it(" Price for past after mint for past", async () => {
    //   priceOfTheDay = await std.getAvailability(cheapDay - 1);
    //   console.log("__ price: ", priceOfTheDay.toNumber());
    //   expect(priceOfTheDay.toNumber()).to.equal(110);
    // });

    // it("expensive day no change after mint", async () => {
    //   priceOfTheDay = await std.getAvailability(expensiveDay);
    //   console.log("__ price: ", priceOfTheDay.toNumber());
    //   expect(priceOfTheDay.toNumber()).to.equal(100 * 100 * 100);
    // });
  });
