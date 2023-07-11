// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface IFeeStore {
    function update(address pool, address _token, uint256 _amount) external; // 받은 수수료 업데이트
    function distributionFee() external; // 수수료 분배
}