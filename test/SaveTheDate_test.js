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
const othersArtPrice = web3.utils.toWei("0.5", "ether");
const myArtPrice = web3.utils.toWei("0.1", "ether");
const testCollection = "0xF44B9b01E5205437CE7Bc3D43CEd3C7C1346fc20";
const testArtIds = [60, 42, 6];
const defaultMetadata =
  '{"name":"BigDay [Minting...]", "description":"Minting in progress. Please, stand by."}';

let priceOfTheDay;
let priceOfArt;
skip
  .if(!developmentChains.includes(network.name))
  .describe("STD Unit Tests", async function () {
    let std;
    let signer;
    before(async () => {
      console.log("A1");
      // const accounts = await hre.ethers.getSigners();
      // signer = accounts[0];
      const [owner] = await ethers.getSigners();
      signer = owner;
      console.log("A1", signer.address);
      await deployments.fixture(["all"]);
      const STD = await deployments.get("TheDate");
      std = await ethers.getContractAt("TheDate", STD.address);
      const signed = std.connect(signer);
    });

    //
    // PUBLIC SALES
    //
    describe("Public sales", function () {
      it("should be closed to open sales", async () => {
        const cd = await std.isPublicSalesOpen();
        expect(cd).to.equal(false); //1
      });

      it("should be able to setopen sales", async () => {
        await std.setPublicSales(true);
        expect(true).to.be.true;
      });

      it("should be opened to open sales", async () => {
        const cd = await std.isPublicSalesOpen();
        expect(cd).to.equal(true); //1
      });
    });

    //
    // PRICES CHECK
    //
    describe("Prices check. Initial", function () {
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

      it("get art price others", async () => {
        priceOfArt = await std.getArtPrice(testCollection, testArtIds[0]);
        console.log("meta", priceOfArt);
        expect(meta).to.equal(othersArtPrice);
      });

      // it("get art price", async () => {
      //   priceOfArt = await std.getArtPrice(testCollection, testArtIds[0]);
      //   console.log("meta", priceOfArt);
      //   expect(meta).to.equal(othersArtPrice);
      // });
    });

    //
    // Minting
    //
    describe("Minting", function () {
      it("should mint public", async () => {
        let tx = await std.mint(cheapDay, { value: priceOfTheDay });
        reciept = await tx.wait(1);
        expect(true).to.be.true;
      });
    });

    //
    // Meta
    //
    describe("Metadata and art. 1", function () {
      it("get meta", async () => {
        let meta = await std.tokenURI(cheapDay);
        console.log("meta", meta);
        expect(meta).to.equal(defaultMetadata);
      });

      it("set art", async () => {
        await std.setArt(cheapDay, testCollection, testArtIds[0], {
          value: priceOfArt,
        });
        expect(true).to.be.true;
      });

      it("update meta", async () => {
        let meta = await std.updateMetadata(cheapDay, "https://www.ya60.ru");
        console.log("meta updated");
        // await meta.wait(1);
        expect(true).to.be.true;
      });

      it("get meta updated", async () => {
        let meta = await std.tokenURI(cheapDay);
        console.log("meta updated:", meta);
        expect(meta).to.equal("https://www.ya60.ru");
      });

      it("get history", async () => {
        let history = await std.getArtHistory(cheapDay);
        console.log("history:", history);
        expect(true).to.be.true;
      });
    });
  });
