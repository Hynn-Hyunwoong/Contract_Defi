import { HardhatUserConfig } from 'hardhat/config';
import '@nomicfoundation/hardhat-toolbox';
import "@nomicfoundation/hardhat-ethers";

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: '0.6.12',
      },
      {
        version: '0.8.9',
      },
    ],
  },
  networks: {
    hardhat: {
      forking: {
        // url: 'https://arbitrum-mainnet.infura.io/v3/5ea599f0ded84b0b9ad9b0dfcc1fb6acs',
        url: "https://goerli-rollup.arbitrum.io/rpc",
      },
      accounts: {
        mnemonic:
          'test test test test test test test test test test test junk',
        initialIndex: 0,
        count: 20,
        accountsBalance:
          '100000000000000000000000', // 100000 ETH
      },
      blockGasLimit: 300000000,
      gas: 20000000,
      gasPrice: 25000000000,

    },
    sepolia: {
      url: 'https://ethereum-sepolia.blockpi.network/v1/rpc/public',
      chainId: 11155111,
      accounts: [
        require('./privatekey.json')
          .privatekey,
      ],
      gas: 10000000,
      gasPrice: 1000000000,
    },
    baobab: {
      url: 'https://api.baobab.klaytn.net:8651',
      chainId: 1001,
      accounts: [
        require('./privatekey.json')
          .privatekey,
      ],
      gas: 20000000,
      gasPrice: 25000000000,
    },
    arbitrum: {
      url: 'https://arbitrum-goerli.publicnode.com',
      chainId: 421613,
      accounts: [
        require('./privatekey.json')
          .privatekey,
      ],
      gas: 20000000,
      gasPrice: 25000000000,
    },
  },
};

export default config;
