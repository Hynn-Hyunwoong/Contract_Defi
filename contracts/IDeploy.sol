// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IDeploy {
    function deployPair(uint _level, address _owner) external returns(address pair);
    function deployStaking(address owner, address token) external returns(address staking);
}