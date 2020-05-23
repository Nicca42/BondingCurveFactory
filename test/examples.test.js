const { 
    ethers,
    etherlime,
    TokenAbi,
    CurveAbi,
    Erc20Abi,
    CollateralTokenAbi,
    MarketTransitionAbi,
    UniswapRouterAbi,
    initSettings,
    testSettings,
    examples
} = require("./test.settings.js");

describe("🛠 Examples", async () => {
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

    beforeEach('', async () => {
        deployer = new etherlime.EtherlimeGanacheDeployer(insecureDeployer.secretKey);
        
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

        wethInstance = await deployer.deploy(
            CollateralTokenAbi,
            false,
            initSettings.collateralInit.name,
            initSettings.collateralInit.symbol,
        )

        routerInstance = await deployer.deploy(
            UniswapRouterAbi,
            false,
            uniswapFactory.signer.address,
            wethInstance.contract.address
        )

        marketTransfterInstance = await deployer.deploy(
            MarketTransitionAbi,
            false,
            routerInstance.contract.address,
        );
    });

    describe("🌨 Chilled linear", async () => {
        it("🤔 Results & set up", async () => {
            tokenInstance = await deployer.deploy(
                TokenAbi,
                false,
                curveInstance.contract.address,
                marketTransfterInstance.contract.address,
                examples.a.curveParameters,
                examples.a.name,
                examples.a.symbol,
                collateralInstance.contract.address,
                examples.a.transitionThreshold,
                examples.a.minimumCollateralThreshold,
                examples.a.colaleralTimeoutInMonths
            );

            console.log(
                "Curve parameters:\n" + 
                examples.a.curveParameters[0].toString()       
            );
            console.log(
                examples.a.curveParameters[1].toString()       
            );
            console.log(
                examples.a.curveParameters[2].toString()       
            );

            console.log("Token transition threshold:\n" + examples.a.transitionThreshold.toString())

            let collateralAtThreshold = await tokenInstance.getBuyCost(
                examples.a.transitionThreshold
            );
            console.log("Collateral at threshold:\n" + collateralAtThreshold.toString());

            console.log(
                "Minimum token threshold:\n" +
                examples.a.minimumCollateralThreshold
            );

            collateralAtThreshold = await tokenInstance.getBuyCost(
                examples.a.minimumCollateralThreshold
            );
            console.log("Collateral at threshold:\n" + collateralAtThreshold.toString());
        });
    });

    describe("🎢 Exponential", async () => {
        it("🤔 Results & set up", async () => {
            tokenInstance = await deployer.deploy(
                TokenAbi,
                false,
                curveInstance.contract.address,
                marketTransfterInstance.contract.address,
                examples.b.curveParameters,
                examples.b.name,
                examples.b.symbol,
                collateralInstance.contract.address,
                examples.b.transitionThreshold,
                examples.b.minimumCollateralThreshold,
                examples.b.colaleralTimeoutInMonths
            );

            console.log(
                "Curve parameters:\n" + 
                examples.b.curveParameters[0].toString()       
            );
            console.log(
                examples.b.curveParameters[1].toString()       
            );
            console.log(
                examples.b.curveParameters[2].toString()       
            );

            console.log("Token transition threshold:\n" + examples.b.transitionThreshold.toString())

            let collateralAtThreshold = await tokenInstance.getBuyCost(
                examples.b.transitionThreshold
            );
            console.log("Collateral at threshold:\n" + collateralAtThreshold.toString());

            console.log(
                "Minimum token threshold:\n" +
                examples.b.minimumCollateralThreshold
            );

            collateralAtThreshold = await tokenInstance.getBuyCost(
                examples.b.minimumCollateralThreshold
            );
            console.log("Collateral at threshold:\n" + collateralAtThreshold.toString());
        });
    });

    describe("🛋 Flat line", async () => {
        it("🤔 Results & set up", async () => {
            tokenInstance = await deployer.deploy(
                TokenAbi,
                false,
                curveInstance.contract.address,
                marketTransfterInstance.contract.address,
                examples.c.curveParameters,
                examples.c.name,
                examples.c.symbol,
                collateralInstance.contract.address,
                examples.c.transitionThreshold,
                examples.c.minimumCollateralThreshold,
                examples.c.colaleralTimeoutInMonths
            );

            console.log(
                "Curve parameters:\n" + 
                examples.c.curveParameters[0].toString()       
            );
            console.log(
                examples.c.curveParameters[1].toString()       
            );
            console.log(
                examples.c.curveParameters[2].toString()       
            );

            console.log("Token transition threshold:\n" + examples.c.transitionThreshold.toString())

            let collateralAtThreshold = await tokenInstance.getBuyCost(
                examples.c.transitionThreshold
            );
            console.log("Collateral at threshold:\n" + collateralAtThreshold.toString());

            console.log(
                "Minimum token threshold:\n" +
                examples.c.minimumCollateralThreshold
            );

            collateralAtThreshold = await tokenInstance.getBuyCost(
                examples.c.minimumCollateralThreshold
            );
            console.log("Collateral at threshold:\n" + collateralAtThreshold.toString());
        });
    });
});