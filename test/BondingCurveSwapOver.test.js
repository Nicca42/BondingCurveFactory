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

describe("🆓 Transitioning Token To Free Market Tests", async () => {
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
            initSettings.tokenInit.transitionThreshold
        );
    });

    describe("📈 Buy tests", async () => {
        it("🤑 Buy Tokens", async () => {
            let buyPrice = await tokenInstance.getBuyCost(100);
            let tokenContractBalance = await collateralInstance.balanceOf(tokenInstance.contract.address)
    
            console.log(buyPrice.toString())
            assert.equal(
                tokenContractBalance.toString(),
                0,
                "Token contract did not start with 0 balance"
            );
    
            await collateralInstance.from(user).buy(buyPrice);
            await collateralInstance.from(user).approve(
                tokenInstance.contract.address,
                buyPrice
            );
    
            await tokenInstance.from(user).buy(
                100
            );

            buyPrice = await tokenInstance.getBuyCost(1);
            console.log(buyPrice.toString())

            tokenContractBalance = await collateralInstance.balanceOf(tokenInstance.contract.address)
            console.log("token contract collateral balance:")
            console.log(tokenContractBalance.toString())
        });
    });
});