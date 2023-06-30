// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IFactory {
    function swapFeeKeeper(address _token, uint256 _amount) external;
    function getPairAddress(address tokenA, address tokenB) external returns (address);
    function createPair(address tokenA, address tokenB) external returns (address);
    function allPairsLength() external view returns (uint);
}
