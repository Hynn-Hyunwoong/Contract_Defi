// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./ILPToken.sol";
import "./IASDStaking.sol";
import "./ISwapPool.sol";
import "./ITokenInDex.sol";

contract ASDstaking is IASDStaking{
    uint256 public totalAmount;
    address public dropToken;
    address public owner;
    mapping(address => mapping(address => uint)) stakingList; // tokenAddress => sender => amount
    mapping(address => uint256) private period; // sender => timestamp 스테이킹 끝나는 시간. ( 스테이킹 시작 시간 + 기간 )

    constructor(address _owner, address _dropToken){
        owner = _owner;
        dropToken = _dropToken;
    }

    function addStaking(address sender, address asdToken, uint256 amount, uint256 time, uint256 serv) public override returns(bool){
        // serv = 몇 배인지. 4개월 1배, 8개월 2배, 12개월 4배, 12++ 8배
        totalAmount += amount;
        period[sender] = time;
        stakingList[asdToken][sender] = amount;
        ITokenInDex(asdToken).DexApprove(sender, amount);
        IERC20(asdToken).transferFrom(sender, address(this), amount);
        claimReward(sender, amount, serv);
        return true;
    }

    function removeStaking(address sender, address _token, uint256 time) public {
        // time = 현재 시간
        require(time > period[sender],"Not Enough Time");
        uint256 amount = stakingList[sender][_token];
        IERC20(_token).transfer(sender, amount);
        delete period[sender]; 
        delete stakingList[sender][_token];

    }

    function claimReward(address to, uint256 amount, uint256 serv) public{
        // reward 계산
        uint256 reward = getReward(amount, serv);
        ITokenInDex(dropToken).mint(to, reward);
    }

    function getReward(uint256 amount, uint256 serv) pure private returns(uint256 reward){
        // time은 staking 기간, 스테이킹 시작 시점부터 끝시점 까지의 시간 차이.
        reward = amount * serv;
    }
}