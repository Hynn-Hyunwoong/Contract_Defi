// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IFactory.sol";
import "./ISwapPool.sol";
import "./IStaking.sol";
import "./IASDstaking.sol";

contract ASDRouter {
    address public factoryAddress;
    IFactory public factory;
    constructor( address _factory) {
        factoryAddress = _factory;
        factory = IFactory(factoryAddress);
    }

    function addLiquidity( address tokenA, uint256 amountA, address tokenB, uint256 amountB, address sender) public {
        address pairAddress = factory.getPairAddress(tokenA, tokenB);
        if (pairAddress == address(0)) {
            pairAddress = factory.createPair(tokenA, tokenB);
        }

        ISwapPool(pairAddress).addLiquidity(tokenA, tokenB, amountA, amountB, sender);
    }

    function removeLiquidity(address tokenA, address tokenB, address sender) public {
        address pair = factory.getPairAddress(tokenA, tokenB);
        ISwapPool(pair).removeLiquidity(sender);
    }

    function swap(address _swap, address _swaped, uint256 amount) public {
        address pair = factory.getPairAddress(_swap, _swaped);
        ISwapPool(pair).swap(_swap, _swaped, amount, msg.sender);
    }

    function getStakingAddress(address _token) public returns(address){
        address staking = factory.getStakingPool(_token); // _token은 ASD나 vASD 토큰 CA, 보상 받는 토큰을 입력.
        require(staking==address(0),"No Exist Staking Pool");
        return staking;
    }

    function addLpStaking(address sender, address _token, uint256 amount, uint256 time, address rewardToken) public {
        // time은 staking 누른시점부터 4개월 8개월 12개월을 timestamp 형식으로 더한 값.
        address staking = getStakingAddress(rewardToken);
        IStaking(staking).addStaking(sender, _token, amount, time);
    }

    function removeLpStaking(address sender, address _token, uint256 time, address rewardToken) public {
        address staking = getStakingAddress(rewardToken);
        IStaking(staking).removeStaking(sender, _token, time);
    }

    function addASDTokenStaking(address sender, address asdToken, uint256 amount, uint256 time, uint256 serv, address rewardToken) public {
        address staking = getStakingAddress(rewardToken);
        IASDStaking(staking).addStaking(sender, asdToken, amount, time, serv);
    }

    function removeASDTokenStaking( address sender, address _token, uint256 time, address rewardToken) public {
        address staking = getStakingAddress(rewardToken);
        IASDStaking(staking).removeStaking(sender, _token, time);
    }
}
