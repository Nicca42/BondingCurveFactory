pragma solidity 0.6.6;

import "./I_Token.sol";

contract Token is I_Token {

    constructor(uint256 _totalSupply) public {

    }

    function getSupply() override(I_Token) external view returns(uint256) {

    }
    
    function getCurve() override(I_Token) external view returns (
        uint256,
        uint256,
        uint256
    ) {
        
    }
}