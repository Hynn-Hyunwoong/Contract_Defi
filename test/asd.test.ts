import { ethers } from "hardhat";
// import { ethers } from "ethers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { loadFixture, time } from "@nomicfoundation/hardhat-network-helpers";

const toEther = (amount : number, unit = "ether") => ethers.parseUnits(amount.toString(), unit);
const fromEther = (amount : number, unit = "ether") => ethers.formatUnits(amount, unit);

describe("ASDToken", () => {
    
    async function inittest () {
        const [owner, user] = await ethers.getSigners();
        const tokenFactory = await ethers.getContractFactory("ASDToken");
        const token = await tokenFactory.deploy();
        return {token, owner, user};
    }

    describe("Deployment", async () => {
        it.only("verification metadata", async ()=>{
            const {token, owner} = await loadFixture(inittest);     
            console.log('token address',await token.getAddress())
            console.log('owner address',owner.address)     
            console.log ('minter', await token.minter())
            expect(await token.minter()).to.equal(owner.address);
        })
    })

    describe("Mint", async () => {
        it("verify can mint by minter", async ()=>{})
        it("verify exact amount", async ()=>{})
    })
})