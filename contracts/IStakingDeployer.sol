// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface IStakingDeployer{
    function setOwner(address _owner) external;
    function stakingDeploy(address _token) external returns(address);
   
}