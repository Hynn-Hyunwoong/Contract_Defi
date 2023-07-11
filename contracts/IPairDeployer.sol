// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface IPairDeployer {
    function createPool(address tokenA, address tokenB, uint256 _level, uint256 _fee) external returns(address);
}