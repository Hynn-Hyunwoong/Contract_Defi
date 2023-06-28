// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Factory.sol";
import "./ASD_Pair.sol";

contract ASDRouter {
    address public factory;

    constructor( address _factory) public {
        factory = _factory;
    }

    function addLiquidity( address tokenA, uint256 amountA, address tokenB, uint256 amountB) public {
        address pairAddress = TokenFactory(factory).getPair(tokenA, tokenB);
        if (pairAddress == address(0)) {
            TokenFactory(factory).createPair(tokenA, tokenB);
        }

        pairAddress = getPair(tokenA, tokenB);
        ASD_SwapPair(pairAddress).addLiquidity(tokenA, tokenB, amountA, amountB, msg.sender);
    }

    function removeLiquidity(address tokenA, address tokenB) public {
        pair = getPair(tokenA, tokenB);
        ASD_SwapPair(pair).removeLiquidity(msg.sender);
    }

    function swap(address tokenA, uint256 amountA, address tokenB, uint256 amountB) public {
        pair = getPair(tokenA, tokenB);
        ASD_SwapPair(pair).swap(tokenA, amountA, tokenB, amountB, msg.sender);
    }

    function getPair(address tokenA, address tokenB) returns(address pair) {
        pair = TokenFactory(factory).getPair(tokenA, tokenB);
    }


}
