// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract ASD is ERC20("ASD Token", "ASD") {
    address private ASD_CA;
    address private minter;

    constructor () {
        ASD_CA = address(this);
        minter = msg.sender;
    }

    modifier onlyMinter() {
        require(msg.sender == minter || msg.sender == ASD_CA, "only minter");
        _;
    }
    

    function mint(address to, uint amount) onlyMinter external {
        _mint(to, amount);
    }

    function burn(address to, uint amount) onlyMinter external {
        _burn(to, amount);
    }
}