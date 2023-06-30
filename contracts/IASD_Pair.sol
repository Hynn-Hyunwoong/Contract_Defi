// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
interface IASD_SwapPair {
    struct Ratio{
        address tokenA;
        uint ratioA;
        address tokenB;
        uint ratioB;
    }
    function getFee() external view returns (uint256);
    function setFee(uint256 _fee) external;
    function getRatio() external view returns (Ratio memory);
    function setRatio() external;
    function getLiquidity(address token, address provider) external view returns (uint256);
    function getPoolAmount(address _token) external view returns (uint256);
    function initialize(address _tokenA, address _tokenB) external;
    function addLiquidity(address _tokenA, address _tokenB, uint256 _amountA, uint256 _amountB, address from) external payable;
    function removeLiquidity(address from) external;
    function swap(address _token, uint256 amountIn, address sender) external returns (uint256);
}
