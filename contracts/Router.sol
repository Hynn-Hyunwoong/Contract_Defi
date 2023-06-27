// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./ASD_Pair2.sol";

contract ASDRouter {
    address public factory;

    constructor( address _factory) public {
        factory = _factory;
    }

    function addLiquidity( address tokenA, uint256 amountA, address tokenB, uint256 amountB, address to) public {

    }
}
