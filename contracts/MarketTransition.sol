pragma solidity 0.6.6;

import "./IUniswapV2Router01.sol";
import "./I_Token.sol";
import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "./BokkyPooBahsDateTimeLibrary.sol";

contract MarketTransition {
    using BokkyPooBahsDateTimeLibrary for uint256;
    // Creates an instance of the uniswap router
    IUniswapV2Router01 public routerInstance;

    bool public check;
    mapping(address => uint[3]) public transitionInfo;

    event transitionToFreeMarket(uint amountA, uint amountB, uint liquidity);

    constructor(address _uniswapRouter) public {
        routerInstance = IUniswapV2Router01(_uniswapRouter);
    }

    function transition() public {
        // Creates an instance of the token sender.
        I_Token tokenInstance = I_Token(msg.sender);
        // Creates an instance of the collateral token of the token.
        IERC20 collateralInstance = IERC20(
            tokenInstance.getCollateralInstance()
        );
        // // This gets the price of the next token in collateral
        uint256 currentPrice = transitionInfo[msg.sender][0];
        uint256 tokensToMint = transitionInfo[msg.sender][1];
        uint256 collateralInToken = transitionInfo[msg.sender][2];

        // TODO Checks if a pair is already created 
        // TODO if there is then the min A & B need to be sliders not set
        {
            // Approves the uniswap router as a spender for the collateral and
            // tokens.
            require(
                collateralInstance.approve(
                    address(routerInstance),
                    collateralInToken
                ),
                "Transfer of collateral failed"
            );
            require(
                tokenInstance.approve(
                    address(routerInstance),
                    tokensToMint
                ),
                "Transfer of minted tokens failed"
            );
            // Creates and adds liquidity for the pair on uniswap. 
            (
                uint amountA, 
                uint amountB, 
                uint liquidity
            ) = routerInstance.addLiquidity(
                address(tokenInstance),
                address(collateralInstance),
                tokensToMint,
                collateralInToken,
                tokensToMint,
                collateralInToken,
                address(tokenInstance),
                (now + 1000)
            );

            emit transitionToFreeMarket(amountA, amountB, liquidity);
        }
        // Sets the token to transitioned.
        I_Token(msg.sender).setTransition();
    }

    /**
      * @notice This functions stores the information around the prices for the
      *         token as when this information was not stored the calculations
      *         would inherintly be different as there would be new tokens 
      *         minted between this function and the transition function 
      *         iteself.
      * @return uint256: The number of tokens the token will need to mint
      *         for the start price of the uniswap market to be the same as the
      *         end price of the bonding curve.
      */
    function getTokensToMint() public returns(uint256) {
        I_Token tokenInstance = I_Token(msg.sender);
        uint256 currentPrice = tokenInstance.getBuyCost(1);
        // Makes an instance of the collateral token of the token
        IERC20 collateralInstance = IERC20(
            tokenInstance.getCollateralInstance()
        );
        
        uint256 collateralInToken = collateralInstance.balanceOf(msg.sender);
        uint256 tokensToMint = collateralInToken/currentPrice;

        transitionInfo[msg.sender][0] = currentPrice;
        transitionInfo[msg.sender][1] = tokensToMint;
        transitionInfo[msg.sender][2] = collateralInToken;

        return tokensToMint;
    }

    /**
      * @return address: The address of the uniswap router. 
      */
    function getRouterAddress() public view returns(address) {
        return address(routerInstance);
    }

    /**
      * @param  _token: The address of the token.
      * @return uint: The current price. The price of the token at transition.
      *         This should be the start price of the uniswap market. 
      * @return uint: The tokens minted to the transition contract.
      * @return uint: The collateral moved out of the bonding curve and into the
      *         uniswap market.
      */
    function getTransitionInfo(
        address _token
    ) 
        public 
        view 
        returns(
            uint, 
            uint, 
            uint
        ) 
    {
        return (
            transitionInfo[_token][0],
            transitionInfo[_token][1],
            transitionInfo[_token][2]
        );
    }

    /**
      * @notice I needed a time calaculator somewhere, so I added it in here.
      * @param  _months: The number of months to be converted into unix time.
      * @return uint256: The time stamp of the months in unix time.
      */
    function getMonthsFutureTimestamp(
        uint256 _months
    ) 
        public 
        view 
        returns(uint256) 
    {
        return now.addMonths(_months);
    }
}