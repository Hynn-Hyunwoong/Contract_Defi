// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface ITokenBank {
    function saveTokne(address sender, uint256 amount) external;
    
}