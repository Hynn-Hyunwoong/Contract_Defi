// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./ILPToken.sol";


contract LPtoken is ILPToken, ERC20("LP token", "LP"){
    address private owner;
    mapping(address => uint256) private list;

    uint public level;

    constructor(address _owner, uint poolLevel) {
        owner = _owner; //pool address
        level = poolLevel;
    }

    modifier NotZeroAddress(address to) {
        require(to != address(0),"Zero Address");
        require(msg.sender == owner,"Wrong request");
        _;
    }

    function getOwner() view public returns(address) {
        return owner;
    }

    function setLevel(uint _level) public {
        level = _level;
    }

    function getLevel() view public returns(uint _level){
        _level = level;
    }

    function getList(address user) view public returns(uint256){
        return list[user];
    }

    function mint(address to, uint256 amount) NotZeroAddress(to) public returns(bool){
        list[to] += amount;
        _mint(to, amount);
        return true;
    }

    function burn(address to) NotZeroAddress(to) public returns(bool) {
        _burn(to, list[to]);
        delete list[to];
        return true;
    }

    function DexApprove(address from, uint256 amount) public virtual override returns(bool) {
        address spender = _msgSender();
        _approve(from, spender, amount);
        return true;
    }


}