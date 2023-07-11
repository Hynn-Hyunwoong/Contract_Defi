// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IFactory.sol";
import "./ISwapPool.sol";
import "./IStaking.sol";

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

    function getStakingAddress(address _token) public returns(address staking){
        staking = factory.getStakingPool(_token); // _token은 lptoken이나 ASD 토큰 CA
        if(staking == address(0)) staking = factory.createStaking(_token);
    }

    function addLpStaking(address sender, address lpToken, uint256 amount, uint256 time) public {

    }
}
