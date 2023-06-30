// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IFactory.sol";
import "./ASD_Pair.sol";
contract TokenFactory is IFactory{

    mapping(address => mapping(address => address)) public getPair; // token => token => pairAddress
    mapping(address => uint) public poolLv;
    mapping(address => uint) private feeKeeper;
    address[] public allPairs;
    uint fee;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    event TokenCreated(address tokenAddress);

    function createToken(string memory name, string memory symbol, uint initialSupply, address owner) public {
        Token newToken = new Token(name, symbol, initialSupply, owner);
        emit TokenCreated(address(newToken));
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

    function getPairAddress(address tokenA, address tokenB) public returns(address) {
        return getPair[tokenA][tokenB];
    }

    function createPair(address tokenA, address tokenB) public returns (address pair) {
        require(tokenA != tokenB, 'IDENTICAL_ADDRESSES');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'ZERO_ADDRESS');
        require(getPair[token0][token1] == address(0), 'PAIR_EXISTS');
        ASD_SwapPair pair = new ASD_SwapPair();
        pair.initialize(token0, token1);
        pair.setFee(fee);
        getPair[token0][token1] = address(pair);
        getPair[token1][token0] = address(pair);
        allPairs.push(address(pair));
        poolLv[address(pair)] = 1;
        emit PairCreated(token0, token1, address(pair), allPairs.length);
    }
}