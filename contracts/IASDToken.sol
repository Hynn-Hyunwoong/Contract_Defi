// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface IASDToken {
    function DexApprove(address from, uint256 amount)  external returns(bool);
    function mint(address to, uint256 amount) external;
    function burn(address to, uint256 amount) external;
}