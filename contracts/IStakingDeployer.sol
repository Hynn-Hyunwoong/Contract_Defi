// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface IStakingDeployer{
    function setOwner(address _owner) external;
    function LpStakingDeploy(address _token) external returns(address);
   
}