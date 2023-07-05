// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IFactory.sol";
import "./IASD_Pair.sol";

contract ASDRouter {
    address public factory;

    constructor( address _factory)  {
        factory = _factory;
    }

    function addLiquidity( address tokenA, uint256 amountA, address tokenB, uint256 amountB) public {
        address pairAddress = IFactory(factory).getPairAddress(tokenA, tokenB);
        if (pairAddress == address(0)) {
            pairAddress = IFactory(factory).createPair(tokenA, tokenB);
        }

        IASD_SwapPair(pairAddress).addLiquidity(tokenA, tokenB, amountA, amountB, msg.sender);
    }

    function removeLiquidity(address tokenA, address tokenB) public {
        address pair = getPair(tokenA, tokenB);
        IASD_SwapPair(pair).removeLiquidity(msg.sender);
    }

    function swap(address _swap, address _swaped, uint256 amount) public {
        address pair = getPair(_swap, _swaped);
        IASD_SwapPair(pair).swap(_swap, _swaped, amount, msg.sender);
    }

    function getPair(address tokenA, address tokenB) private returns(address pair) {
        pair = IFactory(factory).getPairAddress(tokenA, tokenB);
    }


}
