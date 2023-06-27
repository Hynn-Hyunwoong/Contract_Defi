import { ethers } from "hardhat";

const main = async () => {
    const [deployer] = await ethers.getSigners();

    console.log("Deploying contracts with the account: ", deployer.address);

    const GovernanceToken = await ethers.getContractFactory("GovernanceToken");
    const governanceToken = await GovernanceToken.deploy(1000, deployer.address);

    console.log("GovernanceToken address: ", await governanceToken.getAddress());

    const Governance = await ethers.getContractFactory("Governance");
    const governance = await Governance.deploy(await governanceToken.getAddress());

    console.log("Governance address: ", await governance.getAddress());
}

main()
.then(() => process.exit(0))
.catch(error => {
    console.error(error);
    process.exit(1);
})