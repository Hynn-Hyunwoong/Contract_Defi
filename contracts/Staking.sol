// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./ILPToken.sol";
import "./IStaking.sol";
import "./ISwapPool.sol";
import "./ITokenInDex.sol";

contract LpStaking is IStaking{
    uint public totalAmount;
    address public dropToken;
    address public owner;
    uint256[] public several = [0,100,120,150];
    mapping(address => mapping(address => uint)) stakingList; // tokenAddress => sender => amount
    mapping(address => uint256) private period; // sender => timestamp 스테이킹 기간

    constructor(address _owner, address _dropToken){
        owner = _owner;
        dropToken = _dropToken;
    }

    function addStaking(address sender, address lpToken, uint256 amount, uint256 time) public override returns(bool){
        totalAmount += amount;
        period[sender] = time;
        stakingList[lpToken][sender] = amount;
        ILPToken(lpToken).DexApprove(sender, amount);
        IERC20(lpToken).transferFrom(sender, address(this), amount);
        claimReward(sender, lpToken);
        return true;
    }

    function removeStaking(address sender, address _token, uint256 time) public {
        require(time > period[sender],"Not Enough Time");
        uint256 amount = stakingList[sender][_token];
        IERC20(_token).transfer(sender, amount);
        delete period[sender]; 
        delete stakingList[sender][_token];

    }

    function claimReward(address to, address _token) public{
        // reward 계산
        uint256 reward = getReward(to, _token);
        ITokenInDex(dropToken).mint(to, reward);
    }

    function getReward(address to, address _token) view private returns(uint256 reward){
        address pool = ILPToken(_token).getOwner();
        uint256 amount = ILPToken(_token).getList(to);
        uint256 level = ISwapPool(pool).getLevel();
        reward = amount * several[level] / 100;
    }

    // function forcedCancle(address to, address _token) public override {
    //     require(msg.sender == owner, "No Authorized");
    //     removeStaking(to, _token);
    // }
}