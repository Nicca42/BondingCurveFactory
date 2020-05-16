pragma solidity 0.6.6;

import "./IUniswapV2Router01.sol";
import "./I_Token.sol";
import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

contract MarketTransition {
    IUniswapV2Router01 public routerInstance;

    constructor(address _uniswapRouter) public {
        routerInstance = IUniswapV2Router01(_uniswapRouter);
    }

    function transition(address _token) public returns(bool) {
        I_Token tokenInstance = I_Token(_token);

        // This gets the price of the next token in collateral
        uint256 currentPrice = tokenInstance.getBuyCost(1);

        uint256 supply = tokenInstance.totalSupply();

        return true;
    }

    // Collateral in curve: 15 100 000
    // Cost per token:         302 500
    // total supply                100
    //

    /**
     348100000
     10392733
     100
     */

    // function getBuyCost(uint256 _tokens) public view returns(uint256);
}