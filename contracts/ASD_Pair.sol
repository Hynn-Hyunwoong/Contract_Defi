// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@uniswap/v2-core/contracts/libraries/SafeMath.sol";
import "./LPToken.sol";
import "./TokenPriceOracle.sol"; 


contract ASD_SwapPair {
    using SafeMath for uint;

    address public factory;
    address public pool;
    address public tokenA;
    address public tokenB;

    uint public K;
    uint256 public PriceASD = 1000000000;
    uint256 public otherPrice;
    uint256 private fee;

    mapping(address => mapping(address => uint)) private tokenList; // 무슨 토큰에 누가 얼마 공급했나.

    mapping(address => uint) private poolAmount; // pair 토큰 A,B 수량

    event AddLiquidity(address from, address tokenA, address tokenB, uint256 _amountA, uint256 _amountB);
    event removeLP(address provider, uint256 amountA, uint256 amountB);
    event Swap(address sender, uint256 amountAIn, uint256 amountBIn, uint256 amountAOut, uint256 amountBOut);

    constructor() public {
        factory = msg.sender;
        pool = address(this);
        LPtoken LP = new LPtoken(pool);
    }

    function getFee() public returns(uint256){
        return fee;
    }

    function setFee( uint256 _fee) public {
        fee = _fee;
    }

    function getLiquidity(address token, address provider) view returns(uint) {
        return tokenlist[token][provider];
    }

    function getPoolAmount(address _token) view returns(uint) {
        return poolAmount(_token);
    }

    function initialize(address _tokenA, address _tokenB) public {
        tokenA = _tokenA;
        tokenB = _tokenB;
    }

    function setK() private {
        k = poolAmount[tokenA] * poolAmount[tokenB];
    }

    function addLiquidity(address _tokenA, address _tokenB, uint256 _amountA, uint256 _amountB, address from) public {
        require(_tokenA == tokenA && _tokenB == tokenB, "Incorrect Token");
        // IERC20 token1 = IERC20(_tokenA);
        // IERC20 token2 = IERC20(_tokenB);

        // token1.approve(pool, _amountA);
        // token2.approve(pool, _amountB);

        // token1.transferFrom(msg.sender, pool, _amountA);
        // token2.transferFrom(msg.sender, pool, _amountB);

        // token_list[_tokenA][msg.sender] += _amountA;
        // token_list[_tokenB][msg.sender] += _amountB;
        // tokens[tokenA] += _amountA;
        // tokens[tokenB] += _amountB;

        getTokenFromSender(_tokenA, _amountA, from);
        getTokenFromSender(_tokenB, _amountB, from);

        // LPtoken mint
        // CPMM
        K= tokens[tokenA] * tokens[tokenB];
        uint256 rewardLP = _CPMM(_amountA, _amountB); 
        require(LP.mint == true,"LP minting fail");    
        
        emit AddLiquidity(from, tokenA, tokenB, _amountA, _amountB);
    }

    function getTokenFromSender(address _token, uint256 _amount, address from) private payable {
        IERC20 token = IERC20(_token);

        token.approve(pool, _amount);

        token.transferFrom(from, pool, _amount);

        token_list[_token][from] += _amount;
        tokens[_token] += _amount;

    }

    function _CPMM(uint256 _amountA, uint256 _amountB) view public returns(uint256 reward) {
        uint256 LPtotal = tokens[tokenA] + tokens[tokenB];
        uint256 ratio_A = (_amountA*100 / LPtotal);
        uint256 ratio_B = (_amountB*100 / LPtotal);
        reward = K * (ratio_A + ratio_B)/10000;
    }

    function _mint( address to, uint256 amount) private returns(bool){
        LP.mint(to, amount);
        return true;
    }


    function removeLiquidity( address from) public {
        require(burnAmount != 0, "Wrong Request");
        uint256 burnAmount = LP.getList(from);
        uint256 burnA = tokenList[tokenA][from];
        uint256 burnB = tokenList[tokenB][from];
        _burn(from, burnAmount);
        _transfer(tokenA, from, burnA);
        _transfer(tokenB, from, burnB);

        emit RemoveLP(from, burnA, burnB);
    }

    function _burn( address to) private returns(bool){
        LP.burn(to);
        return true;
    }

    function _transfer( address _token, address provider, uint256 amount) private {
        IERC20(_token).transfer(provider, amount);
        delete tokenList[_token][provider];
        poolAmount[_token] -= amount;
    }

    function swap(address _tokenA, uint256 amountA, address _tokenB, uint256 amountB, address sender) private returns(uint256 swapAmount){
        otherPrice = new TokenPriceOracle().routing(IERC(_tokenB).symbol());
        uint256 swapAmount = otherPrice * fee / 100 / priceASD;
        IERC swap = IERC20(tokenB);
        getTokenFromSender(_tokenA, amountA, sender);
        swap._transfer(_tokenB, sender, swapAmount);
        emit Swap(sender, amountAIn, amountBIn, amountAOut, amountBOut);
    }

}

/*
swap - 계산식 수정

*/
