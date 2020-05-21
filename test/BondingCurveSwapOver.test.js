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

        // TODO rename to market transition (MT)
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

        it("✅ Threshold is reached with threshold amount (exact limit reached)", async () => {
            let buyPrice = await tokenInstance.getBuyCost(initSettings.tokenInit.transitionThreshold);
            let tokenContractBalance = await collateralInstance.balanceOf(
                tokenInstance.contract.address
            );
            let transferInformation = await transferInstance.getTransitionInfo(
                tokenInstance.contract.address
            );
    
            assert.equal(
                tokenContractBalance.toString(),
                0,
                "Token contract did not start with 0 balance"
            );

            assert.equal(
                transferInformation[0].toString(),
                0,
                "Transition information prematurly set"
            );

            assert.equal(
                transferInformation[1].toString(),
                0,
                "Transition information prematurly set"
            );

            assert.equal(
                transferInformation[2].toString(),
                0,
                "Transition information prematurly set"
            );
            
            await collateralInstance.from(user).buy(buyPrice);
            await collateralInstance.from(user).approve(
                tokenInstance.contract.address,
                buyPrice
            );
    
            await tokenInstance.from(user).buy(
                initSettings.tokenInit.transitionThreshold
            );

            let transitionConditionsMet = await tokenInstance.getTokenStatus();

            assert.equal(
                transitionConditionsMet[0],
                transitionConditionsMet[1],
                "Transition state incorrect before buy"
            );

            await assert.revert(
                tokenInstance.from(user).buy(
                    initSettings.tokenInit.transitionThreshold
                )
            );

            let transferInformationAfter = await transferInstance.getTransitionInfo(
                tokenInstance.contract.address
            );
            let mtCollateralBalance = await collateralInstance.balanceOf(
                transferInstance.contract.address
            );
            let mtTokenBalance = await tokenInstance.balanceOf(
                transferInstance.contract.address
            );
            let mtCollateral = await collateralInstance.allowance(
                transferInstance.contract.address,
                routerInstance.contract.address
            );
            let mtToken = await tokenInstance.allowance(
                transferInstance.contract.address,
                routerInstance.contract.address
            );
            let routerAfterCollateral = await collateralInstance.balanceOf(
                routerInstance.contract.address
            );
            let routerAfterToken = await tokenInstance.balanceOf(
                routerInstance.contract.address
            );
            let transitionConditionsMetAfter = await tokenInstance.getTokenStatus();

            assert.equal(
                transferInformationAfter[0].toString(),
                testSettings.endBondingCurve.finalBuyCost,
                "Transition information prematurly set"
            );

            assert.equal(
                transferInformationAfter[1].toString(),
                testSettings.endBondingCurve.mintedTokenAmount,
                "Transition information prematurly set"
            );

            assert.equal(
                transferInformationAfter[2].toString(),
                testSettings.endBondingCurve.collateralBalance,
                "Transition information prematurly set"
            );

            assert.equal(
                mtCollateralBalance.toString(),
                0,
                "Market Transition balance in collateral inccorect"
            );

            assert.equal(
                mtTokenBalance.toString(),
                0,
                "Market Transition balance in token inccorect"
            );

            assert.equal(
                mtCollateral.toString(),
                0,
                "Market Transition balance in collateral inccorect"
            );

            assert.equal(
                mtToken.toString(),
                0,
                "Market Transition balance in token inccorect"
            );

            assert.equal(
                routerAfterCollateral.toString(),
                testSettings.endBondingCurve.collateralBalance,
                "router token balance incorect after transition"
            );

            assert.equal(
                routerAfterToken.toString(),
                testSettings.endBondingCurve.mintedTokenAmount,
                "router token balance incorect after transition"
            );

            assert.equal(
                transitionConditionsMetAfter[0],
                true,
                "Transition state incorectly set after transition"
            );

            assert.equal(
                transitionConditionsMetAfter[1],
                true,
                "Transition state incorectly set after transition"
            );
        });

        it("✅ Threshold is reached with threshold amount (excess of limit reached)", async () => {
            let buyPrice = await tokenInstance.getBuyCost(
                testSettings.endBondingCurve.justUnderThreshold
            );
            let tokenContractBalance = await collateralInstance.balanceOf(
                tokenInstance.contract.address
            );
            let transferInformation = await transferInstance.getTransitionInfo(
                tokenInstance.contract.address
            );
    
            assert.equal(
                tokenContractBalance.toString(),
                0,
                "Token contract did not start with 0 balance"
            );

            assert.equal(
                transferInformation[0].toString(),
                0,
                "Transition information prematurly set"
            );

            assert.equal(
                transferInformation[1].toString(),
                0,
                "Transition information prematurly set"
            );

            assert.equal(
                transferInformation[2].toString(),
                0,
                "Transition information prematurly set"
            );
            
            await collateralInstance.from(user).buy(buyPrice);
            await collateralInstance.from(user).approve(
                tokenInstance.contract.address,
                buyPrice
            );
    
            await tokenInstance.from(user).buy(
                testSettings.endBondingCurve.justUnderThreshold
            );

            let transitionConditionsMet = await tokenInstance.getTokenStatus();

            assert.equal(
                transitionConditionsMet[0],
                transitionConditionsMet[1],
                "Transition state incorrect before buy"
            );

            // >>> Buy that pushes token into transition

            buyPrice = await tokenInstance.getBuyCost(
                testSettings.buy.mintAmount
            );

            await collateralInstance.from(user).buy(buyPrice);
            await collateralInstance.from(user).approve(
                tokenInstance.contract.address,
                buyPrice
            );

            await tokenInstance.from(user).buy(
                testSettings.buy.mintAmount
            );

            // TODO add checks that user was only able to buy the difference

            let transferInformationAfter = await transferInstance.getTransitionInfo(
                tokenInstance.contract.address
            );
            let mtCollateralBalance = await collateralInstance.balanceOf(
                transferInstance.contract.address
            );
            let mtTokenBalance = await tokenInstance.balanceOf(
                transferInstance.contract.address
            );
            let mtCollateral = await collateralInstance.allowance(
                transferInstance.contract.address,
                routerInstance.contract.address
            );
            let mtToken = await tokenInstance.allowance(
                transferInstance.contract.address,
                routerInstance.contract.address
            );
            let routerAfterCollateral = await collateralInstance.balanceOf(
                routerInstance.contract.address
            );
            let routerAfterToken = await tokenInstance.balanceOf(
                routerInstance.contract.address
            );
            let transitionConditionsMetAfter = await tokenInstance.getTokenStatus();

            assert.equal(
                transferInformationAfter[0].toString(),
                testSettings.endBondingCurve.finalBuyCost,
                "Transition information prematurly set"
            );

            assert.equal(
                transferInformationAfter[1].toString(),
                testSettings.endBondingCurve.mintedTokenAmount,
                "Transition information prematurly set"
            );

            assert.equal(
                transferInformationAfter[2].toString(),
                testSettings.endBondingCurve.collateralBalance,
                "Transition information prematurly set"
            );

            assert.equal(
                mtCollateralBalance.toString(),
                0,
                "Market Transition balance in collateral inccorect"
            );

            assert.equal(
                mtTokenBalance.toString(),
                0,
                "Market Transition balance in token inccorect"
            );

            assert.equal(
                mtCollateral.toString(),
                0,
                "Market Transition balance in collateral inccorect"
            );

            assert.equal(
                mtToken.toString(),
                0,
                "Market Transition balance in token inccorect"
            );

            assert.equal(
                routerAfterCollateral.toString(),
                testSettings.endBondingCurve.collateralBalance,
                "router token balance incorect after transition"
            );

            assert.equal(
                routerAfterToken.toString(),
                testSettings.endBondingCurve.mintedTokenAmount,
                "router token balance incorect after transition"
            );

            assert.equal(
                transitionConditionsMetAfter[0],
                true,
                "Transition state incorectly set after transition"
            );

            assert.equal(
                transitionConditionsMetAfter[1],
                true,
                "Transition state incorectly set after transition"
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
    });
});