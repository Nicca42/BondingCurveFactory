const etherlime = require('etherlime-lib');
const ethers = require('ethers');
const BigNumber = require('bignumber.js');

let TokenAbi = require('../build/Token.json');
let CurveAbi = require('../build/Curve.json');
let MarketTransitionAbi = require('../build/MarketTransition.json');
let Erc20Abi = require('../build/ERC20.json');
let CollateralTokenAbi = require('../build/Ztest_CollateralToken.json');
let UniswapRouterAbi = require('../build/UniswapRouter.json');
let BondingCurveFactoryAbi = require('../build/BondingCurveFactory.json');

const defaultDaiPurchase = ethers.utils.parseUnits("5000000", 18);
const defaultTokenVolume = ethers.utils.parseUnits("320000", 18);

var initSettings = {
    tokenInit: {
        curveParameters: [
            ethers.utils.parseUnits("1", 2),
            ethers.utils.parseUnits("3", 4),
            ethers.utils.parseUnits("1", 1)
        ],
        name: "Coolest Project Ever",
        symbol: "CPE",
        transitionThreshold: ethers.utils.parseUnits("500", 18),
        minimumCollateralThreshold: ethers.utils.parseUnits("250", 18),
        colaleralTimeoutInMonths: 900
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
        mintedTokenCost: "33000000000000001500000000000000000000100000000000000000000",
    },
    sell: {
        sellPartial: ethers.utils.parseUnits("1", 18),
    },
    endBondingCurve: {
        buy: ethers.utils.parseUnits("500", 18),
        justUnderThreshold: ethers.utils.parseUnits("499", 18),
        buyCost: "833250000000000000003750000000000000000005000000000000000000000000",
        finalBuyCost: "24750000000000000015049500000000000000015043",
        mintedTokenAmount: "166666666666666666716",
        collateralBalance: "4125000000000000003750000000000000000000005000000000000000000000"
    }
};

module.exports = {
    ethers,
    etherlime,
    TokenAbi,
    CurveAbi,
    Erc20Abi,
    CollateralTokenAbi,
    BondingCurveFactoryAbi,
    MarketTransitionAbi,
    UniswapRouterAbi,
    initSettings,
    testSettings
}
