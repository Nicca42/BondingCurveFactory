# Liquorice Gen
A bonding curve factory for simple and easy dynamic bonding curve creation. 

## Getting started

Below are the instructions to get the code up and running

### Installation

Run `yarn` or `npm install`

### Build & test

To build the smart contracts run `yarn build`.

To test, first run `yarn start` (which will start a ganache instance) and then in a separate terminal run `yarn test` to run the smart contract tests. 

### Front end

To view the front end simply double click the `index.html` to open it in a browser of your choice. 

# What is Liquorice Gen?

Liquorice Gen allows you to gather liquidity to launch a token onto the main net without having to go through traditional fundraising routes. 

Through the use of a bonding curve as an automated market maker, you can deterministically raise collateral to launch a token onto uniswap at a predetermined price. 

## The nitty gritty

When creating a market through the [bonding curve factory](./contracts/BondingCurveFactory.sol) you will need to enter the following criteria:

1. **The curve parameters**
    These parameters will be used inside the [bonding curve](./contracts/Curve.sol) to determine the price of your token. 
2. **Name**
    A name for your [token](./contracts/Token.sol). This is for compliance with the [ERC20](./node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol) standard.
3. **Symbol**
    A symbol for your [token](./contracts/Token.sol). This is for compliance with the [ERC20](./node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol) standard.
4. **An address for the underlying collateral**
    When buying a token, the user will have to pay for it in something. This is that something. This underlying collateral must comply with the [ERC20](./node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol) standard, and we would recommend using a stable coin as to ensure the value of your token does not get affected by the volatility of your collateral. 
5. **Token threshold**
    The amount of tokens you would like to be created before the token transitions to a uniswap market. Remember that no more tokens will be able to be created after the token transitions to uniswap. From this number and your curve parameters the amount of collateral that your token will seed the uniswap pool with can be predetermined, along with the start price of your token in the uniswap market (this start price will be the end price determined by the bonding curve at this supply).
6. **Minimum threshold**
    Like the threshold above, except that this minimum threshold will only be checked against after your timeout expires. This is here so that if your threshold is not reached within the time frame, your token can still move across to uniswap. Remember that this cannot be changed once it is set, so think carefully about it. 
7. **Threshold timeout**
    Entered in months (and then conveniently converted) this time line determines when your token will switch from trying to reach the threshold to reaching the minimum threshold. 
