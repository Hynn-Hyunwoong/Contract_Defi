// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IFactory.sol";
import "./ASD_Pair.sol";
import "./IASD_Pair.sol";
contract TokenFactory is IFactory{

    mapping(address => mapping(address => address)) public getPair; // token => token => pairAddress
    mapping(address => uint) public poolLv;
    mapping(address => uint) private feeKeeper;
    address[] public allPairs;
    uint fee;
    uint private defaultLevel = 1;
    uint private level;


    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function setLevel(uint _level) public {
        level = _level;
    }

    function setFee(uint _fee) public {
        fee = _fee;
    }
    
    function swapFeeKeeper(address _token, uint256 _amount) public {
        feeKeeper[_token] += _amount;
    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function getPairAddress(address tokenA, address tokenB) view public returns(address) {
        return getPair[tokenA][tokenB];
    }

    function createPair(address tokenA, address tokenB) public returns (address pair) {
        require(tokenA != tokenB, 'IDENTICAL_ADDRESSES');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'ZERO_ADDRESS');
        require(getPair[token0][token1] == address(0), 'PAIR_EXISTS');
        if(level == 0) pair = createPool(token0, token1, defaultLevel);
        else pair = createPool(token0, token1, level);
        level = 0;
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setPoolLevel(address pool, uint _level) public {
        IASD_SwapPair(pool).setLevel(_level);
        poolLv[pool] = _level;
    }

    function createPool(address tokenA, address tokenB, uint _level) public returns(address pairAddress){
        ASD_SwapPair pair = new ASD_SwapPair(_level);
        pair.initialize(tokenA, tokenB);
        pair.setFee(fee);
        pairAddress = address(pair);
        getPair[tokenA][tokenB] = pairAddress;
        getPair[tokenB][tokenA] = pairAddress;
        allPairs.push(pairAddress);
        poolLv[pairAddress] = _level;
    }
}