// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "./IStakingDeployer.sol";
import "./Staking.sol";
import "./ASDstaking.sol";

contract StakingDeployer is IStakingDeployer{
    address public owner;


    function setOwner(address _owner) public {
        owner = _owner;
    }

    function  LpStakingDeploy(address _token) public returns(address){
        require( msg.sender == owner, "No Authority");
        LpStaking staking = new LpStaking(owner, _token);

        return address(staking);
    }

    function ASDstakingDeploy(address _token) public returns(address){
        require( msg.sender == owner, "No Authority");
        ASDstaking staking = new ASDstaking(owner, _token);

        return address(staking);
    }
   
}