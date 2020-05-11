const etherlime = require('etherlime-lib');
const ethers = require('ethers');
const BigNumber = require('bignumber.js');


let TokenAbi = require('../build/Token.json');
let CurveAbi = require('../build/Curve.json');

describe("💰 Curve Tests", async () => {
    let insecureDeployer = accounts[0];
    
    let tokenInstance;
    let curveInstance;

    beforeEach('', async () => {
        deployer = new etherlime.EtherlimeGanacheDeployer(insecureDeployer.secretKey);
        
        curveInstance = await deployer.deploy(
            CurveAbi,
            false
        );

        tokenInstance = await deployer.deploy(
            TokenAbi,
            false,
            curveInstance.contract.address,
            100,
            5,
            4,
            3
        );
    });

    it("💰 Get token price", async () => {
        let buyPrice = await tokenInstance.getBuyCost(10);
        console.log(buyPrice.toString())
    });

    it("💰 Get token price", async () => {
        
    });
});