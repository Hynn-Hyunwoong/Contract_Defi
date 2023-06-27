// // SPDX-License-Identifier: MIT 
// pragma solidity ^0.8.9;

// import "./asd.sol";
// import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
// import "../node_modules/@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";


// contract Factory {
//     address public minter;
//     address public uniswapFactory;
//     address[] public allTokens;
//     address[] public allPairs;

//     constructor(address _uniswapFactory) {
//         minter = msg.sender;
//         uniswapFactory = _uniswapFactory;
        
//     }

//     mapping(address => address) public getPair;
//     mapping(address => bool) public isToken;
//     mapping(address => mapping(address => address)) public getPairForTokens;

//     event PairCreated(address indexed token0, address indexed token1, address pair, uint);
//     event TokenCreated(address indexed token, address indexed owner, uint);
    
//     event TokenDecimals(address indexed token, uint8 decimals);
//     event TokenName(address indexed token, string name);
//     event TokenSymbol(address indexed token, string symbol);

//     event TokenMint(address indexed token, address indexed owner, uint256 amount);    
//     event TokenMinted(address indexed token, address indexed owner, uint);

//     event TokenTotalSupply(address indexed token, uint256 totalSupply);
//     event TokenBalanceOf(address indexed token, address indexed owner, uint256 balance);

//     event TokenBurn(address indexed token, address indexed owner, uint256 amount);
//     event TokenBurned(address indexed token, address indexed owner, uint);
    
//     event TokenTransfer(address indexed token, address indexed from, address indexed to, uint256 amount);    
//     event TokenTransferFrom(address indexed token, address indexed spender, address indexed from, address to, uint);
//     event TokenTransfered(address indexed token, address indexed from, address indexed to, uint);
    
//     event TokenApproval(address indexed token, address indexed owner, address indexed spender, uint);
//     event TokenApprove(address indexed token, address indexed owner, address indexed spender, uint256 amount);
//     event TokenAllowance(address indexed token, address indexed owner, address indexed spender, uint);
    
//     event TokenIncreaseAllowance(address indexed token, address indexed owner, address indexed spender, uint256 amount);
//     event TokenDecreaseAllowance(address indexed token, address indexed owner, address indexed spender, uint256 amount);

//     modifier onlyMinter() {
//         require(msg.sender == minter, "Alert : Only Owner");
//         _;
//     }

//     modifier onlyToken() {
//         require(isToken[msg.sender], "Alert : Only Token");
//         _;
//     }

//     modifier onlyPair() {
//         require(getPair[msg.sender] != address(0), "Alert : Only Pair");
//         _;
//     }

//     modifier onlyUniswapFactory() {
//         require(msg.sender == uniswapFactory, "Alert : Only Uniswap Factory");
//         _;
//     }

//     function createPair() external onlyToken returns (address pair) {
//         address token0 = msg.sender;
//         address token1 = address(new ASDToken());
//         pair = IUniswapV2Factory(uniswapFactory).createPair(token0, token1);
//         allTokens.push(token0);
//         getPair[token0] = pair;
//         getPairForTokens[token0][token1] = pair;
//         getPairForTokens[token1][token0] = pair;
//     }

//     function _mint(address to, uint256 amount) external onlyToken {
//         ASDToken(msg.sender).mint(to, amount);
//     }

//     function _burn(address to, uint256 amount) external onlyToken {
//         ASDToken(msg.sender).burn(to, amount);
//     } 
// }



