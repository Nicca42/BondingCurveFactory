pragma solidity 0.6.6;

import "./I_Token.sol";
import "./I_Curve.sol";
import "./I_MarketTransition.sol";
import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

contract Token is ERC20 {
    uint256 public maxSupply;
    uint256 public a;
    uint256 public b;
    uint256 public c;
    I_Curve public curveInstance;
    IERC20 public collateralInstance;
    I_MarketTransition public transfterInstance;

    bool public transitionConditionsMet;
    bool public transitionCompleated;
    // Threshold collateral amount for open market transition
    uint256 public collateralThreshold;

    event transfering(uint collateral, uint tokensToMint);

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
        uint256 _maxSupply,
        uint256[3] memory _curveParameters,
        string memory _name,
        string memory _sybol,
        address _underlyingCollateral,
        uint256 _collateralThreshold
    )
        ERC20(
            _name,
            _sybol
        )
        public 
    {
        curveInstance = I_Curve(_curveInstance);
        transfterInstance = I_MarketTransition(_transiton);
        maxSupply = _maxSupply;
        a = _curveParameters[0];
        b = _curveParameters[1];
        c = _curveParameters[2];
        collateralInstance = IERC20(_underlyingCollateral);

        collateralThreshold = _collateralThreshold;
    }

    function buy(uint256 _tokens) external freeMarket() {
        _transitionCheck(); 
        // TODO 1. if your buy will push the limit you should be able to
        // buy up untill the limit (to met the amount so that it transitions)
        // and then it will not use any funds over that
        // and possibly removes exes approval (just to set a good stanard)
        // if(supply+_tokens => transitionCheck == true) {then buy till limit}
        if(transitionConditionsMet) {
            transition();
        } else {
            uint256 cost = getBuyCost(_tokens);

            require(
                collateralInstance.allowance(msg.sender, address(this)) >= cost,
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
    }

    function sell(uint256 _tokens) external freeMarket() {
        _transitionCheck(); 
        if(transitionConditionsMet) {
            transition();
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

    function transition() public {
        // Calls transiton check to update state
        _transitionCheck();

        require(
            transitionConditionsMet,
            "Token has not met requirements for free market transition"
        );

        address router = transfterInstance.getRouterAddress();
        // Approves 
        require(
            collateralInstance.approve(
                router,
                collateralInstance.balanceOf(address(this))
            ),
            "Approval of collateral failed"
        );

        uint256 tokensToMint = transfterInstance.getTokensToMint();
        _mint(address(this), tokensToMint);

        require(
            this.approve(
                router,
                tokensToMint
            ),
            "Approval of minted tokens failed"
        );

        //TODO make mt 
        transfterInstance.transition(address(this));

        emit transfering(
            collateralInstance.balanceOf(address(this)), 
            tokensToMint
        );
    }

    function setTransition() external {
        require(
            msg.sender == address(transfterInstance),
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

    function _transitionCheck() internal {
        if(
            collateralThreshold <= 
            this.totalSupply()
        ) {
            transitionConditionsMet = true;
        }

        //TODO add checks for various other conditions:
        /**
          ✅ collateral threshold 
          ⚙️ collateral timeout
          ⚙️ minimum collateral threashold 
          */
    }

    function getTokenStatus() 
        external 
        view 
        returns(
            bool,
            bool
        )   
    {
        //TODO also return additional checks
        return (
            transitionConditionsMet,
            transitionCompleated
        );
    }

    //TODO update interface with all functions
}