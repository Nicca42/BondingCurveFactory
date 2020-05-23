pragma solidity 0.6.6;

import "./I_Curve.sol";
import "./I_Token.sol";

//TODO update to use safe maths

/**
  * @author Veronica Coutts @vonnie610 (twitter) @VeronicaLC (GitLab) 
  * @title  Curve
  * @notice This curve contract enables an IBCO (Initial Bonding Curve Offering)
  *         as a mechanism to launch a token into the open market without having
  *         to raise the funds in a traditional manner.
  *         This product is a beta. Use at your own risk.
  */
contract Curve is I_Curve {
    /**
      * This curve uses the following formula:
      * a/3(x_1^3 - x_0^3) + b/2(x_1^2 - x_0^2) + c(x_1 - x_0)
      * The vaiables (a, b & c) are pulled from the token (msg.sender).
      * x_1 and x_0 are the supply and the supply +/- the amount of tokens being
      * bought and sold. 
      */

    /**
      * @param  _tokens: The number of tokens being bought.
      * @return uint256: The cost price of the number of tokens in collateral.
      */
    function getBuyPrice(
        uint256 _tokens
    )
        override(I_Curve)
        public
        view
        returns(uint256)
    {
        uint256 supply = I_Token(msg.sender).totalSupply();
        uint256 newSupply = supply + _tokens;

        uint256 a;
        uint256 b;
        uint256 c;
        (a, b, c) = I_Token(msg.sender).getCurve();
        
        uint256 price = (a/(3))*(newSupply**3 - supply**3) 
                        + (b/2)*(newSupply**2 - supply**2) 
                        + c*(newSupply - supply);

        return price/1e18;
    }

    /**
      * @param  _tokens: The number of tokens being sold.
      * @return uint256: The sell price of the number of tokens in collateral.
      */
    function getSellAmount(
        uint256 _tokens
    )
        override(I_Curve)
        public
        view
        returns(uint256) 
    {
        uint256 supply = I_Token(msg.sender).totalSupply();
        uint256 newSupply = supply - _tokens;

        uint256 a;
        uint256 b;
        uint256 c;
        (a, b, c) = I_Token(msg.sender).getCurve();
        
        uint256 price = (a/3)*(supply**3 - newSupply**3) 
                        + (b/2)*(supply**2 - newSupply**2) 
                        + c*(supply - newSupply);

        return price/1e18;
    }
}