pragma solidity 0.6.6;

import "./I_Token.sol";
import "./I_Curve.sol";

contract Token is I_Token {
    uint256 public totalSupply;
    uint256 public currentSupply;
    uint256 public a;
    uint256 public b;
    uint256 public c;
    I_Curve public curveInstance;

    constructor(
        address _curveInstance,
        uint256 _totalSupply,
        uint256 _a,
        uint256 _b,
        uint256 _c
    ) 
        public 
    {
        curveInstance = I_Curve(_curveInstance);
        totalSupply = _totalSupply;
        currentSupply = 0;
        a = _a;
        b = _b;
        c = _c;
    }

    function getBuyCost(uint256 _tokens) public view returns(uint256) {
        return curveInstance.getBuyPrice(_tokens);
    } 

    function getSupply() override(I_Token) external view returns(uint256) {
        return currentSupply;
    }
    
    function getCurve() override(I_Token) external view returns (
        uint256,
        uint256,
        uint256
    ) {
        return (a, b, c);
    }
}