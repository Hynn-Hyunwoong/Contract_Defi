// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./ASD_Pair.sol";
contract TokenFactory {

    mapping(address => mapping(address => address)) public getPair;
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

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function getPair(address tokenA, address tokenB) public returns(address) {
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
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair;
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }
}

contract Token is ERC20 { // staking 작업 해야함.
    constructor(string memory name, string memory symbol, uint initialSupply, address owner) ERC20(name, symbol) {
        _mint(owner, initialSupply);
    }

    function mint(address to, uint amount) external {
        _mint(to, amount);
    }

    function burn(address from, uint amount) external {
        _burn(from, amount);
    }
}
