// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract LPtoken is ERC20("LP token", "LP"){
    address private owner;
    mapping(address => uint256) private list;

    constructor(address _owner) {
        owner = _owner; //pool address
    }

    modifier NotZeroAddress(address to) {
        require(to != address(0),"Zero Address");
        require(msg.sender == owner,"Wrong request");
        _;
    }

    function getList(address user) view public returns(uint256){
        return list[user];
    }

    function mint(address to, uint256 amount) NotZeroAddress(to) public {
        list[to] += amount;
        _mint(to, amount);
    }

    function burn(address to) NotZeroAddress(to) public {
        _burn(to, list[to]);
        delete list[to];
    }


}