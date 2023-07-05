// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Airdrop {
    IERC20 public token;
    mapping (address => bool) public airdropped;
    address public owner;

    modifier onlyOwner(){
        require(msg.sender == owner, "Alert : only owner can call this function");
        _;
    }

    constructor(address _token) {
        token = IERC20(_token);
        owner = msg.sender ;
    }

    function airdrop(address[] memory recipients, uint256[] memory amounts)external onlyOwner{
        require(recipients.length == amounts.length, "recipients and amounts length mismatch");

        for (uint256 i=0; i<recipients.length; i++){
            require(!airdropped[recipients[i]], "recipient already airdropped");
            token.transferFrom(msg.sender, recipients[i], amounts[i]);
            airdropped[recipients[i]] = true;
        }
    }

}