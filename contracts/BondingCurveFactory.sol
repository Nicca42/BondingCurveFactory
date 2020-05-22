pragma solidity 0.6.6;

import "./Token.sol";
import "./Curve.sol";
import "./MarketTransition.sol";
import "./IUniswapV2Router01.sol";

contract BondingCurveFactory {
    address public owner;
    bool public setUp;

    IUniswapV2Router01 public uniswapRouter;
    Curve public activeCurve;
    MarketTransition public activeMarketTransition;

    mapping(address => address[]) public deployedMarkets;

    event factorySetUp(address curve, address market);
    event marketCreated(address owner, address token, string name);

    modifier onlyOnwer() {
        require(msg.sender == owner, "Only owner can access");
        _;
    }

    constructor(address _uniswapRouter) public {
        uniswapRouter = IUniswapV2Router01(_uniswapRouter);
        owner = msg.sender;
    }

    function setUpFactory() public onlyOnwer() {
        require(
            !setUp,
            "Factory has already been set up"
        );

        activeCurve = new Curve();
        activeMarketTransition = new MarketTransition(address(uniswapRouter));

        emit factorySetUp(
            address(activeCurve),
            address(activeMarketTransition)
        );

        setUp = true;
    }

    function getFactorySetUp() public view returns(address, address) {
        return (
            address(activeCurve),
            address(activeMarketTransition)
        );
    }
    
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
        Token newToken = new Token(
            address(activeCurve),
            address(activeMarketTransition),
            _curveParameters,
            _name,
            _symbol,
            _underlyingCollateral,
            _tokenThreshold,
            _minimumTokenThreshold,
            _thresholdTimeout
        );

        deployedMarkets[msg.sender].push(address(newToken));

        emit marketCreated(msg.sender, address(newToken), _name);

        return address(newToken);
    }

    function getDeployedMarkets(address _user) public view returns(address[] memory) {
        return deployedMarkets[msg.sender];
    }
}