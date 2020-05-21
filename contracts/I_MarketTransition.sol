pragma solidity 0.6.6;

interface I_MarketTransition {

    function transition() external;
    function getTokensToMint() external returns(uint256 tokensToMint);
    function getRouterAddress() external view returns(address);
    function getTransitionInfo(address _token) external view returns(uint, uint, uint);
}