import {ethers} from 'hardhat';

const main = async () => {
    const [owner] = await ethers.getSigners();

    const tokenFactory = await ethers.getContractFactory("ASDToken");
    const token = await tokenFactory.deploy();

    console.log("ASDToken deployed to:", await token.getAddress());
    console.log("ASDToken deployed by:", owner.address);
    console.log("ASDToken deployed by:", await token.minter());
}

main()
.then(() => process.exit(0))
.catch(error => {
    console.error(error);
    process.exit(1);
})