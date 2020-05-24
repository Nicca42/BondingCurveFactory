pragma solidity 0.6.6;

import "./Token.sol";
import "./Curve.sol";
import "./MarketTransition.sol";
import "./IUniswapV2Router01.sol";
import "./BokkyPooBahsDateTimeLibrary.sol";

/**
  * @author Veronica Coutts @vonnie610 (twitter) @VeronicaLC (GitLab) 
  * @title  Bonding Curve Factory
  * @notice This curve contract enables an IBCO (Initial Bonding Curve Offering)
  *         as a mechanism to launch a token into the open market without having
  *         to raise the funds in a traditional manner.
  *         This product is a beta. Use at your own risk.
  */
contract BondingCurveFactory {
    using BokkyPooBahsDateTimeLibrary for uint256;

    IUniswapV2Router01 public uniswapRouter;
    Curve public activeCurve;
    MarketTransition public activeMarketTransition;

    address public owner;
    mapping(address => address[]) public deployedMarkets;

    event factorySetUp(address curve, address market);
    event marketCreated(address owner, address token, string name);

    modifier onlyOnwer() {
        require(msg.sender == owner, "Only owner can access");
        _;
    }

    /**
      * @param  _uniswapRouter: The address of the uniswap contract on the
      *         network this contract is deployed on. 
      */
    constructor(address _uniswapRouter) public {
        uniswapRouter = IUniswapV2Router01(_uniswapRouter);
        owner = msg.sender;

        activeCurve = new Curve();
        activeMarketTransition = new MarketTransition(address(uniswapRouter));

        emit factorySetUp(
            address(activeCurve),
            address(activeMarketTransition)
        );
    }

    /**
      * @return address: The address of the curve being used in this factory
      *         and all deployed tokens from this factory. 
      * @return address: The address of the market transition contract being
      *         used by this factory and all tokens deployed from this factory.
      */
    function getFactorySetUp() public view returns(address, address) {
        return (
            address(activeCurve),
            address(activeMarketTransition)
        );
    }
    
    /**
      * @param  _curveParameters: The curve "settings" that will be used in the 
      *         curve instance in order to determine the prices of the token. 
      *         For more information please see the curve contract docs. 
      * @param  _name: The name of the token.
      * @param  _symbol: The symbol for the token.
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
      * @return address: The address of the new token.
      */
    function createMarket(
        uint256[3] memory _curveParameters,
        string memory _name,
        string memory _symbol,
        address _underlyingCollateral,
        uint256 _tokenThreshold,
        uint256 _minimumTokenThreshold,
        uint256 _thresholdTimeout
    ) 
        public
        returns(address)
    {
        // TODO add checks for curve variables 
        /**
            a & b & C cant all be 0
            if a == 0 then b != 0 and visa versa 
            a cant be bigger than ... ?
          */
        Token newToken = new Token(
            address(activeCurve),
            address(activeMarketTransition),
            _curveParameters,
            _name,
            _symbol,
            _underlyingCollateral,
            _tokenThreshold,
            _minimumTokenThreshold,
            now.addMonths(_thresholdTimeout)
        );

        deployedMarkets[msg.sender].push(address(newToken));

        emit marketCreated(msg.sender, address(newToken), _name);

        return address(newToken);
    }

    /**
      * @param  _user: The address of the user
      * @return address[]: The addresses of any markets the user has deployed
      *         through this factory.
      */
    function getDeployedMarkets(
        address _user
    ) 
        public 
        view 
        returns(address[] memory) 
    {
        return deployedMarkets[msg.sender];
    }
}