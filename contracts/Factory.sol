// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IFactory.sol";
// import "./ASD_Pair.sol";
import "./IASD_Pair.sol";
import "./IDeploy.sol";

contract TokenFactory is IFactory{

    mapping(address => mapping(address => address)) public getPair; // token => token => pairAddress
    mapping(address => uint) public poolLv;
    mapping(address => uint) private feeKeeper;
    address[] public allPairs;
    address private deployer=0xd9145CCE52D386f254917e481eB44e9943F39138;
    uint fee=95; // ex) 95
    uint private defaultLevel = 1;


    event PairCreated(address indexed token0, address indexed token1, address pair, uint);


    function setFee(uint _fee) public {
        fee = _fee;
    }
    
    function swapFeeKeeper(address _token, uint256 _amount) public {
        feeKeeper[_token] += _amount;
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

    function setPoolLevel(address pool, uint _level) public {
        IASD_SwapPair(pool).setLevel(_level);
        poolLv[pool] = _level;
    }

    function createPool(address tokenA, address tokenB, uint _level) public returns(address pair){
        pair = IDeploy(deployer).deployPair(_level, address(this));
        IASD_SwapPair(pair).initialize(tokenA, tokenB);
        IASD_SwapPair(pair).setFee(fee);
        getPair[tokenA][tokenB] = pair;
        getPair[tokenB][tokenA] = pair;
        allPairs.push(pair);
        poolLv[pair] = _level;
    }
}