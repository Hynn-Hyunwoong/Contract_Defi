// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./IFactory.sol";
import "./ISwapPool.sol";
import "./LPToken.sol";
import "./TokenPriceOracle.sol"; 
import "./ITokenInDex.sol";

contract SwapPool is ISwapPool {
    using SafeMath for uint256;

    struct TokenInfo {
        uint256 totalSupply;
        mapping(address => uint256) balances;
    }

    address public factory;
    address public pool;
    address public tokenA;
    address public tokenB;

    uint256 public level;
    uint256 public K;
    uint256 public priceASD = 100000000;
    uint256 public fee = 5;

    TokenInfo private tokenInfoA;
    TokenInfo private tokenInfoB;

    LPtoken private LP; 
    TokenPriceOracle public tokenPriceOracle;

    event AddLiquidity(address from, address tokenA, address tokenB, uint256 amountA, uint256 amountB);
    event RemoveLP(address provider, uint256 amountA, uint256 amountB);
    event Swap(address sender, address swap, uint256 amountIn, address swaped, uint256 amountOut);
    
    modifier onlyFactory() {
        require(msg.sender == factory, "ASD_SwapPair: Only factory can call this");
        _;
    }

    constructor(uint256 _level, address _owner) {
        factory = _owner;
        pool = address(this);
        level = _level;
        tokenPriceOracle = new TokenPriceOracle();
        LP = new LPtoken(pool, level);
    }

    function getLevel() view public virtual override returns(uint){
        return level;
    }

    function setLevel(uint256 _level) external  {
        level = _level;
        LP.setLevel(_level);
    }
    function getFee() external view virtual override returns(uint256) {
        return fee;
    }

    function setFee(uint256 feeValue) external virtual override {
        fee = feeValue;
    }

    function getLiquidity(address token, address provider) external view virtual override returns(uint256) {
        if(token == tokenA) return tokenInfoA.balances[provider];
        else return tokenInfoB.balances[provider];
    }

    function getLpAmount(address sender) external virtual override returns(uint256) {
        return LP.getList(sender);
    }

    function getPoolAmount(address _token) external view virtual returns(uint256) {
        if (_token == tokenA) {
            return tokenInfoA.totalSupply;
        } else if (_token == tokenB) {
            return tokenInfoB.totalSupply;
        }
        return 0;
    }

    function initialize(address _tokenA, address _tokenB) external virtual  {
        tokenA = _tokenA;
        tokenB = _tokenB;
    }

    function setK() private {
        K = tokenInfoA.totalSupply.mul(tokenInfoB.totalSupply);
    }

    function addLiquidity(address _tokenA, address _tokenB, uint256 _amountA, uint256 _amountB, address from) public virtual override {
        getTokenFromSender(_tokenA, _amountA, from);
        getTokenFromSender(_tokenB, _amountB, from);

        K = tokenInfoA.totalSupply.mul(tokenInfoB.totalSupply);
        uint256 rewardLP = getLpReward(_amountA, _amountB); 

        require(_mint(from, rewardLP), "ASD_SwapPair: LP minting failed");    
        
        emit AddLiquidity(from, tokenA, tokenB, _amountA, _amountB);
    }

    function getTokenFromSender(address _token, uint256 _amount, address from) private {
        require(IERC20(_token).balanceOf(from)>= _amount, "Not Enough");
        ITokenInDex(_token).DexApprove(from, _amount);
        IERC20(_token).transferFrom(from, pool, _amount);

        if (_token == tokenA) {
            tokenInfoA.totalSupply = tokenInfoA.totalSupply.add(_amount);
            tokenInfoA.balances[from] = tokenInfoA.balances[from].add(_amount);
        } else if (_token == tokenB) {
            tokenInfoB.totalSupply = tokenInfoB.totalSupply.add(_amount);
            tokenInfoB.balances[from] = tokenInfoB.balances[from].add(_amount);
        }
    }

    function getLpReward(uint256 _amountA, uint256 _amountB) public view returns(uint256 reward) {
        uint256 LPtotal = tokenInfoA.totalSupply.add(tokenInfoB.totalSupply);
        uint256 ratio_A = (_amountA.mul(100)).div(LPtotal);
        uint256 ratio_B = (_amountB.mul(100)).div(LPtotal);
        reward = Math.sqrt(K.mul(ratio_A.add(ratio_B)).div(100))/10**18;
    }

    function _mint(address to, uint256 amount) private returns(bool) {
        LP.mint(to, amount);
        return true;
    }

    function removeLiquidity(address from) public virtual override{
        uint256 burnA = tokenInfoA.balances[from];
        uint256 burnB = tokenInfoB.balances[from];
        require(burnA != 0, "Not Enough");
        require(burnB != 0, "Not Enough");
        _burn(from);
        _transfer(tokenA, from, burnA);
        _transfer(tokenB, from, burnB);
        // setK();
        // emit RemoveLP(from, burnA, burnB);
    }

    function _burn(address to) private returns(bool) {
        LP.burn(to);
        return true;
    }

    function _transfer(address _token, address to, uint256 amount) private {
        IERC20(_token).transfer(to, amount);
        if (_token == tokenA) {
            delete tokenInfoA.balances[to];
            tokenInfoA.totalSupply = tokenInfoA.totalSupply.sub(amount);
        } else if (_token == tokenB) {
            delete tokenInfoB.balances[to];
            tokenInfoB.totalSupply = tokenInfoB.totalSupply.sub(amount);
        }
    }
// 1000000000000000000000
    function swap(address _swap, address _swaped, uint256 amountIn, address sender) public virtual override returns(uint256 swapedAmount) {
        uint256 swapFee = amountIn.mul(fee).div(100);
        uint256 swapAmount = amountIn.sub(swapFee);
        getTokenFromSender(_swap, amountIn, sender);
        feeKeepingtoFactory(_swap, swapFee);
        if (_swap == tokenA) {
            tokenInfoA.totalSupply = tokenInfoA.totalSupply.add(swapAmount);
        } else if (_swap == tokenB) {
            tokenInfoB.totalSupply = tokenInfoB.totalSupply.add(swapAmount);
        }
        swapedAmount = tokenInfoB.totalSupply.sub(K.div(tokenInfoA.totalSupply));
        
        _transfer(_swaped, sender, swapedAmount);
        setK(); 
        emit Swap(sender, _swap, amountIn, _swaped, swapedAmount);
    }

    function feeKeepingtoFactory(address _token, uint256 _amount) private {
        _transfer(_token, factory, _amount);
        IFactory(factory).swapFeeKeeper(_token, _amount);
    }
}
