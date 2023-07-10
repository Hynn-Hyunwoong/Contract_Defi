// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "./SwapPool.sol";
import "./IPairDeployer.sol";
contract PairDeployer is IPairDeployer{

    address public owner;

    function setOwner(address _owner) public {
        owner = _owner;
    }

    function createPool(address tokenA, address tokenB, uint _level, uint256 _fee) public returns(address){
        require(msg.sender == owner, "No Authority");
        SwapPool pair = new SwapPool(_level, owner);
        pair.initialize(tokenA, tokenB);
        pair.setFee(_fee);
        return address(pair);
    }
}