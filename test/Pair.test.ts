import { ethers } from "hardhat";
import { Contract, ContractFactory } from "ethers";
import { expect } from "chai"

describe("ASD_SwapPair", () => {
  let swapPair: Contract;
  let tokenA: string;
  let tokenB: string;

  beforeEach(async () => {
    const SwapPairFactory: ContractFactory = await ethers.getContractFactory("ASD_SwapPair");
    swapPair = await SwapPairFactory.deploy();
    await swapPair.deployed();

    tokenA = "0x123"; // 임의의 토큰 A 주소
    tokenB = "0x456"; // 임의의 토큰 B 주소

    await swapPair.setPairTokens(tokenA, tokenB);
  });

  it("should add liquidity", async () => {
    const amountA = 100;
    const amountB = 200;

    await swapPair.addLiquidity(tokenA, tokenB, amountA, amountB);

    const tokenABalance = await swapPair.getTokenABalance(tokenA, ethers.constants.AddressZero);
    const tokenBBalance = await swapPair.getTokenBBalance(tokenB, ethers.constants.AddressZero);

    expect(tokenABalance).to.equal(amountA);
    expect(tokenBBalance).to.equal(amountB);
  });

  it("should swap tokens", async () => {
    const amountA = 100;
    const amountB = 200;

    await swapPair.addLiquidity(tokenA, tokenB, amountA, amountB);

    const initialBalanceA = await ethers.provider.getBalance(tokenA);
    const initialBalanceB = await ethers.provider.getBalance(tokenB);

    await swapPair.swap(tokenA, 50, tokenB, 0);

    const finalBalanceA = await ethers.provider.getBalance(tokenA);
    const finalBalanceB = await ethers.provider.getBalance(tokenB);

    expect(finalBalanceA).to.equal(initialBalanceA.sub(50));
    expect(finalBalanceB).to.equal(initialBalanceB.add(50));
  });
});
