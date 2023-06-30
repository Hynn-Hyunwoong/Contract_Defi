// deploy.ts
import { ethers } from 'hardhat';
import { token } from '../typechain-types/@openzeppelin/contracts';

async function main() {
  // Get the ContractFactory and Signers here.
  const TokenPriceOracle = await ethers.getContractFactory("TokenPriceOracle");
  
  // Deploy the contract.
  const tokenPriceOracle = await TokenPriceOracle.deploy();
  
  console.log("TokenPriceOracle deployed to:", await tokenPriceOracle.getAddress());
  console.log("address", tokenPriceOracle.target)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
