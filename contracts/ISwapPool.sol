// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
interface ISwapPool {
    function setLevel(uint _level) external;
    function getLevel() view external returns(uint);
    function getFee() external view returns (uint256);
    function setFee(uint256 feeValue) external;
    function getLpAmount(address sender) external returns(uint256);
    function getLiquidity(address token, address provider) external view returns (uint);
    function getPoolAmount(address _token) external view returns (uint);
    function initialize(address _tokenA, address _tokenB) external;
    function addLiquidity(address _tokenA, address _tokenB, uint256 _amountA, uint256 _amountB, address from) external;
    function removeLiquidity(address from) external;
    function swap(address _swap, address _swapped, uint256 amountIn, address sender) external returns (uint256);
}
