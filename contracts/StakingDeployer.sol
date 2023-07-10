// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "./IStakingDeployer.sol";
import "./Staking.sol";

contract StakingDeployer is IStakingDeployer{
    address public owner;


    function setOwner(address _owner) public {
        owner = _owner;
    }

    function  stakingDeploy(address _token) public returns(address){
        require( msg.sender == owner, "No Authority");
        Staking staking = new Staking(owner, _token);

        return address(staking);
    }
   
}