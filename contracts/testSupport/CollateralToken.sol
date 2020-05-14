pragma solidity 0.6.6;

import "../../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "../../node_modules/openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

contract Token is ERC20 {

    constructor(
        string memory _name,
        string memory _sybol
    )
        ERC20(
            _name,
            _sybol
        )
        public 
    {
    }

    function buy(uint256 _tokens) external {
        _mint(msg.sender, _tokens);
    } 
}