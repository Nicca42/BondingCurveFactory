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
                1
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
});