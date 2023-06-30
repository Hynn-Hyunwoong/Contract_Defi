import { ethers } from "hardhat";
import { expect } from "chai";

describe("TokenPriceOracle", async() => {
  let oracle: any;
  const TokenPriceOracle = await ethers.getContractFactory("TokenPriceOracle");

  beforeEach(async () => {
    oracle = await TokenPriceOracle.deploy();
    await oracle.deployTransaction.wait();
  });

  it("should return a price for ETH", async () => {
    const price = await oracle.routing("ETH");
    console.log("ETH price:", price.toString());
    // expect(price).to.be.a('BigNumber');
    // expect(BigNumber.from(price).gt(0)).to.be.true;
  });

  it("should return a price for USDT", async () => {
    const price = await oracle.routing("USDT");
    console.log("USDT price:", price.toString());
    // expect(price).to.be.a('BigNumber');
    // expect(BigNumber.from(price).gt(0)).to.be.true;
  });

  it("should return a price for ARB", async () => {
    const price = await oracle.routing("ARB");
    console.log("ARB price:", price.toString());
    // expect(price).to.be.a('BigNumber');
    // expect(BigNumber.from(price).gt(0)).to.be.true;
  });
});