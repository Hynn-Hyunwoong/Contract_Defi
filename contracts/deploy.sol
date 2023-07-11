// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "./Pool.sol";
import "./Staking.sol";
import "./IDeploy.sol";

contract Deploy is IDeploy{
    function deployPair(uint _level, address _owner) public override returns(address pair) {
        pair = address(new SwapPool(_level, _owner));
        return(pair);
    }

    // function deployStaking(address _owner, address _token) external override returns(address staking){
    //     staking = address(new Staking(_owner, _token));
    // }
}