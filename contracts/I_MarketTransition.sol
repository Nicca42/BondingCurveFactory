pragma solidity 0.6.6;

interface I_MarketTransition {

    function transition(address _token) external;
    function getTokensToMint() external view returns(uint256 tokensToMint);
    function getRouterAddress() external view returns(address);
}