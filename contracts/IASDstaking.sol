// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface IASDStaking {
    function addStaking(address sender, address asdToken, uint amount, uint time, uint256 serv) external returns(bool);
    function claimReward(address to, uint256 amount, uint256 serv) external;
    function removeStaking(address sender, address _token, uint256 time) external;
}