// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract TESTToken1 is ERC20("Test1 Token", "TST"){


    function mint(address to, uint256 amount) public returns(bool){   
        _mint(to, amount);
        return true;
    }

    function burn(address to, uint amount) public returns(bool) {
        _burn(to, amount);
        return true;
    }
}

contract TESTToken2 is ERC20("Test2 Token", "TSTT"){


    function mint(address to, uint256 amount) public returns(bool){   
        _mint(to, amount);
        return true;
    }

    function burn(address to, uint amount) public returns(bool) {
        _burn(to, amount);
        return true;
    }
}