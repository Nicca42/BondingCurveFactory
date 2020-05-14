const etherlime = require('etherlime-lib');
const ethers = require('ethers');
const BigNumber = require('bignumber.js');

let TokenAbi = require('../build/Token.json');
let CurveAbi = require('../build/Curve.json');
let Erc20Abi = require('../build/ERC20.json');
let CollateralTokenAbi = require('../build/Ztest_CollateralToken.json');

const defaultDaiPurchase = ethers.utils.parseUnits("5000000", 18);
const defaultTokenVolume = ethers.utils.parseUnits("320000", 18);

const initSettings = {
    tokenInit: {
        maxSupply: ethers.utils.parseUnits("5000000", 18),
        a: ethers.utils.parseUnits("2", 4),
        b: ethers.utils.parseUnits("3", 4),
        c: ethers.utils.parseUnits("1", 4),
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
        moreThanMintAmount: ethers.utils.parseUnits("11", 18),
        lessThanMintAmount: ethers.utils.parseUnits("9", 18),
        mintedTokens: "6666000000000000001500000000000000000100000000000000000000000",
    },
    sell: {
        sellPartial: ethers.utils.parseUnits("1", 18),
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
