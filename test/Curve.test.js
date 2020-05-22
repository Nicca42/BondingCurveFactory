const { 
    ethers,
    etherlime,
    TokenAbi,
    CurveAbi,
    CollateralTokenAbi,
    MarketTransitionAbi,
    initSettings,
    testSettings
} = require("./test.settings.js");

describe("📈 Curve Tests", async () => {
    let insecureDeployer = accounts[0];
    let user = accounts[1];
    let uniswapRouter = accounts[2];
    //TODO make a mock for uniswap router
    
    let tokenInstance;
    let curveInstance;
    let collateralInstance;
    let transerInstance;

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

        transerInstance = await deployer.deploy(
            MarketTransitionAbi,
            false,
            uniswapRouter.signer.address,
        );

        tokenInstance = await deployer.deploy(
            TokenAbi,
            false,
            curveInstance.contract.address,
            transerInstance.contract.address,
            initSettings.tokenInit.maxSupply,
            initSettings.tokenInit.curveParameters,
            initSettings.tokenInit.name,
            initSettings.tokenInit.symbol,
            collateralInstance.contract.address,
            initSettings.tokenInit.transitionThreshold,
            initSettings.tokenInit.minimumCollateralThreshold,
            initSettings.tokenInit.colaleralTimeoutInMonths
        );
    });

    it("📈 Get buy token price", async () => {
        let buyPrice = await tokenInstance.getBuyCost(testSettings.buy.mintAmount);

        assert.equal(
            buyPrice.toString(),
            testSettings.buy.mintedTokenCost,
            "Unexpected amount of minted tokens"
        );
    });

    it("📉 Get sell token price", async () => {
        let buyPrice = await tokenInstance.getBuyCost(testSettings.buy.mintAmount);

        await collateralInstance.from(user).buy(buyPrice);
        await collateralInstance.from(user).approve(
            tokenInstance.contract.address,
            buyPrice
        );

        await tokenInstance.from(user).buy(
            testSettings.buy.mintAmount
        );

        let userBalance = await tokenInstance.balanceOf(user.signer.address);

        assert.equal(
            userBalance.toString(),
            testSettings.buy.mintAmount.toString(),
            "User balance incorrect"
        );

        let sellReward = await tokenInstance.getSellAmount(testSettings.buy.mintAmount);

        assert.equal(
            sellReward.toString(),
            testSettings.buy.mintedTokenCost,
            "Unexpected amount of minted tokens"
        );
    });

    it("🚫📉 Negative Get sell token price", async () => {
        let sellReward = await tokenInstance.getSellAmount(testSettings.buy.mintAmount);

        assert.equal(
            sellReward.toString(),
            0,
            "There is a sell reward without tokens"
        )
    });
});