// const { expect } = require("chai");
// const chai = require("chai");
// const BN = require("bn.js");
// const skipIf = require("mocha-skip-if");
// chai.use(require("chai-bn")(BN));
// const fs = require("fs");
// const { deployments, getChainId, deploy } = require("hardhat");
// const {
//   networkConfig,
//   developmentChains,
// } = require("../helper-hardhat-config");

// const tokenId = 5000000;
// let priceOfTheDay;
// skip
//   .if(!developmentChains.includes(network.name))
//   .describe("ArtManager Unit Tests", async function () {
//     let ctrct;
//     let signer;
//     let user;
//     before(async () => {
//       const accounts = await hre.ethers.getSigners();
//       signer = accounts[0];
//       user = accounts[1];

//       const CTRCT = await ethers.getContractFactory("ArtManager");

//       const tx = await CTRCT.deploy();

//       ctrct = await ethers.getContractAt("ArtManager", tx.address);
//     });

//     it("should update", async () => {
//       await ctrct._updateArt(tokenId, "someurl", user.address);
//       const currentArt = await ctrct.getCurrentArt(tokenId);

//       console.log("__ CA: ", currentArt);
//       // expect(priceOfTheDay.toNumber()).to.equal(100 * 100 * 100);
//     });

//     it("should update2", async () => {
//       await ctrct._updateArt(tokenId, "someurl2", user.address);
//       await ctrct._updateArt(tokenId, "someurl3", user.address);
//       const currentArt = await ctrct.getCurrentArt(tokenId);

//       console.log("__ CA: ", currentArt);
//       // expect(priceOfTheDay.toNumber()).to.equal(100 * 100 * 100);
//     });

//     it("should be ok after delete end", async () => {
//       await ctrct._removeArt(tokenId, "someurl3");
//       const currentArt = await ctrct.getCurrentArt(tokenId);

//       console.log("__ CA: ", currentArt);
//       expect(currentArt.url).to.equal("someurl2");
//     });

//     it("should be ok after delete first", async () => {
//       await ctrct._removeArt(tokenId, "someurl");
//       const currentArt = await ctrct.getCurrentArt(tokenId);

//       console.log("__ CA: ", currentArt);
//       // expect(priceOfTheDay.toNumber()).to.equal(100 * 100 * 100);
//       expect(currentArt.url).to.equal("someurl2");
//     });
//     it("should be ok after delete non existed", async () => {
//       await ctrct._removeArt(tokenId, "someurl3");
//       const currentArt = await ctrct.getCurrentArt(tokenId);

//       console.log("__ CA: ", currentArt);
//       // expect(priceOfTheDay.toNumber()).to.equal(100 * 100 * 100);
//       expect(currentArt.url).to.equal("someurl2");
//     });

//     it("should be ok after delete the last", async () => {
//       await ctrct._removeArt(tokenId, "someurl2");
//       const currentArt = await ctrct.getCurrentArt(tokenId);

//       console.log("__ CA: ", currentArt);
//       // expect(priceOfTheDay.toNumber()).to.equal(100 * 100 * 100);
//       expect(currentArt.url).to.equal("");
//     });
//   });
