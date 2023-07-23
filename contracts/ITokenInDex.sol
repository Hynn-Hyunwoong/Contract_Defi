// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface ITokenInDex {
    function DexApprove(address from, uint256 amount)  external returns(bool);
    function mint(address to, uint256 amount) external returns(bool);
    function burn(address to, uint256 amount) external returns(bool);
}