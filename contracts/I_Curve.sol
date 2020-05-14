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