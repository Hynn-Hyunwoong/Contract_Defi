// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./ILPToken.sol";
import "./IStaking.sol";

contract Staking is IStaking{
    // uint public month = 30 days;
    uint public totalAmount;
    address public dropToken;
    address public owner;

    mapping(address => mapping(address => uint)) stakingList; // tokenAddress => sender => amount
    mapping(address => uint256) private period; // sender => timestamp 스테이킹 기간

    constructor(address _owner, address _dropToken){
        owner = _owner;
        dropToken = _dropToken;
    }

    function addStaking(address sender, address lpToken, uint amount, uint time) public override returns(bool){
        totalAmount += amount;
        period[sender] = time;
        stakingList[lpToken][sender] = amount;
        IERC20(lpToken).approve(address(this), amount);
        IERC20(lpToken).transferFrom(sender, address(this), amount);

        // period[sender] = block.timestamp + time * month;
        return true;
    }

    function removeStaking(address sender, address _token) private {
        delete period[sender]; 
        delete stakingList[sender][_token];
    }

    function claimReward(address to, address _token, uint256 time) public{
        require(time > period[to],"Not Enough Time");
        removeStaking(to, _token);
    }

    function forcedCancle(address to, address _token) public override {
        require(msg.sender == owner, "No Authorized");
        removeStaking(to, _token);
    }
}