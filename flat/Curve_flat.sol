pragma solidity 0.6.6;

interface I_Curve {
    function getBuyPrice(
        uint256 _tokens
    )
        external
        view
        returns(uint256);
    
    function getSellAmount(
        uint256 _tokens
    )
        external
        view
        returns(uint256);
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface I_Token is IERC20 {

    function buy(uint256 _tokens) external;
    function sell(uint256 _tokens) external;
    function setTransition() external;
    function getBuyCost(uint256 _tokens) external view returns(uint256);
    function getSellAmount(uint256 _tokens) external view returns(uint256);
    function getCurve() external view returns (
        uint256,
        uint256,
        uint256
    );
    function getCollateralInstance() external view returns(address);
    function getTokenStatus() 
        external 
        view 
        returns(
            bool,
            bool
        );
    function getTransitionThresholds() external view returns(uint256,uint256,uint256);
}

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}




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

		uint aPrice = 0;

		if(a != 0) {
			aPrice = ((a.div(3)).mul((newSupply**3).sub(supply**3))).div(1e18);
		}
        
        uint256 price = aPrice + (b.div(2)).mul(
			(newSupply**2).sub(supply**2)
		) + c.mul(
			newSupply.sub(supply)
		);

        return price.div(1e18);
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
		uint256 supply = 0;
        uint256 newSupply = _threshold;

		uint aPrice = 0;

		if(_a != 0) {
			aPrice = ((_a.div(3)).mul((newSupply**3).sub(supply**3))).div(1e18);
		}
        
        uint256 price = aPrice + (_b.div(2)).mul(
			(newSupply**2).sub(supply**2)
		) + _c.mul(
			newSupply.sub(supply)
		);

        return price.div(1e18);
	}
}