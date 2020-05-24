pragma solidity 0.6.6;

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

interface I_MarketTransition {

    function transition() external;
    function getTokensToMint() external returns(uint256);
    function getRouterAddress() external view returns(address);
    function getTransitionInfo(address _token) external view returns(uint, uint, uint);
    function getMonthsFutureTimestamp(uint256 _months) external view returns(uint256);
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
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


/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}





/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20MinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}







/**
  * @author Veronica Coutts @vonnie610 (twitter) @VeronicaLC (GitLab) 
  * @title  Token
  * @notice This token contract enables an IBCO (Initial Bonding Curve Offering)
  *         as a mechanism to launch a token into the open market without having
  *         to raise the funds in a traditional manner.
  *         This product is a beta. Use at your own risk.
  */
contract Token is ERC20 {
    // Curve set up
    uint256 public a;
    uint256 public b;
    uint256 public c;
    // Instances for contract interactions
    I_Curve public curveInstance;
    IERC20 public collateralInstance;
    I_MarketTransition public marketTransfterInstance;
    // Transition variables
    bool public transitionConditionsMet;
    bool public transitionCompleated;
    // Threshold collateral amount for open market transition
    uint256 public tokenThreshold;
    uint256 public minimumTokenThreshold;
    uint256 public thresholdTimeout;

    modifier freeMarket() {
        require(
            !transitionCompleated,
            "Market has transitioned to uniswap"
        );
        _;
    }

    /**
      * @param  _curve: The address of the curve implementation. 
      * @param  _transiton: The address of the transition implementation.
      * @param  _curveParameters: The curve "settings" that will be used in the 
      *         curve instance in order to determine the prices of the token. 
      *         For more information please see the curve contract docs. 
      * @param  _name: The name of the token.
      * @param  _sybol: The symbol for the token.
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
      */
    constructor(
        address _curve,
        address _transiton,
        uint256[3] memory _curveParameters,
        string memory _name,
        string memory _sybol,
        address _underlyingCollateral,
        uint256 _tokenThreshold,
        uint256 _minimumTokenThreshold,
        uint256 _thresholdTimeout
    )
        ERC20(
            _name,
            _sybol
        )
        public 
    {
        curveInstance = I_Curve(_curve);
        marketTransfterInstance = I_MarketTransition(_transiton);
        a = _curveParameters[0];
        b = _curveParameters[1];
        c = _curveParameters[2];
        collateralInstance = IERC20(_underlyingCollateral);

        tokenThreshold = _tokenThreshold;
        minimumTokenThreshold = _minimumTokenThreshold;
        thresholdTimeout = now + _thresholdTimeout;
    }

    /**
      * @param  _tokens: The number of tokens to buy.
      * @notice This function will check if the buy will push the token over its
      *         threshold, thus moving the token to uniswap. If the buy will 
      *         push the supply in excess of the threshold, only the tokens 
      *         needed to reach the threshold will be bought. 
      * @dev    This function will be blocked after the market has transitioned
      *         to uniswap.
      */
    function buy(uint256 _tokens) external freeMarket() {
        _transitionCheck(true, _tokens); 
        // The token can transition
        if(transitionConditionsMet) {
            // TODO check what happens here on min threshold
            if(
                this.totalSupply() + _tokens >= tokenThreshold
            ) {
                _tokens = tokenThreshold - this.totalSupply();

                _executeBuy(_tokens);
            }
            // Transitions market to uniswap 
            _transition();
        } else {
            // Transition threshold not met
            _executeBuy(_tokens);
        }
    }

    /**
      * @param  _tokens: The number fo tokens to sell.
      * @notice This function checks if the threshold has been reached, but 
      *         most importantly in the context of a sell is checking if the 
      *         token has reached its expiring time. 
      * @dev    This function will be blocked after the market has transitioned
      *         to uniswap.
      */
    function sell(uint256 _tokens) external freeMarket() {
        _transitionCheck(false, _tokens); 
        if(transitionConditionsMet) {
            _transition();
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

    /**
      * @notice Allows the market transition contract to set the transitioned 
      *         state of this token to true. 
      * @dev    Can only be called by the market transition contract.
      */
    function setTransition() external {
        require(
            msg.sender == address(marketTransfterInstance),
            "Only transitioning contract may mark transition compleate"
        );

        transitionCompleated = true;
    }

    /**
      * @param  _tokens: The number of tokens someone would like to buy.
      * @return uint256: The cost (in collateral) for the number of tokens.
      * @dev    This function uses the curve library in order to determine the 
      *         price of the token. 
      */
    function getBuyCost(uint256 _tokens) public view returns(uint256) {
        return curveInstance.getBuyPrice(_tokens);
    } 

    /**
      * @param  _tokens: The number of tokens someone would like to sell.
      * @return uint256: The reward (in collateral) for the number of tokens.
      * @dev    This function uses the curve library in order to determine the 
      *         price of the token. 
      */
    function getSellAmount(uint256 _tokens) public view returns(uint256) {
        if(this.totalSupply() == 0) {
            return 0;
        } else {
            return curveInstance.getSellAmount(_tokens);
        }
    } 
    
    /**
      * @notice This function returns the variables that determine the behaviour
      *         of the curve. 
      * @dev    The variables returned are used in the curves calculations. 
      *         Below is the current version of the equation being used:
      *         a/3(x_1^3 - x_0^3) + b/2(x_1^2 - x_0^2) + c(x_1 - x_0)
      * @return uint256: a
      * @return uint256: b
      * @return uint256: c
      */
    function getCurve() external view returns (
        uint256,
        uint256,
        uint256
    ) {
        return (a, b, c);
    }

    /**
      * @return address: The address of the collateral being used for this 
      *         token.
      */
    function getCollateralInstance() external view returns(address) {
        return address(collateralInstance);
    }

    /**
      * @return bool: If the transition condition has been met. I.e Are there 
      *         enough tokens to transition the token into a uniswap market.
      * @return bool: If the token has transitioned. This can only be set by the
      *         market transition contract.
      */
    function getTokenStatus() external view returns(bool, bool) {
        return (
            transitionConditionsMet,
            transitionCompleated
        );
    }

    /**
      * @notice Returns the transition information for this token. 
      * @return uint256: The token threshold. The number of tokens that need to
      *         be bought in order to push the token into the open market.
      * @return uint256: The minimum threshold for transition. If the contract
      *         times out and is above this minimum threshold the contract will 
      *         still transition.
      * @return uint256: The timeout threshold. If the token times out then only 
      *         the minimum threshold is needed to be met to transition the 
      *         market. The market will not stop or break when the timeout 
      *         happens.
      */
    function getTransitionThresholds() 
        external 
        view 
        returns(
            uint256,
            uint256,
            uint256
        ) 
    {
        return (
            tokenThreshold,
            minimumTokenThreshold,
            thresholdTimeout
        );
    }

    /**
      * @param  _tokens: The number of tokens to be bought. 
      * @notice This function executes the buy of tokens from a user. This was
      *         done for readability.
      * @dev    This function can only be called internally.
      */
    function _executeBuy(uint _tokens) internal {
        uint256 cost = getBuyCost(_tokens);

        require(
            collateralInstance.allowance(
                msg.sender, address(this)
            ) >= cost,
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

    /**
      * @param  _buy: true if the check is being called by the buy function. 
      *         False if the check is called from sell.
      * @param  _tokens: The number of tokens being bought or sold.
      * @notice Checks if the transition threshold has been met, if the timeout 
      *         has been exceeded and if so if the minimum threshold has been 
      *         reached.
      */
    function _transitionCheck(bool _buy, uint _tokens) internal {
        uint newSupply;
        // Sets new supply according to buy or sell
        if(_buy) {
            newSupply = this.totalSupply() + _tokens;
            // Checks if main threshold has been reached
            if(newSupply >= tokenThreshold) {
                transitionConditionsMet = true;
            } 
        } else {
            newSupply = this.totalSupply() - _tokens;
        }
        
        if(now >= thresholdTimeout) {
            // Time has expired
            if(newSupply >= minimumTokenThreshold) {
                transitionConditionsMet = true;
            } 
        }
    }

    /**
      * @notice Contains the functionality to transition the token to the open
      *         market using the market transtition contract. 
      * @dev    Requires that the market has reached the transition state.
      *         Transfers collateral into the market transition contract which
      *         then creates the uniswap market.
      */
    function _transition() internal {
        require(
            transitionConditionsMet,
            "Token has not met requirements for free market transition"
        );

        address router = marketTransfterInstance.getRouterAddress();
        uint256 tokensToMint = marketTransfterInstance.getTokensToMint();
        _mint(address(marketTransfterInstance), tokensToMint);
        // Approves 
        require(
            collateralInstance.transfer(
                address(marketTransfterInstance),
                collateralInstance.balanceOf(address(this))
            ),
            "Transfer of collateral failed"
        );

        marketTransfterInstance.transition();
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

// ----------------------------------------------------------------------------
// BokkyPooBah's DateTime Library v1.00
//
// A gas-efficient Solidity date and time library
//
// https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary
//
// Tested date range 1970/01/01 to 2345/12/31
//
// Conventions:
// Unit      | Range         | Notes
// :-------- |:-------------:|:-----
// timestamp | >= 0          | Unix timestamp, number of seconds since 1970/01/01 00:00:00 UTC
// year      | 1970 ... 2345 |
// month     | 1 ... 12      |
// day       | 1 ... 31      |
// hour      | 0 ... 23      |
// minute    | 0 ... 59      |
// second    | 0 ... 59      |
// dayOfWeek | 1 ... 7       | 1 = Monday, ..., 7 = Sunday
//
//
// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2018.
//
// GNU Lesser General Public License 3.0
// https://www.gnu.org/licenses/lgpl-3.0.en.html
// ----------------------------------------------------------------------------

library BokkyPooBahsDateTimeLibrary {

    uint256  constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint256  constant SECONDS_PER_HOUR = 60 * 60;
    uint256  constant SECONDS_PER_MINUTE = 60;
    int256 constant OFFSET19700101 = 2440588;

    uint256  constant DOW_MON = 1;
    uint256  constant DOW_TUE = 2;
    uint256  constant DOW_WED = 3;
    uint256  constant DOW_THU = 4;
    uint256  constant DOW_FRI = 5;
    uint256  constant DOW_SAT = 6;
    uint256  constant DOW_SUN = 7;

    // ------------------------------------------------------------------------
    // Calculate the number of days from 1970/01/01 to year/month/day using
    // the date conversion algorithm from
    //   http://aa.usno.navy.mil/faq/docs/JD_Formula.php
    // and subtracting the offset 2440588 so that 1970/01/01 is day 0
    //
    // days = day
    //      - 32075
    //      + 1461 * (year + 4800 + (month - 14) / 12) / 4
    //      + 367 * (month - 2 - (month - 14) / 12 * 12) / 12
    //      - 3 * ((year + 4900 + (month - 14) / 12) / 100) / 4
    //      - offset
    // ------------------------------------------------------------------------
    function _daysFromDate(uint256  year, uint256  month, uint256  day) internal pure returns (uint256  _days) {
        require(year >= 1970, "Epoch error");
        int256 _year = int256(year);
        int256 _month = int256(month);
        int256 _day = int256(day);

        int256 __days = _day
          - 32075
          + 1461 * (_year + 4800 + (_month - 14) / 12) / 4
          + 367 * (_month - 2 - (_month - 14) / 12 * 12) / 12
          - 3 * ((_year + 4900 + (_month - 14) / 12) / 100) / 4
          - OFFSET19700101;

        _days = uint256 (__days);
    }

    // ------------------------------------------------------------------------
    // Calculate year/month/day from the number of days since 1970/01/01 using
    // the date conversion algorithm from
    //   http://aa.usno.navy.mil/faq/docs/JD_Formula.php
    // and adding the offset 2440588 so that 1970/01/01 is day 0
    //
    // int256 L = days + 68569 + offset
    // int256 N = 4 * L / 146097
    // L = L - (146097 * N + 3) / 4
    // year = 4000 * (L + 1) / 1461001
    // L = L - 1461 * year / 4 + 31
    // month = 80 * L / 2447
    // dd = L - 2447 * month / 80
    // L = month / 11
    // month = month + 2 - 12 * L
    // year = 100 * (N - 49) + year + L
    // ------------------------------------------------------------------------
    function _daysToDate(uint256  _days) internal pure returns (uint256  year, uint256  month, uint256  day) {
        int256 __days = int256(_days);

        int256 L = __days + 68569 + OFFSET19700101;
        int256 N = 4 * L / 146097;
        L = L - (146097 * N + 3) / 4;
        int256 _year = 4000 * (L + 1) / 1461001;
        L = L - 1461 * _year / 4 + 31;
        int256 _month = 80 * L / 2447;
        int256 _day = L - 2447 * _month / 80;
        L = _month / 11;
        _month = _month + 2 - 12 * L;
        _year = 100 * (N - 49) + _year + L;

        year = uint256 (_year);
        month = uint256 (_month);
        day = uint256 (_day);
    }

    function timestampFromDate(uint256  year, uint256  month, uint256  day) internal pure returns (uint256  timestamp) {
        timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY;
    }
    function timestampFromDateTime(uint256  year, uint256  month, uint256  day, uint256  hour, uint256  minute, uint256  second) internal pure returns (uint256  timestamp) {
        timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + hour * SECONDS_PER_HOUR + minute * SECONDS_PER_MINUTE + second;
    }
    function timestampToDate(uint256  timestamp) internal pure returns (uint256  year, uint256  month, uint256  day) {
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function timestampToDateTime(uint256  timestamp) internal pure returns (uint256  year, uint256  month, uint256  day, uint256  hour, uint256  minute, uint256  second) {
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        uint256  secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
        secs = secs % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
        second = secs % SECONDS_PER_MINUTE;
    }

    function isValidDate(uint256  year, uint256  month, uint256  day) internal pure returns (bool valid) {
        if (year >= 1970 && month > 0 && month <= 12) {
            uint256  daysInMonth = _getDaysInMonth(year, month);
            if (day > 0 && day <= daysInMonth) {
                valid = true;
            }
        }
    }
    function isValidDateTime(uint256  year, uint256  month, uint256  day, uint256  hour, uint256  minute, uint256  second) internal pure returns (bool valid) {
        if (isValidDate(year, month, day)) {
            if (hour < 24 && minute < 60 && second < 60) {
                valid = true;
            }
        }
    }
    function isLeapYear(uint256  timestamp) internal pure returns (bool leapYear) {
        uint256  year;
        uint256  month;
        uint256  day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        leapYear = _isLeapYear(year);
    }
    function _isLeapYear(uint256  year) internal pure returns (bool leapYear) {
        leapYear = ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0);
    }
    function isWeekDay(uint256  timestamp) internal pure returns (bool weekDay) {
        weekDay = getDayOfWeek(timestamp) <= DOW_FRI;
    }
    function isWeekEnd(uint256  timestamp) internal pure returns (bool weekEnd) {
        weekEnd = getDayOfWeek(timestamp) >= DOW_SAT;
    }
    function getDaysInMonth(uint256  timestamp) internal pure returns (uint256  daysInMonth) {
        uint256  year;
        uint256  month;
        uint256  day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        daysInMonth = _getDaysInMonth(year, month);
    }
    function _getDaysInMonth(uint256  year, uint256  month) internal pure returns (uint256  daysInMonth) {
        if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
            daysInMonth = 31;
        } else if (month != 2) {
            daysInMonth = 30;
        } else {
            daysInMonth = _isLeapYear(year) ? 29 : 28;
        }
    }
    // 1 = Monday, 7 = Sunday
    function getDayOfWeek(uint256  timestamp) internal pure returns (uint256  dayOfWeek) {
        uint256  _days = timestamp / SECONDS_PER_DAY;
        dayOfWeek = (_days + 3) % 7 + 1;
    }

    function getYear(uint256  timestamp) internal pure returns (uint256  year) {
        uint256  month;
        uint256  day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getMonth(uint256  timestamp) internal pure returns (uint256  month) {
        uint256  year;
        uint256  day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getDay(uint256  timestamp) internal pure returns (uint256  day) {
        uint256  year;
        uint256  month;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getHour(uint256  timestamp) internal pure returns (uint256  hour) {
        uint256  secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
    }
    function getMinute(uint256  timestamp) internal pure returns (uint256  minute) {
        uint256  secs = timestamp % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
    }
    function getSecond(uint256  timestamp) internal pure returns (uint256  second) {
        second = timestamp % SECONDS_PER_MINUTE;
    }

    function addYears(uint256  timestamp, uint256  _years) internal pure returns (uint256  newTimestamp) {
        uint256  year;
        uint256  month;
        uint256  day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        year += _years;
        uint256  daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        assert(newTimestamp >= timestamp);
    }
    function addMonths(uint256  timestamp, uint256  _months) internal pure returns (uint256  newTimestamp) {
        uint256  year;
        uint256  month;
        uint256  day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        month += _months;
        year += (month - 1) / 12;
        month = (month - 1) % 12 + 1;
        uint256  daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        assert(newTimestamp >= timestamp);
    }
    function addDays(uint256  timestamp, uint256  _days) internal pure returns (uint256  newTimestamp) {
        newTimestamp = timestamp + _days * SECONDS_PER_DAY;
        assert(newTimestamp >= timestamp);
    }
    function addHours(uint256  timestamp, uint256  _hours) internal pure returns (uint256  newTimestamp) {
        newTimestamp = timestamp + _hours * SECONDS_PER_HOUR;
        assert(newTimestamp >= timestamp);
    }
    function addMinutes(uint256  timestamp, uint256  _minutes) internal pure returns (uint256  newTimestamp) {
        newTimestamp = timestamp + _minutes * SECONDS_PER_MINUTE;
        require(newTimestamp >= timestamp);
    }
    function addSeconds(uint256  timestamp, uint256  _seconds) internal pure returns (uint256  newTimestamp) {
        newTimestamp = timestamp + _seconds;
        assert(newTimestamp >= timestamp);
    }

    function subYears(uint256  timestamp, uint256  _years) internal pure returns (uint256  newTimestamp) {
        uint256  year;
        uint256  month;
        uint256  day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        year -= _years;
        uint256  daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        assert(newTimestamp <= timestamp);
    }
    function subMonths(uint256  timestamp, uint256  _months) internal pure returns (uint256  newTimestamp) {
        uint256  year;
        uint256  month;
        uint256  day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        uint256  yearMonth = year * 12 + (month - 1) - _months;
        year = yearMonth / 12;
        month = yearMonth % 12 + 1;
        uint256  daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        assert(newTimestamp <= timestamp);
    }
    function subDays(uint256  timestamp, uint256  _days) internal pure returns (uint256  newTimestamp) {
        newTimestamp = timestamp - _days * SECONDS_PER_DAY;
        assert(newTimestamp <= timestamp);
    }
    function subHours(uint256  timestamp, uint256  _hours) internal pure returns (uint256  newTimestamp) {
        newTimestamp = timestamp - _hours * SECONDS_PER_HOUR;
        assert(newTimestamp <= timestamp);
    }
    function subMinutes(uint256  timestamp, uint256  _minutes) internal pure returns (uint256  newTimestamp) {
        newTimestamp = timestamp - _minutes * SECONDS_PER_MINUTE;
        assert(newTimestamp <= timestamp);
    }
    function subSeconds(uint256  timestamp, uint256  _seconds) internal pure returns (uint256  newTimestamp) {
        newTimestamp = timestamp - _seconds;
        assert(newTimestamp <= timestamp);
    }

    function diffYears(uint256  fromTimestamp, uint256  toTimestamp) internal pure returns (uint256  _years) {
        require(fromTimestamp <= toTimestamp);
        uint256  fromYear;
        uint256  fromMonth;
        uint256  fromDay;
        uint256  toYear;
        uint256  toMonth;
        uint256  toDay;
        (fromYear, fromMonth, fromDay) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (toYear, toMonth, toDay) = _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _years = toYear - fromYear;
    }
    function diffMonths(uint256  fromTimestamp, uint256  toTimestamp) internal pure returns (uint256  _months) {
        require(fromTimestamp <= toTimestamp);
        uint256  fromYear;
        uint256  fromMonth;
        uint256  fromDay;
        uint256  toYear;
        uint256  toMonth;
        uint256  toDay;
        (fromYear, fromMonth, fromDay) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (toYear, toMonth, toDay) = _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _months = toYear * 12 + toMonth - fromYear * 12 - fromMonth;
    }
    function diffDays(uint256  fromTimestamp, uint256  toTimestamp) internal pure returns (uint256  _days) {
        require(fromTimestamp <= toTimestamp);
        _days = (toTimestamp - fromTimestamp) / SECONDS_PER_DAY;
    }
    function diffHours(uint256  fromTimestamp, uint256  toTimestamp) internal pure returns (uint256  _hours) {
        require(fromTimestamp <= toTimestamp);
        _hours = (toTimestamp - fromTimestamp) / SECONDS_PER_HOUR;
    }
    function diffMinutes(uint256  fromTimestamp, uint256  toTimestamp) internal pure returns (uint256  _minutes) {
        require(fromTimestamp <= toTimestamp);
        _minutes = (toTimestamp - fromTimestamp) / SECONDS_PER_MINUTE;
    }
    function diffSeconds(uint256  fromTimestamp, uint256  toTimestamp) internal pure returns (uint256  _seconds) {
        require(fromTimestamp <= toTimestamp);
        _seconds = toTimestamp - fromTimestamp;
    }
}





/**
  * @author Veronica Coutts @vonnie610 (twitter) @VeronicaLC (GitLab) 
  * @title  Market Transition
  * @notice This curve contract enables an IBCO (Initial Bonding Curve Offering)
  *         as a mechanism to launch a token into the open market without having
  *         to raise the funds in a traditional manner.
  *         This product is a beta. Use at your own risk.
  */
contract MarketTransition {
    using BokkyPooBahsDateTimeLibrary for uint256;
    // Creates an instance of the uniswap router
    IUniswapV2Router01 public routerInstance;

    bool public check;
    mapping(address => uint[3]) public transitionInfo;

    event transitionToFreeMarket(uint amountA, uint amountB, uint liquidity);

    constructor(address _uniswapRouter) public {
        routerInstance = IUniswapV2Router01(_uniswapRouter);
    }

    function transition() public {
        // Creates an instance of the token sender.
        I_Token tokenInstance = I_Token(msg.sender);
        // Creates an instance of the collateral token of the token.
        IERC20 collateralInstance = IERC20(
            tokenInstance.getCollateralInstance()
        );
        // // This gets the price of the next token in collateral
        uint256 currentPrice = transitionInfo[msg.sender][0];
        uint256 tokensToMint = transitionInfo[msg.sender][1];
        uint256 collateralInToken = transitionInfo[msg.sender][2];

        // TODO Checks if a pair is already created 
        // TODO if there is then the min A & B need to be sliders not set
        {
            // Approves the uniswap router as a spender for the collateral and
            // tokens.
            require(
                collateralInstance.approve(
                    address(routerInstance),
                    collateralInToken
                ),
                "Transfer of collateral failed"
            );
            require(
                tokenInstance.approve(
                    address(routerInstance),
                    tokensToMint
                ),
                "Transfer of minted tokens failed"
            );
            // Creates and adds liquidity for the pair on uniswap. 
            (
                uint amountA, 
                uint amountB, 
                uint liquidity
            ) = routerInstance.addLiquidity(
                address(tokenInstance),
                address(collateralInstance),
                tokensToMint,
                collateralInToken,
                tokensToMint,
                collateralInToken,
                address(tokenInstance),
                (now + 1000)
            );

            emit transitionToFreeMarket(amountA, amountB, liquidity);
        }
        // Sets the token to transitioned.
        I_Token(msg.sender).setTransition();
    }

    /**
      * @notice This functions stores the information around the prices for the
      *         token as when this information was not stored the calculations
      *         would inherintly be different as there would be new tokens 
      *         minted between this function and the transition function 
      *         iteself.
      * @return uint256: The number of tokens the token will need to mint
      *         for the start price of the uniswap market to be the same as the
      *         end price of the bonding curve.
      */
    function getTokensToMint() public returns(uint256) {
        I_Token tokenInstance = I_Token(msg.sender);
        uint256 currentPrice = tokenInstance.getBuyCost(1);
        // Makes an instance of the collateral token of the token
        IERC20 collateralInstance = IERC20(
            tokenInstance.getCollateralInstance()
        );
        
        uint256 collateralInToken = collateralInstance.balanceOf(msg.sender);
        uint256 tokensToMint = collateralInToken/currentPrice;

        transitionInfo[msg.sender][0] = currentPrice;
        transitionInfo[msg.sender][1] = tokensToMint;
        transitionInfo[msg.sender][2] = collateralInToken;

        return tokensToMint;
    }

    /**
      * @return address: The address of the uniswap router. 
      */
    function getRouterAddress() public view returns(address) {
        return address(routerInstance);
    }

    /**
      * @param  _token: The address of the token.
      * @return uint: The current price. The price of the token at transition.
      *         This should be the start price of the uniswap market. 
      * @return uint: The tokens minted to the transition contract.
      * @return uint: The collateral moved out of the bonding curve and into the
      *         uniswap market.
      */
    function getTransitionInfo(
        address _token
    ) 
        public 
        view 
        returns(
            uint, 
            uint, 
            uint
        ) 
    {
        return (
            transitionInfo[_token][0],
            transitionInfo[_token][1],
            transitionInfo[_token][2]
        );
    }

    /**
      * @notice I needed a time calaculator somewhere, so I added it in here.
      * @param  _months: The number of months to be converted into unix time.
      * @return uint256: The time stamp of the months in unix time.
      */
    function getMonthsFutureTimestamp(
        uint256 _months
    ) 
        public 
        view 
        returns(uint256) 
    {
        return now.addMonths(_months);
    }
}





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