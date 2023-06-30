// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./TokenPrice.sol";

/*
    address public EthAddress = 0x62CAe0FA2da220f43a51F86Db2EDb36DcA9A5A08;
    address public UsdtAddress = 0x0a023a3423D9b27A0BE48c768CCF2dD7877fEf5E;
    address public ArbAddress = 0x2eE9BFB2D319B31A573EA15774B755715988E99D;
 */

contract TokenPriceOracle {
    TokenPrice public ethPrice;
    TokenPrice public usdtPrice;
    TokenPrice public arbPrice;
    // TokenPrice public swapTokenPrice;

    constructor() {
    // constructor(address _swapFeed){
        ethPrice = new TokenPrice(address(0x62CAe0FA2da220f43a51F86Db2EDb36DcA9A5A08));
        usdtPrice = new TokenPrice(address(0x0a023a3423D9b27A0BE48c768CCF2dD7877fEf5E));
        arbPrice = new TokenPrice(address(0x2eE9BFB2D319B31A573EA15774B755715988E99D));
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



