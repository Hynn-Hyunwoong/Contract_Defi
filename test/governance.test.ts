import { ethers } from 'hardhat';
import { expect } from 'chai';

describe('Governance', () => {
  let GovernanceToken: any ;
  let Token: any;
  let Governance: any;

  beforeEach(async () => {
    // Deploy contracts
    const GovernanceTokenFactory = await ethers.getContractFactory('GovernanceToken');
    GovernanceToken = await GovernanceTokenFactory.deploy();

    const TokenFactory = await ethers.getContractFactory('Token');
    Token = await TokenFactory.deploy();

    const GovernanceFactory = await ethers.getContractFactory('Governance');
    Governance = await GovernanceFactory.deploy(GovernanceToken.address, Token.address);

  });

  it('should be able to propose a topic', async () => {
    await GovernanceToken.mint(10);  

    const initialTopicCount = await Governance.nextTopicId();
    expect(initialTopicCount).to.equal(0);

    await Governance.connect().proposeTopic(0, '0xAnotherAddress', 1000);  

    const finalTopicCount = await Governance.nextTopicId();
    expect(finalTopicCount).to.equal(1);
  });

});
