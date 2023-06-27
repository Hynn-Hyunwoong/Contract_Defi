// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./TokenPrice.sol";

/*
ETH : 0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612
USDT : 0x3f3f5dF88dC9F13eac63DF89EC16ef6e7E25DdE7
ARD : 0xb2A824043730FE05F3DA2efaFa1CBbe83fa548D6
 */

contract TokenPriceOracle {
    TokenPrice public ethPrice;
    TokenPrice public usdtPrice;
    TokenPrice public arbPrice;
    // TokenPrice public swapTokenPrice;

    constructor() {
    // constructor(address _swapFeed){
        ethPrice = new TokenPrice(address(0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612));
        usdtPrice = new TokenPrice(address(0x3f3f5dF88dC9F13eac63DF89EC16ef6e7E25DdE7));
        arbPrice = new TokenPrice(address(0xb2A824043730FE05F3DA2efaFa1CBbe83fa548D6));
        // swapTokenPrice = new TokenPrice(_swapFeed);
    }

    // function getSwapTokenPrice() external view returns (uint256) {
    //     return swapTokenPrice.getPrice();
    // }

    function routing(string memory name) view public returns(uint256 price) {
        if(Strings.equal(name, "ETH")) price =  getEthPrice();
        else if(Strings.equal(name, "USDT")) price = getUsdtPrice();
        else if(Strings.equal(name, "ARB")) price = getArbPrice();
    }

    function getEthPrice() private view returns (uint256) {
        return ethPrice.getPrice();
    }

    function getUsdtPrice() private view returns (uint256) {
        return usdtPrice.getPrice();
    }

    function getArbPrice() private view returns (uint256) {
        return arbPrice.getPrice();
    }
}



