const { 
    ethers,
    etherlime,
    TokenAbi,
    CurveAbi,
    CollateralTokenAbi,
    initSettings,
    testSettings
} = require("./test.settings.js");

describe("💰 Curve Tests", async () => {
    let insecureDeployer = accounts[0];
    
    let tokenInstance;
    let curveInstance;
    let collateralInstance;

    beforeEach('', async () => {
        let deployer = new etherlime.EtherlimeGanacheDeployer(insecureDeployer.secretKey);
        
        curveInstance = await deployer.deploy(
            CurveAbi,
            false
        );

        collateralInstance = await deployer.deploy(
            CollateralTokenAbi,
            false,
            initSettings.tokenInit.name,
            initSettings.tokenInit.symbol
        );

        tokenInstance = await deployer.deploy(
            TokenAbi,
            false,
            curveInstance.contract.address,
            initSettings.tokenInit.maxSupply,
            initSettings.tokenInit.a,
            initSettings.tokenInit.b,
            initSettings.tokenInit.c,
            initSettings.tokenInit.name,
            initSettings.tokenInit.symbol,
            collateralInstance.contract.address
        );
    });

    it("🤑 Buy Tokens", async () => {
        let buyPrice = await tokenInstance.getBuyCost('12340000000000000000');
        console.log(buyPrice);
        assert.equal(
            buyPrice.toString(),
            testSettings.buy.mintedTokens,
            "Unexpected amount of minted tokens"
        );
    });

    it("💰 Get token price", async () => {
        
    });
});