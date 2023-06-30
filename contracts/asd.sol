// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.9;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract ASDToken is ERC20("ASDToken", "ASD"){
    address public minter;
    uint public _decimal;
    constructor() {
        minter = msg.sender;
        _decimal = 10 ** decimals();
        // _mint(msg.sender, 10000 * _decimal);

    }

    function setAmount(uint _amount) view private returns(uint amount){
        amount = _amount * _decimal;
    }

    function mint(address to, uint256 amount)  external {
        require(msg.sender == minter, "Alert : Only Owner");
        _mint(to, setAmount(amount));
    }

    function burn (address to, uint256 amount)  external {
        require(msg.sender == minter, "Alert : Only Owner");
        _burn(to, setAmount(amount));
    }
}