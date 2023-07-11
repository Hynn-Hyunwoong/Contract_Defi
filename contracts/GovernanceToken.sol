// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./Airdrop.sol";

contract GovernanceToken is ERC20{
    Airdrop public airdrop;
    address public factory;

    mapping(address => uint256) public stakingBalance;
    mapping(address => bool) public isStaking;
    mapping(address => uint256) public startTime;

    modifier onlyFactory() {
        require(msg.sender == factory, "Only factory can call this function");
        _;
    }

    constructor() ERC20("V-ASD Token", "V-ASD") {
        _mint(msg.sender, 100000);
        airdrop = new Airdrop(IERC20(address(this)), msg.sender); 
    }

    function mint(address to, uint amount) external onlyFactory {
        _mint(to, amount);
    }

    function burn(address from, uint amount) external onlyFactory{
        require(balanceOf(from) >= amount, "ERC20: burn amount exceeds balance");
        _burn(from, amount);
    }

    function distributeAirdrop(address[] memory recipients, uint256[] memory amounts) external onlyFactory {
        airdrop.airdrop(recipients, amounts);
    }

    function setFactory(address _factory) external {
        factory = _factory;
    }

    function stakeToken(uint _amount) external {
        require(_amount > 0, "amount cannot be 0");
        transferFrom(msg.sender, address(this), _amount);
        stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;
        isStaking[msg.sender] = true;
        startTime[msg.sender] = block.timestamp;
    }

    function unstakeTokens() public {
        uint256 balance = stakingBalance[msg.sender];
        require(balance > 0, "staking balance cannot be 0");
        transfer(msg.sender, balance);
        stakingBalance[msg.sender] = 0;
        isStaking[msg.sender] = false;
    }

    function issueRewards() public {
        if(isStaking[msg.sender]){
            uint256 balance = stakingBalance[msg.sender];
            if(balance > 0){
                uint256 reward = calculateReward(msg.sender);
                transfer(msg.sender, reward);
            }
        }
    }

    function calculateReward(address _user) public view returns(uint256){
        uint256 stakingTime = block.timestamp - startTime[_user];
        uint256 reward = (stakingBalance[_user] * stakingTime)/ 100; 
        return reward;
    }
}