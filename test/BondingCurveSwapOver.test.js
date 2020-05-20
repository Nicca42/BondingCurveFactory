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
    testSettings
} = require("./test.settings.js");

describe("🆓 Transitioning Token To Free Market Tests", async () => {
    let insecureDeployer = accounts[0];
    let user = accounts[1];
    let uniswapFactory = accounts[2];
    //TODO make a mock for uniswap router
    let tester = accounts[3];
    
    let tokenInstance;
    let curveInstance;
    let collateralInstance;
    let transferInstance;
    let routerInstance;
    let wethInstance;

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

        transferInstance = await deployer.deploy(
            MarketTransitionAbi,
            false,
            routerInstance.contract.address,
        );

        tokenInstance = await deployer.deploy(
            TokenAbi,
            false,
            curveInstance.contract.address,
            transferInstance.contract.address,
            initSettings.tokenInit.maxSupply,
            initSettings.tokenInit.curveParameters,
            initSettings.tokenInit.name,
            initSettings.tokenInit.symbol,
            collateralInstance.contract.address,
            initSettings.tokenInit.transitionThreshold
        );
    });

    describe("💫 Transiton tests", async () => {
        it("🦄 Add liquidity mocks", async () => {
            await collateralInstance.from(user).buy(testSettings.buy.mintAmount);
            await collateralInstance.from(user).approve(
                routerInstance.contract.address,
                testSettings.buy.mintAmount
            );

            await wethInstance.from(user).buy(testSettings.buy.mintAmount);
            await wethInstance.from(user).approve(
                routerInstance.contract.address,
                testSettings.buy.mintAmount
            );
            
            let results = await(await routerInstance.from(user).addLiquidity(
                collateralInstance.contract.address,
                wethInstance.contract.address,
                testSettings.buy.mintAmount,
                testSettings.buy.mintAmount,
                0,
                0,
                user.signer.address,
                10000
            )).wait();
        });

        it("✅ Threshold is reached with threshold amount", async () => {
            //TODO move test out of buy tokens
            assert.equal(
                true,
                false,
                "Check not added well in contracts"
            );
        });

        it("💥 Token does not transfer after timeout when below min threshould", async () => {
            assert.equal(
                true,
                false,
                "Check not added in contracts"
            );
        });

        it("✅ Token does transfer after timeout when above min threshould", async () => {
            assert.equal(
                true,
                false,
                "Check not added in contracts"
            );
        });

        it("🤑 Buy Tokens", async () => {
            let buyPrice = await tokenInstance.getBuyCost(initSettings.tokenInit.transitionThreshold);
            let tokenContractBalance = await collateralInstance.balanceOf(tokenInstance.contract.address)
    
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
                initSettings.tokenInit.transitionThreshold
            );

            buyPrice = await tokenInstance.getBuyCost(initSettings.tokenInit.transitionThreshold);
            
            await collateralInstance.from(user).buy(buyPrice);
            await collateralInstance.from(user).approve(
                tokenInstance.contract.address,
                buyPrice
            );

            tokenContractBalance = await collateralInstance.balanceOf(tokenInstance.contract.address);

            console.log("tok bal:\t" + tokenContractBalance.toString());

            let transitionConditionsMet = await tokenInstance.getTokenStatus();
            console.log("transitionConditionsMet:")
            console.log(transitionConditionsMet)

            let results = await(await tokenInstance.from(user).buy(
                initSettings.tokenInit.transitionThreshold
            )).wait();

            transitionConditionsMet = await tokenInstance.getTokenStatus();
            console.log("transitionConditionsMet:")
            console.log(transitionConditionsMet)
            console.log(results)
            // console.log("Vaule of approve\n" + results.events[0].args.value.toString());
            // console.log(results.events[1].args);
            // console.log("Vaule of approve\n" + results.events[2].args.value.toString());
            // // console.log(results.events[3].args);
            // console.log("Tokens to mint:\n" + results.events[3].args.tokensToMint.toString());
            // console.log("Colalteral of market\n" + results.events[3].args.collateral.toString());

            // console.log(results.events[4]);
            // console.log(results.events[5]);

            let routerBalanceOfCollateral = await collateralInstance.allowance(
                tokenInstance.contract.address,
                routerInstance.contract.address
            );
            let routerBalanceOfToken = await tokenInstance.allowance(
                tokenInstance.contract.address,
                routerInstance.contract.address
            );

            console.log(routerBalanceOfCollateral.toString());
            console.log(routerBalanceOfToken.toString());

            buyPrice = await tokenInstance.getBuyCost(1);
            console.log("buy cost:\t" + buyPrice.toString())

            tokenContractBalance = await collateralInstance.balanceOf(tokenInstance.contract.address);

            console.log("tok bal:\t" + tokenContractBalance.toString());


        });
    });
});