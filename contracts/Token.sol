pragma solidity 0.6.6;

import "./I_Token.sol";
import "./I_Curve.sol";
import "./I_MarketTransition.sol";
import "./IUniswapV2Router01.sol";
import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

/**
  * @author Veronica Coutts 
  *         @vonnie610 (twitter) 
  *         @VeronicaLC (GitLab) 
  *         @nicca42 (GitHub)
  * @title  Token
  * @notice This token contract enables an IBCO (Initial Bonding Curve Offering)
  *         as a mechanism to launch a token into the open market without having
  *         to raise the funds in a traditional manner.
  *         This product is a beta. Use at your own risk.
  */
contract Token is ERC20 {
    // Curve set up
    uint256 public a;
    uint256 public b;
    uint256 public c;
    // Instances for contract interactions
    I_Curve public curveInstance;
    IERC20 public collateralInstance;
    I_MarketTransition public marketTransfterInstance;
    // Transition variables
    bool public transitionConditionsMet;
    bool public transitionCompleated;
    // Threshold collateral amount for open market transition
    uint256 public tokenThreshold;
    uint256 public minimumTokenThreshold;
    uint256 public thresholdTimeout;

    event transfering(uint collateral, uint tokensToMint);
    event transitionToFreeMarket(uint amountA, uint amountB, uint liquidity);
    event wtf(uint tokens, uint collateral, address sender);

    modifier freeMarket() {
        require(
            !transitionCompleated,
            "Market has transitioned to uniswap"
        );
        _;
    }

    /**
      * @param  _curveInstance: The address of the curve implementation. 
      * @param  _transiton: The address of the transition implementation.
      * @param  _curveParameters: The curve "settings" that will be used in the 
      *         curve instance in order to determine the prices of the token. 
      *         For more information please see the curve contract docs. 
      * @param  _name: The name of the token.
      * @param  _sybol: The symbol for the token.
      * @param  _underlyingCollateral: The addresss of the underlying collateral
      *         for the tokens. I.e the currency for the price of the token. 
      *         Recomended to use a stable coin such as DAI to ensure a stable
      *         price for your token. 
      * @param  _tokenThreshold: The transition threshold for the token in 
      *         tokens. As the value of the tokens is determanistic (with the 
      *         bonding curve enforcing a price) the threshold for when the 
      *         token can move to the free market can be expressed in tokens.
      * @param  _minimumTokenThreshold: This minimum token threshold is a safty
      *         catch for it the threshold is not met before expiry, this min
      *         threshold can still force the market into uniswap. If you only
      *         want to move acress at your threshold, simply set this vaule 
      *         to be the same as the threshold. 
      * @param  _thresholdTimeout: Once this timeout is reached the curve will 
      *         check against the min threshold for transition. When this 
      *         timeout is reached, the curve will operate as normal.
      */
    constructor(
        address _curve,
        address _transiton,
        uint256[3] memory _curveParameters,
        string memory _name,
        string memory _sybol,
        address _underlyingCollateral,
        uint256 _tokenThreshold,
        uint256 _minimumTokenThreshold,
        uint256 _thresholdTimeout
    )
        ERC20(
            _name,
            _sybol
        )
        public 
    {
        curveInstance = I_Curve(_curve);
        marketTransfterInstance = I_MarketTransition(_transiton);
        a = _curveParameters[0];
        b = _curveParameters[1];
        c = _curveParameters[2];
        collateralInstance = IERC20(_underlyingCollateral);

        tokenThreshold = _tokenThreshold;
        minimumTokenThreshold = _minimumTokenThreshold;
        thresholdTimeout = now + _thresholdTimeout;
    }

    /**
      * @param  _tokens: The number of tokens to buy.
      * @notice This function will check if the buy will push the token over its
      *         threshold, thus moving the token to uniswap. If the buy will 
      *         push the supply in excess of the threshold, only the tokens 
      *         needed to reach the threshold will be bought. 
      * @dev    This function will be blocked after the market has transitioned
      *         to uniswap.
      */
    function buy(uint256 _tokens) external freeMarket() {
        _transitionCheck(true, _tokens); 
        // The token can transition
        if(transitionConditionsMet) {
            if(
                this.totalSupply() + _tokens >= tokenThreshold
            ) {
                _tokens = tokenThreshold - this.totalSupply();

                _executeBuy(_tokens);
            }
            // Transitions market to uniswap 
            _transition();
        } else {
            // Transition threshold not met
            _executeBuy(_tokens);
        }
    }

    /**
      * @param  _tokens: The number fo tokens to sell.
      * @notice This function checks if the threshold has been reached, but 
      *         most importantly in the context of a sell is checking if the 
      *         token has reached its expiring time. 
      * @dev    This function will be blocked after the market has transitioned
      *         to uniswap.
      */
    function sell(uint256 _tokens) external freeMarket() {
        _transitionCheck(false, _tokens); 
        if(transitionConditionsMet) {
            _transition();
        } else {
            uint256 reward = getSellAmount(_tokens);

            require(
                this.balanceOf(msg.sender) >= _tokens,
                "Cannot sell more tokens than owned"
            );

            require(
                collateralInstance.transfer(
                    msg.sender,
                    reward
                ),
                "Transfering of collateral failed"
            );

            _burn(msg.sender, _tokens);
        }
    }

    /**
      * @notice Allows the market transition contract to set the transitioned 
      *         state of this token to true. 
      * @dev    Can only be called by the market transition contract.
      */
    function setTransition() external {
        require(
            msg.sender == address(marketTransfterInstance),
            "Only transitioning contract may mark transition compleate"
        );

        transitionCompleated = true;
    }

    /**
      * @param  _tokens: The number of tokens someone would like to buy.
      * @return uint256: The cost (in collateral) for the number of tokens.
      * @dev    This function uses the curve library in order to determine the 
      *         price of the token. 
      */
    function getBuyCost(uint256 _tokens) public view returns(uint256) {
        return curveInstance.getBuyPrice(_tokens);
    } 

    /**
      * @param  _tokens: The number of tokens someone would like to sell.
      * @return uint256: The reward (in collateral) for the number of tokens.
      * @dev    This function uses the curve library in order to determine the 
      *         price of the token. 
      */
    function getSellAmount(uint256 _tokens) public view returns(uint256) {
        if(this.totalSupply() == 0) {
            return 0;
        } else {
            return curveInstance.getSellAmount(_tokens);
        }
    } 
    
    /**
      * @notice This function returns the variables that determine the behaviour
      *         of the curve. 
      * @dev    The variables returned are used in the curves calculations. 
      *         Below is the current version of the equation being used:
      *         a/3(x_1^3 - x_0^3) + b/2(x_1^2 - x_0^2) + c(x_1 - x_0)
      * @return uint256: a
      * @return uint256: b
      * @return uint256: c
      */
    function getCurve() external view returns (
        uint256,
        uint256,
        uint256
    ) {
        return (a, b, c);
    }

    /**
      * @return address: The address of the collateral being used for this 
      *         token.
      */
    function getCollateralInstance() external view returns(address) {
        return address(collateralInstance);
    }

    /**
      * @return bool: If the transition condition has been met. I.e Are there 
      *         enough tokens to transition the token into a uniswap market.
      * @return bool: If the token has transitioned. This can only be set by the
      *         market transition contract.
      */
    function getTokenStatus() external view returns(bool, bool) {
        return (
            transitionConditionsMet,
            transitionCompleated
        );
    }

    /**
      * @notice Returns the transition information for this token. 
      * @return uint256: The token threshold. The number of tokens that need to
      *         be bought in order to push the token into the open market.
      * @return uint256: The minimum threshold for transition. If the contract
      *         times out and is above this minimum threshold the contract will 
      *         still transition.
      * @return uint256: The timeout threshold. If the token times out then only 
      *         the minimum threshold is needed to be met to transition the 
      *         market. The market will not stop or break when the timeout 
      *         happens.
      */
    function getTransitionThresholds() 
        external 
        view 
        returns(
            uint256,
            uint256,
            uint256
        ) 
    {
        return (
            tokenThreshold,
            minimumTokenThreshold,
            thresholdTimeout
        );
    }

    /**
      * @param  _tokens: The number of tokens to be bought. 
      * @notice This function executes the buy of tokens from a user. This was
      *         done for readability.
      * @dev    This function can only be called internally.
      */
    function _executeBuy(uint _tokens) internal {
        uint256 cost = getBuyCost(_tokens);

        require(
            collateralInstance.allowance(
                msg.sender, address(this)
            ) >= cost,
            "User has not approved contract for token cost amount"
        );

        require(
            collateralInstance.transferFrom(
                msg.sender,
                address(this),
                cost
            ),
            "Transfering of collateral failed"
        );

        _mint(msg.sender, _tokens);
    }

    /**
      * @param  _buy: true if the check is being called by the buy function. 
      *         False if the check is called from sell.
      * @param  _tokens: The number of tokens being bought or sold.
      * @notice Checks if the transition threshold has been met, if the timeout 
      *         has been exceeded and if so if the minimum threshold has been 
      *         reached.
      */
    function _transitionCheck(bool _buy, uint _tokens) internal {
        uint newSupply;
        // Sets new supply according to buy or sell
        if(_buy) {
            newSupply = this.totalSupply() + _tokens;
            // Checks if main threshold has been reached
            if(newSupply >= tokenThreshold) {
                transitionConditionsMet = true;
            } 
        } else {
            newSupply = this.totalSupply() - _tokens;
        }
        
        if(now >= thresholdTimeout) {
            // Time has expired
            if(newSupply >= minimumTokenThreshold) {
                transitionConditionsMet = true;
            } 
        }
    }

    /**
      * @notice Contains the functionality to transition the token to the open
      *         market using the market transtition contract. 
      * @dev    Requires that the market has reached the transition state.
      *         Transfers collateral into the market transition contract which
      *         then creates the uniswap market.
      */
    function _transition() internal {
        require(
            transitionConditionsMet,
            "Token has not met requirements for free market transition"
        );

        address router = marketTransfterInstance.getRouterAddress();
        uint256 tokensToMint = marketTransfterInstance.getTokensToMint();
        _mint(address(marketTransfterInstance), tokensToMint);
        // Approves 
        require(
            collateralInstance.transfer(
                address(marketTransfterInstance),
                collateralInstance.balanceOf(address(this))
            ),
            "Transfer of collateral failed"
        );

        marketTransfterInstance.transition();
    }
}