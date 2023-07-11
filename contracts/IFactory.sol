// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IFactory {
    function setFee(uint _fee) external;
    function swapFeeKeeper(address _token, uint256 _amount) external;
    function allPairsLength() external view returns (uint);
    function getPairAddress(address tokenA, address tokenB) external returns (address);
    function createPair(address tokenA, address tokenB) external returns (address);
    function setPoolLevel(address tokenA, address tokenB, uint _level) external;
    function createPool(address tokenA, address tokenB, uint _level) external returns (address pair);
    function createStaking(address _token) external returns(address staking);
    function getStakingPool(address _token) external returns(address);
}
