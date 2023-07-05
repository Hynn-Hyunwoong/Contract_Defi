// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "./ASD_Pair.sol";
import "./Staking.sol";


contract Deploy {
    function deployPair(uint _level)public returns(address pair) {
        pair = address(new ASD_SwapPair(_level));
    }

    function deployStaking(address _owner, address _token) public returns(address staking){
        staking = address(new Staking(_owner, _token));
    }
}