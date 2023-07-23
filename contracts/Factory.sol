// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IFactory.sol";
import "./IPairDeployer.sol";
import "./ISwapPool.sol";
import "./IStakingDeployer.sol";
import "./IStaking.sol";


contract TokenFactory is IFactory{

    mapping(address => mapping(address => address)) public getPair; // token => token => pairAddress
    mapping(address => uint) public poolLv;
    mapping(address => mapping(address => uint256)) private feeKeeper;
    mapping(address => PoolFeeToken[]) private feeKeeperStruct;
    mapping(address => address) private stakingPool;
    address[] public allPairs;
    address public pairDeployer;
    address public stakingDeployer;
    uint fee=5; // ex) 5% fee
    uint private defaultLevel = 1;

    struct PoolFeeToken {
        address token;
        uint256 amount;
    }
 
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    constructor(address _pairDeployer, address _stakingDeployer){
        pairDeployer = _pairDeployer;
        stakingDeployer = _stakingDeployer;
    }

    function setFee(uint _fee) public {
        fee = _fee;
    }
    
    function swapFeeKeeper(address _token, uint256 _amount) public {
        PoolFeeToken memory poolFeeToken = PoolFeeToken(_token, _amount);
        feeKeeperStruct[msg.sender].push(poolFeeToken);
        feeKeeper[msg.sender][_token] += _amount;
    }

    function getFeeAmount(address pool, address _token) view public returns(uint256) {
        return feeKeeper[pool][_token];
    }

    function getFeeAmountByTokens(address tokenA, address tokenB, address feeToken) view public returns(uint256){
        address pool = getPair[tokenA][tokenB];
        return feeKeeper[pool][feeToken];
    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function getPairAddress(address tokenA, address tokenB) view external returns(address) {
        return getPair[tokenA][tokenB];
    }

    function createPair(address tokenA, address tokenB) public returns (address pair) {
        require(tokenA != tokenB, 'IDENTICAL_ADDRESSES');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(getPair[token0][token1] == address(0), 'PAIR_EXISTS');
        pair = createPool(tokenA, tokenB, defaultLevel);
        emit PairCreated(tokenA, tokenB, pair, allPairs.length);
    }

    function setPoolLevel(address tokenA, address tokenB, uint _level) public {
        address pool = getPair[tokenA][tokenB];
        ISwapPool(pool).setLevel(_level);
        poolLv[pool] = _level;
    }

    function createPool(address tokenA, address tokenB, uint256 _level) public virtual override returns(address pair){
        pair = IPairDeployer(pairDeployer).createPool(tokenA, tokenB, _level, fee);
        getPair[tokenA][tokenB] = pair;
        getPair[tokenB][tokenA] = pair;
        allPairs.push(pair);
        poolLv[pair] = _level;
    }

    function createLpStaking(address _token) public returns(address staking){
        staking = IStakingDeployer(stakingDeployer).LpStakingDeploy(_token);
        stakingPool[_token] = staking;
    } // 의제로만 생성가능하도록?? 일단 아무나 생성가능

    function createASDstaking(address _token) public returns(address staking){
        staking = IStakingDeployer(stakingDeployer).ASDstakingDeploy(_token);
        stakingPool[_token] = staking;
    }

    function getStakingPool(address _token) view public returns(address) {
        return stakingPool[_token];
    }


}