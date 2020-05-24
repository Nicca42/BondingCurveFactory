pragma solidity 0.6.6;

import "./I_Curve.sol";
import "./I_Token.sol";
import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

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
  	using SafeMath for uint256;
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
        uint256 newSupply = supply.add(_tokens);

        uint256 a;
        uint256 b;
        uint256 c;
        (a, b, c) = I_Token(msg.sender).getCurve();

        return _getPrice(a, b, c, supply, newSupply);
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
        uint256 newSupply = supply.sub(_tokens);

        uint256 a;
        uint256 b;
        uint256 c;
        (a, b, c) = I_Token(msg.sender).getCurve();
 
        return _getPrice(a, b, c, newSupply, supply);
    }

	 function getEndPrice(
		uint256 _a,
		uint256 _b,
		uint256 _c,
		uint256 _threshold
	) 
		public
		pure	
		returns(uint256)
	{
		uint256 priceAtEnd = _getPrice(_a, _b, _c, _threshold, _threshold.add(1));

        return priceAtEnd;
	}

	function getEndCollateral(
		uint256 _a,
		uint256 _b,
		uint256 _c,
		uint256 _threshold
	) 
		public
		pure	
		returns(uint256)
	{
		uint256 collateralAtEnd = _getPrice(_a, _b, _c, 0, _threshold);

        return collateralAtEnd;
	}

	function _getPrice(
		uint256 _a,
        uint256 _b,
        uint256 _c,
		uint256 _from,
		uint256 _to
	) 
		internal 
		pure 
		returns(uint256)
	{
		uint aPrice = 0;

		if(_a != 0) {
			aPrice = ((_a.div(3)).mul((_to**3).sub(_from**3))).div(1e18);
		}
        
        uint256 price = aPrice + (_b.div(2)).mul(
			(_to**2).sub(_from**2)
		) + _c.mul(
			_to.sub(_from)
		);

        return price.div(1e18);
	}
}