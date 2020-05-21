pragma solidity 0.6.6;

interface I_MarketTransition {

    function transition(address _token, address _router) external;
    function getTokensToMint() external returns(uint256 tokensToMint);
    function getRouterAddress() external view returns(address);
}