pragma solidity 0.6.6;

interface I_Token {
    function totalSupply() external view returns (uint256);
    
    function getCurve() external view returns (
        uint256,
        uint256,
        uint256
    );
}