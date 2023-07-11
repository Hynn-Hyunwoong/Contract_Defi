// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;


contract TokenBank {

    struct Bank {
        string TokenName;
        mapping (address => mapping(address => uint256)) tokenStore;
    }
    
    constructor() {

    }

    function saveToken(address sender, uint256 amount) public {

    }    

    
}