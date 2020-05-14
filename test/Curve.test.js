const { 
    ethers,
    etherlime,
    TokenAbi,
    CurveAbi,
    Erc20Abi,
    initSettings,
    testSettings
} = require("./test.settings.js");

describe("💰 Curve Tests", async () => {
    let insecureDeployer = accounts[0];
    
    let tokenInstance;
    let curveInstance;

    beforeEach('', async () => {
        let deployer = new etherlime.EtherlimeGanacheDeployer(insecureDeployer.secretKey);
        
        curveInstance = await deployer.deploy(
            CurveAbi,
            false
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
            curveInstance.contract.address
        );
    });

    it("💰 Get token price", async () => {
        let buyPrice = await tokenInstance.getBuyCost(testSettings.buy.mintAmount);

        assert.equal(
            buyPrice.toString(),
            testSettings.buy.mintedTokens,
            "Unexpected amount of minted tokens"
        );
    });

    it("💰 Get token price", async () => {
        
    });
});