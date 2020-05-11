pragma solidity 0.6.6;

import "./I_Token.sol";

contract LinearCurve {
    /**
      * Linear curve: y = mx + c
      * Linear curve: price = gradient*supply + startingPrice
      */

    function getBuyPrice(
        uint256 _tokens
    )
        public
        view
        returns(uint256)
    {
        uint256 supply = I_Token(msg.sender).getSupply();
        uint256 newSupply = supply + _tokens;

        uint256 a;
        uint256 b;
        uint256 c;
        (a, b, c) = I_Token(msg.sender).getCurve();
        
        uint256 price = (a/3)*(newSupply**3 - supply**3) + (b/2)*(newSupply**2 - supply**2) + c*(newSupply - supply);

        return price;
    }

    function getTokensForPrice(
        uint256 _price
    )
        public
        pure
        returns(uint256)
    {

    }
}