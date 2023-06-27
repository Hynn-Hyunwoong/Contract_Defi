// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.9;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract ASDToken is ERC20("ASDToken", "ASD"){
    address public minter;
    
    constructor() {
        minter = msg.sender;
        _mint(msg.sender, 10000 * 10 ** 18);
    }

    function mint(address to, uint256 amount)  external {
        require(msg.sender == minter, "Alert : Only Owner");
        _mint(to, amount);
    }

    function burn (address to, uint256 amount)  external {
        require(msg.sender == minter, "Alert : Only Owner");
        _burn(to, amount);
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }   
}