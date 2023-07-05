// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface ILPToken {
    function setLevel(uint _level) external;
    function getLevel(address sender) external returns(uint _level);
    function getList(address user) view external returns(uint256);
    function mint(address to, uint256 amount) external returns(bool);
    function burn(address to) external returns(bool);
}