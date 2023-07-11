// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Airdrop is Ownable, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC20 public governanceToken;
    mapping(address => bool) public claimed;

    constructor(IERC20 _governanceToken, address _owner) {
        governanceToken = _governanceToken;
        transferOwnership(_owner);  
    }

    function airdrop(address[] memory recipients, uint256[] memory amounts) external onlyOwner whenNotPaused nonReentrant {
        require(recipients.length == amounts.length, "Recipients and amounts array length should be same");
        for(uint256 i=0; i<recipients.length; i++){
            require(!claimed[recipients[i]], "Address has already claimed the airdrop");
            claimed[recipients[i]] = true;
            governanceToken.safeTransfer(recipients[i], amounts[i]);
        }
    }
}