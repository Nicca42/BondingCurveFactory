const { 
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
} = require("./test.settings.js");

describe("🏗 Factory tests", async () => {
    let insecureDeployer = accounts[0];
    let user = accounts[1];
    let uniswapFactory = accounts[2];
    let tester = accounts[3];
    
    let deployer;
    let tokenInstance;
    let curveInstance;
    let collateralInstance;
    let marketTransfterInstance;
    let routerInstance;
    let wethInstance;
    let factoryInstance;

    beforeEach('', async () => {
        deployer = new etherlime.EtherlimeGanacheDeployer(insecureDeployer.secretKey);

        collateralInstance = await deployer.deploy(
            CollateralTokenAbi,
            false,
            initSettings.tokenInit.name,
            initSettings.tokenInit.symbol
        );

        wethInstance = await deployer.deploy(
            CollateralTokenAbi,
            false,
            initSettings.collateralInit.name,
            initSettings.collateralInit.symbol,
        );

        routerInstance = await deployer.deploy(
            UniswapRouterAbi,
            false,
            uniswapFactory.signer.address,
            wethInstance.contract.address
        );

        factoryInstance = await deployer.deploy(
            BondingCurveFactoryAbi,
            false,
            routerInstance.contract.address
        );
    });

    describe("🏗 Factory set up & deploy tests", async () => {
        it("🎢 Factory set up", async () => {
            await factoryInstance.from(insecureDeployer).setUpFactory();

            let factorySetUp = await factoryInstance.getFactorySetUp();
            
            assert.notEqual(
                factorySetUp[0],
                factorySetUp[1],
                "Factory set up failed"
            );
        });

        it("💰Deploying a market", async () => {
            await factoryInstance.from(insecureDeployer).setUpFactory();

            let factorySetUp = await factoryInstance.getFactorySetUp();
            let deployedMarkets = await factoryInstance.getDeployedMarkets(
                insecureDeployer.signer.address
            );
            
            assert.notEqual(
                factorySetUp[0],
                factorySetUp[1],
                "Factory set up failed"
            );

            let newMarket = await (await factoryInstance.createMarket(
                initSettings.tokenInit.curveParameters,
                initSettings.tokenInit.name,
                initSettings.tokenInit.symbol,
                collateralInstance.contract.address,
                initSettings.tokenInit.transitionThreshold,
                initSettings.tokenInit.minimumCollateralThreshold,
                initSettings.tokenInit.colaleralTimeoutInMonths
            )).wait();

            let deployedMarketsAfter = await factoryInstance.getDeployedMarkets(
                insecureDeployer.signer.address
            );

            assert.notEqual(
                deployedMarkets,
                deployedMarketsAfter,
                "User has not recorded any markets"
            );
        });
    });
});