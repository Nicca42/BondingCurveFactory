pragma solidity 0.6.6;

import "./IUniswapV2Router01.sol";
import "./I_Token.sol";
import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";


contract MarketTransition is ERC20 {
    IUniswapV2Router01 public routerInstance;
    bool public check;

    mapping(address => uint[3]) public transitionInfo;

    event transitionToFreeMarket(uint amountA, uint amountB, uint liquidity);
    event wtf(uint tokens, uint collateral, address sender);

    constructor(
        address _uniswapRouter
    )
        ERC20(
            "test", "TST"
        )
        public 
    {
        routerInstance = IUniswapV2Router01(_uniswapRouter);
    }

    address public msgSenderOnTransition;

    function getMsgSenderOnTransition() public view returns(address) {
        return msgSenderOnTransition;
    }

    // TODO MAYBE Address passed in so that this can be implemented 
    // as a delegate call in future improvment 
    function transition(address _token, address _router) public {
        // TODO add require for permissioning on this function
        I_Token tokenInstance = I_Token(_token);
        IERC20 collateralInstance = IERC20(tokenInstance.getCollateralInstance());
        // // This gets the price of the next token in collateral
        uint256 currentPrice = transitionInfo[_token][0];
        uint256 tokensToMint = transitionInfo[_token][1];
        uint256 collateralInToken = transitionInfo[_token][2];

        emit wtf(tokensToMint, collateralInToken, msg.sender);
        msgSenderOnTransition = msg.sender;

        //TODO Checks if a pair is already created 
        // TODO if there is then the min A & B need to be sliders not set
        {
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

            (uint amountA, uint amountB, uint liquidity) = routerInstance.addLiquidity(
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

        I_Token(_token).setTransition();
    }

    function getTokensToMint() public returns(uint256 tokensToMint) {
        I_Token tokenInstance = I_Token(msg.sender);
        uint256 currentPrice = tokenInstance.getBuyCost(1);

        IERC20 collateralInstance = IERC20(tokenInstance.getCollateralInstance());
        uint256 collateralInToken = collateralInstance.balanceOf(address(this));

        tokensToMint = collateralInToken/currentPrice;

        transitionInfo[msg.sender][0] = currentPrice;
        transitionInfo[msg.sender][1] = tokensToMint;
        transitionInfo[msg.sender][2] = collateralInToken;
    }

    function getRouterAddress() public view returns(address) {
        return address(routerInstance);
    }

    function getTransitionInfo(address _token) public view returns(uint, uint, uint) {
        return (
            transitionInfo[_token][0],
            transitionInfo[_token][1],
            transitionInfo[_token][2]
        );
    }
}