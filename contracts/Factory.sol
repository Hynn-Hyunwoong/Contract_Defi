// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenFactory {
    event TokenCreated(address tokenAddress);

    function createToken(string memory name, string memory symbol, uint initialSupply, address owner) public {
        Token newToken = new Token(name, symbol, initialSupply, owner);
        emit TokenCreated(address(newToken));
    }
}

contract Token is ERC20 {
    constructor(string memory name, string memory symbol, uint initialSupply, address owner) ERC20(name, symbol) {
        _mint(owner, initialSupply);
    }

    function mint(address to, uint amount) external {
        _mint(to, amount);
    }

    function burn(address from, uint amount) external {
        _burn(from, amount);
    }
}
