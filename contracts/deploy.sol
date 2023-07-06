// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "./ASD_Pair.sol";
import "./Staking.sol";
import "./IDeploy.sol";

contract Deploy is IDeploy{
    ASD_SwapPair pair1;
    function deployPair(uint _level, address _owner) public override returns(address) {
        pair1 = new ASD_SwapPair(_level, _owner);
        return(address(pair1));
    }

    function deployStaking(address _owner, address _token) external override returns(address staking){
        staking = address(new Staking(_owner, _token));
    }
}