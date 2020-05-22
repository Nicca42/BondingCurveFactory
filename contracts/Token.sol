pragma solidity 0.6.6;

import "./I_Token.sol";
import "./I_Curve.sol";
import "./I_MarketTransition.sol";
import "./IUniswapV2Router01.sol";
import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";


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

    constructor(
        address _curveInstance,
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
        curveInstance = I_Curve(_curveInstance);
        marketTransfterInstance = I_MarketTransition(_transiton);
        a = _curveParameters[0];
        b = _curveParameters[1];
        c = _curveParameters[2];
        collateralInstance = IERC20(_underlyingCollateral);

        tokenThreshold = _tokenThreshold;
        minimumTokenThreshold = _minimumTokenThreshold;
        thresholdTimeout = now + _thresholdTimeout;
    }

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

    function setTransition() external {
        require(
            msg.sender == address(marketTransfterInstance),
            "Only transitioning contract may mark transition compleate"
        );

        transitionCompleated = true;
    }

    function getBuyCost(uint256 _tokens) public view returns(uint256) {
        return curveInstance.getBuyPrice(_tokens);
    } 

    function getSellAmount(uint256 _tokens) public view returns(uint256) {
        if(this.totalSupply() == 0) {
            return 0;
        } else {
            return curveInstance.getSellAmount(_tokens);
        }
    } 
    
    function getCurve() external view returns (
        uint256,
        uint256,
        uint256
    ) {
        return (a, b, c);
    }

    function getCollateralInstance() external view returns(address) {
        return address(collateralInstance);
    }

    function getTokenStatus() external view returns(bool, bool) {
        return (
            transitionConditionsMet,
            transitionCompleated
        );
    }

    function getTransitionThresholds() external view returns(uint256,uint256,uint256) {
        return (
            tokenThreshold,
            minimumTokenThreshold,
            thresholdTimeout
        );
    }

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

    function _transitionCheck(bool _buy, uint _tokensToMint) internal {
        uint newSupply;
        // Sets new supply according to buy or sell
        if(_buy) {
            newSupply = this.totalSupply() + _tokensToMint;
            // Checks if main threshold has been reached
            if(newSupply >= tokenThreshold) {
                transitionConditionsMet = true;
            } 
        } else {
            newSupply = this.totalSupply() - _tokensToMint;
        }
        
        if(now >= thresholdTimeout) {
            // Time has expired
            if(newSupply >= minimumTokenThreshold) {
                transitionConditionsMet = true;
            } 
        }
    }

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