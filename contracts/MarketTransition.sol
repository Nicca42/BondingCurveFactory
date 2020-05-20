pragma solidity 0.6.6;

import "./IUniswapV2Router01.sol";
import "./I_Token.sol";
import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";


contract MarketTransition is ERC20 {
    IUniswapV2Router01 public routerInstance;
    bool public check;

    event transitionToFreeMarket(uint amountA, uint amountB, uint liquidity);
    event wtf(uint tokens, uint collateral);

    constructor(address _uniswapRouter)
    ERC20("test", "TST")
    public {
        routerInstance = IUniswapV2Router01(_uniswapRouter);
    }

    // TODO MAYBE Address passed in so that this can be implemented 
    // as a delegate call in future improvment 
    function transition(address _token) public {
        I_Token tokenInstance = I_Token(msg.sender);
        // // This gets the price of the next token in collateral
        uint256 currentPrice = tokenInstance.getBuyCost(1);

        IERC20 collateral = IERC20(tokenInstance.getCollateralInstance());
        uint256 collateralInToken = collateral.balanceOf(msg.sender);

        uint256 tokensToMint = collateralInToken/currentPrice;

        emit wtf(tokensToMint, collateralInToken);

        //TODO Checks if a pair is already created 
        // TODO if there is then the min A & B need to be sliders not set
        {
            (uint amountA, uint amountB, uint liquidity) = routerInstance.addLiquidity(
                address(tokenInstance),
                address(collateral),
                tokensToMint,
                collateralInToken,
                tokensToMint,
                collateralInToken,
                address(tokenInstance),
                (now + 1000)
            );

            emit transitionToFreeMarket(amountA, amountB, liquidity);
        }

        I_Token(msg.sender).setTransition();
    }

    function getTokensToMint() public view returns(uint256 tokensToMint) {
        I_Token tokenInstance = I_Token(msg.sender);
        uint256 currentPrice = tokenInstance.getBuyCost(1);

        IERC20 collateral = IERC20(tokenInstance.getCollateralInstance());
        uint256 collateralInToken = collateral.balanceOf(msg.sender);

        tokensToMint = collateralInToken/currentPrice;
    }

    function getRouterAddress() public view returns(address) {
        return address(routerInstance);
    }
}