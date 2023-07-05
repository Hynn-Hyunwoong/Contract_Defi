// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface IStaking {
    function addStaking(address sender, address lpToken, uint amount, uint time) external returns(bool);
    function claimReward(address to, address _token, uint256 time) external;
    function forcedCancle(address to, address _token) external;
}