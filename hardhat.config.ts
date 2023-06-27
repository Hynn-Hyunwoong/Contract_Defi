import { HardhatUserConfig } from 'hardhat/config';
import '@nomicfoundation/hardhat-toolbox';

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.6.2"
      },
      {
        version: "0.8.9"
      },
    ]
  },
  networks: {
    hardhat: {
      forking: {
        url: 'https://arb1.arbitrum.io/rpc',
      },
      accounts: {
        mnemonic: 'test test test test test test test test test test test junk',
        initialIndex: 0,
        count: 20,
        accountsBalance: '1000000000000000000', // 1 ETH
      },
      gas: 1000000,
      gasPrice: 20000000000,
    },
    sepolia: {
      url: 'https://ethereum-sepolia.blockpi.network/v1/rpc/public',
      chainId: 11155111,
      accounts: [
        require('./privatekey.json').privatekey,
        require('./privatekey.json').privatekey2,
      ],
      gas: 1000000,
      gasPrice: 20000000000,
    },
    baobab: {
      url: 'https://api.baobab.klaytn.net:8651',
      chainId: 1001,
      accounts: [
        require('./privatekey.json').privatekey,
        require('./privatekey.json').privatekey2,
      ],
      gas: 1000000,
      gasPrice: 20000000000,
    },
    arbitrum: {
      url: 'https://arbitrum-goerli.publicnode.com',
      chainId: 421613,
      accounts: [
        require('./privatekey.json').privatekey,
        require('./privatekey.json').privatekey2,
      ],
      gas: 1000000,
      gasPrice: 20000000000,
    },
  },
};

export default config;
