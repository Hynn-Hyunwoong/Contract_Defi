// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./IFactory.sol";
import "./IASD_Pair.sol";
import "./LPToken.sol";
import "./TokenPriceOracle.sol"; 


contract ASD_SwapPair is IASD_SwapPair{
    address public factory;
    address public pool;
    address public tokenA;
    address public tokenB;

    uint public K;
    uint256 public priceASD = 100000000;
    uint256 public otherPrice;
    uint256 private fee;
    uint256 private _fee;

    mapping(address => mapping(address => uint)) private tokenList; // 무슨 토큰에 누가 얼마 공급했나.
    mapping(address => uint) private tokens;
    mapping(address => uint) private poolAmount; // pair 토큰 A,B 수량
    mapping(address => uint) public lpRatio;

    LPtoken private LP;
    TokenPriceOracle public tokenPriceOracle;

    event AddLiquidity(address from, address tokenA, address tokenB, uint256 _amountA, uint256 _amountB);
    event RemoveLP(address provider, uint256 amountA, uint256 amountB);
    event Swap(address sender, uint256 amountAIn, uint256 amountBIn, uint256 amountAOut, uint256 amountBOut);
    

    constructor() public {
        factory = msg.sender;
        pool = address(this);
        LP = new LPtoken(pool);
        tokenPriceOracle = new TokenPriceOracle();
        _fee = fee * 10 ** 16;
        setRatio();
    }

    function getFee() view public override returns(uint256){
        return fee;
    }

    function setFee( uint256 feeValue) public override {
        fee = feeValue;
    }


    function setRatio() public override{
        string memory symbolA = IERC20(tokenA).symbol();
        string memory symbolB = IERC20(tokenB).symbol();
        uint _tokenA = tokenPriceOracle.routing(symbolA);
        uint _tokenB = tokenPriceOracle.routing(symbolB);
 

        lpRatio[tokenA] = _tokenA;
        lpRatio[tokenB] = _tokenB;
    }

    function getRatio() view public override returns(Ratio memory) {
        Ratio memory ratio = Ratio(tokenA, lpRatio[tokenA], tokenB, lpRatio[tokenB]);
        return ratio;
    }

    function getLiquidity(address token, address provider) view public override returns(uint) {
        return tokenList[token][provider];
    }

    function getPoolAmount(address _token) view public override returns(uint) {
        return poolAmount[_token];
    }

    function initialize(address _tokenA, address _tokenB) public override{
        tokenA = _tokenA;
        tokenB = _tokenB;
    }

    function setK() private {
        K = poolAmount[tokenA] * poolAmount[tokenB];
    }

    function addLiquidity(address _tokenA, address _tokenB, uint256 _amountA, uint256 _amountB, address from) public payable override{
        require(_tokenA == tokenA && _tokenB == tokenB, "Incorrect Token");

        getTokenFromSender(_tokenA, _amountA, from);
        getTokenFromSender(_tokenB, _amountB, from);

        // LPtoken mint
        // CPMM
        K= tokens[tokenA] * tokens[tokenB];
        uint256 rewardLP = _CPMM(_amountA, _amountB); 

        require(LP.mint(from, rewardLP) == true,"LP minting fail");    
        
        emit AddLiquidity(from, tokenA, tokenB, _amountA, _amountB);
    }

    function getTokenFromSender(address _token, uint256 _amount, address from) private {
        IERC20 token = IERC20(_token);

        token.approve(pool, _amount);

        token.transferFrom(from, pool, _amount);

        tokenList[_token][from] += _amount;
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


    function removeLiquidity( address from) public override {
        uint256 burnAmount = LP.getList(from);
        uint256 burnA = tokenList[tokenA][from];
        uint256 burnB = tokenList[tokenB][from];
        _burn(from);
        _transfer(tokenA, from, burnA);
        _transfer(tokenB, from, burnB);

        emit RemoveLP(from, burnA, burnB);
    }

    function _burn( address to) private returns(bool){
        LP.burn(to);
        return true;
    }

    function _transfer( address _token, address to, uint256 amount) private {
        IERC20(_token).transfer(to, amount);
        delete tokenList[_token][to];
        poolAmount[_token] -= amount;
    }

    function swap(address _swap, address _swaped, uint256 amountIn, address sender) public override returns(uint256 swapedAmount){
        uint256 swapFee = amountIn * _fee;
        uint256 swapAmount = amountIn - swapFee;
        getTokenFromSender(_swap, amountIn, sender);
        _transfer(_swap, factory, swapFee);
        tokens[_swaped] += swapAmount;
        swapedAmount = K / tokens[_swaped];
        
        _transfer(_swaped, sender, swapedAmount);
        feeKeepingtoFactory(_swap, swapFee);
         
        // emit Swap(sender, amountIn, swapedAmount);
    }

    function feeKeepingtoFactory(address _token, uint256 _amount) private {
        _transfer(_token, factory, _amount);
        IFactory(factory).swapFeeKeeper(_token, _amount);
    }
}