const etherlime = require('etherlime-lib');
const ethers = require('ethers');
const BigNumber = require('bignumber.js');

let TokenAbi = require('../build/Token.json');
let CurveAbi = require('../build/Curve.json');
let Erc20Abi = require('../build/ERC20.json');
let CollateralTokenAbi = require('../build/CollateralToken.json');

const defaultDaiPurchase = ethers.utils.parseUnits("5000000", 18);
const defaultTokenVolume = ethers.utils.parseUnits("320000", 18);

const initSettings = {
    tokenInit: {
        maxSupply: ethers.utils.parseUnits("5000000", 18),
        a: ethers.utils.parseUnits("2", 9),
        b: ethers.utils.parseUnits("3", 8),
        c: ethers.utils.parseUnits("1", 10),
        name: "Coolest Project Ever",
        symbol: "CPE"
    },
    collateralInit: {
        name: "collateral",
        symbol: "COL"
    }
};

const testSettings = {
    buy: {
        mintAmount: ethers.utils.parseUnits("10", 18),
        mintedTokens: "1252720601413946064022841340000000000123400000000000000000000000000",

    }
}

module.exports = { 
    ethers,
    etherlime,
    TokenAbi,
    CurveAbi,
    CollateralTokenAbi,
    initSettings,
    testSettings
}
