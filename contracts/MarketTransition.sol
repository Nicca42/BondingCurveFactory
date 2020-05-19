pragma solidity 0.6.6;

import "./IUniswapV2Router01.sol";
import "./I_Token.sol";
import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";


contract MarketTransition is ERC20 {
    IUniswapV2Router01 public routerInstance;
    bool public check;

    event transfering(string log);

    constructor(address _uniswapRouter)
    ERC20("test", "TST")
    public {
        routerInstance = IUniswapV2Router01(_uniswapRouter);
    }

    function transition(address _token) public {
        I_Token tokenInstance = I_Token(_token);
        // // This gets the price of the next token in collateral
        uint256 currentPrice = tokenInstance.getBuyCost(1);

        IERC20 collateral = IERC20(tokenInstance.getCollateralInstance());
        uint256 collateralInToken = collateral.balanceOf(_token);

        uint256 tokensToMint = collateralInToken/currentPrice;

        // //TODO Checks if a pair is already created 
        // // TODO if there is then the min A & B need to be sliders not set
        // {
        //     (uint amountA, uint amountB, uint liquidity) = routerInstance.addLiquidity(
        //         address(tokenInstance),
        //         address(collateral),
        //         tokensToMint,
        //         collateralInToken,
        //         tokensToMint,
        //         collateralInToken,
        //         address(tokenInstance),
        //         (now + 1000)
        //     );
        // }

        emit transfering("log 1");
    }

    function getTokensToMint() public view returns(uint256 tokensToMint) {
        I_Token tokenInstance = I_Token(msg.sender);
        uint256 currentPrice = tokenInstance.getBuyCost(1);

        IERC20 collateral = IERC20(tokenInstance.getCollateralInstance());
        uint256 collateralInToken = collateral.balanceOf(msg.sender);

        tokensToMint = collateralInToken/currentPrice;
    }
}