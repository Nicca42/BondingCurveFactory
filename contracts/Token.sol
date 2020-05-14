pragma solidity 0.6.6;

import "./I_Token.sol";
import "./I_Curve.sol";
import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

contract Token is ERC20 {
    uint256 public maxSupply;
    uint256 public a;
    uint256 public b;
    uint256 public c;
    I_Curve public curveInstance;
    IERC20 public collateralInstance;

    constructor(
        address _curveInstance,
        uint256 _maxSupply,
        uint256[3] memory _curveParameters,
        string memory _name,
        string memory _sybol,
        address _underlyingCollateral
    )
        ERC20(
            _name,
            _sybol
        )
        public 
    {
        curveInstance = I_Curve(_curveInstance);
        maxSupply = _maxSupply;
        a = _curveParameters[0];
        b = _curveParameters[1];
        c = _curveParameters[2];
        collateralInstance = IERC20(_underlyingCollateral);
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

    function buy(uint256 _tokens) external {
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

    function sell(uint256 _tokens) external {
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