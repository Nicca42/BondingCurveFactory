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

        tokenInstance = await deployer.deploy(
            TokenAbi,
            false,
            curveInstance.contract.address,
            marketTransfterInstance.contract.address,
            initSettings.tokenInit.curveParameters,
            initSettings.tokenInit.name,
            initSettings.tokenInit.symbol,
            collateralInstance.contract.address,
            initSettings.tokenInit.transitionThreshold,
            initSettings.tokenInit.minimumCollateralThreshold,
            initSettings.tokenInit.colaleralTimeoutInMonths
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
            let transferInformation = await marketTransfterInstance.getTransitionInfo(
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

            let transferInformationAfter = await marketTransfterInstance.getTransitionInfo(
                tokenInstance.contract.address
            );
            let mtCollateralBalance = await collateralInstance.balanceOf(
                marketTransfterInstance.contract.address
            );
            let mtTokenBalance = await tokenInstance.balanceOf(
                marketTransfterInstance.contract.address
            );
            let mtCollateral = await collateralInstance.allowance(
                marketTransfterInstance.contract.address,
                routerInstance.contract.address
            );
            let mtToken = await tokenInstance.allowance(
                marketTransfterInstance.contract.address,
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
            let transferInformation = await marketTransfterInstance.getTransitionInfo(
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

            let transitionConditionsMet = await tokenInstance.getTokenStatus();
            let totalSupply = await tokenInstance.totalSupply();

            assert.equal(
                totalSupply.toString(),
                0,
                "Supply exisits before buy"
            );
    
            await tokenInstance.from(user).buy(
                testSettings.endBondingCurve.justUnderThreshold
            );

            let transitionConditionsMetAfter = await tokenInstance.getTokenStatus();
            let totalSupplyAfter = await tokenInstance.totalSupply();

            assert.equal(
                transitionConditionsMet[0],
                transitionConditionsMet[1],
                "Transition state incorrect before buy"
            );

            assert.equal(
                totalSupplyAfter.toString(),
                testSettings.endBondingCurve.justUnderThreshold.toString(),
                "Total supply incorrect after buy"
            );

            assert.equal(
                transitionConditionsMetAfter[0],
                transitionConditionsMetAfter[1],
                "Transition state incorrect before buy"
            );

            /**
             * >>> 
             *      Buy that pushes token into transition
             * <<<
             */
            
            buyPrice = await tokenInstance.getBuyCost(
                testSettings.buy.moreThanMintAmount
            );

            let balanceOfThresholdUser = await tokenInstance.balanceOf(
                tester.signer.address
            );

            assert.equal(
                balanceOfThresholdUser.toString(),
                0,
                "User has balance before buying"
            );

            await collateralInstance.from(tester).buy(buyPrice);
            await collateralInstance.from(tester).approve(
                tokenInstance.contract.address,
                buyPrice
            );

            await tokenInstance.from(tester).buy(
                testSettings.buy.moreThanMintAmount
            );

            let balanceOfThresholdUserAfter = await tokenInstance.balanceOf(
                tester.signer.address
            );

            assert.notEqual(
                balanceOfThresholdUserAfter.toString(),
                testSettings.buy.moreThanMintAmount.toString(),
                "User was able to buy more than threshold"
            );

            let transferInformationAfter = await marketTransfterInstance.getTransitionInfo(
                tokenInstance.contract.address
            );
            let mtCollateralBalance = await collateralInstance.balanceOf(
                marketTransfterInstance.contract.address
            );
            let mtTokenBalance = await tokenInstance.balanceOf(
                marketTransfterInstance.contract.address
            );
            let mtCollateral = await collateralInstance.allowance(
                marketTransfterInstance.contract.address,
                routerInstance.contract.address
            );
            let mtToken = await tokenInstance.allowance(
                marketTransfterInstance.contract.address,
                routerInstance.contract.address
            );
            let routerAfterCollateral = await collateralInstance.balanceOf(
                routerInstance.contract.address
            );
            let routerAfterToken = await tokenInstance.balanceOf(
                routerInstance.contract.address
            );
            transitionConditionsMetAfter = await tokenInstance.getTokenStatus();

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
            let buyPrice = await tokenInstance.getBuyCost(
                testSettings.buy.mintAmount
            );
            let tokenContractBalance = await collateralInstance.balanceOf(
                tokenInstance.contract.address
            );
            let transferInformation = await marketTransfterInstance.getTransitionInfo(
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

            // Time travel 
            await utils.timeTravel(deployer.provider, initSettings.tokenInit.colaleralTimeoutInMonths);
            
            await collateralInstance.from(user).buy(buyPrice);
            await collateralInstance.from(user).approve(
                tokenInstance.contract.address,
                buyPrice
            );
    
            await tokenInstance.from(user).buy(
                testSettings.buy.mintAmount
            );

            let transitionConditionsMet = await tokenInstance.getTokenStatus();

            assert.equal(
                transitionConditionsMet[0],
                transitionConditionsMet[1],
                "Transition state incorrect before buy"
            );

            assert.equal(
                transitionConditionsMet[0],
                false,
                "Token incorrectly transitioned"
            );
        });

        it("✅ Token does transfer after timeout when above min threshould", async () => {
            let buyPrice = await tokenInstance.getBuyCost(
                initSettings.tokenInit.minimumCollateralThreshold
            );
            let tokenContractBalance = await collateralInstance.balanceOf(
                tokenInstance.contract.address
            );
            let transferInformation = await marketTransfterInstance.getTransitionInfo(
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

            let transitionConditionsMet = await tokenInstance.getTokenStatus();

            assert.equal(
                transitionConditionsMet[0],
                transitionConditionsMet[1],
                "Transition state incorrect before buy"
            );

            assert.equal(
                transitionConditionsMet[0],
                false,
                "Token incorectly tansitioned"
            );

            await collateralInstance.from(user).buy(buyPrice);
            await collateralInstance.from(user).approve(
                tokenInstance.contract.address,
                buyPrice
            );
            await tokenInstance.from(user).buy(
                initSettings.tokenInit.minimumCollateralThreshold
            );

            transitionConditionsMet = await tokenInstance.getTokenStatus();

            assert.equal(
                transitionConditionsMet[0],
                transitionConditionsMet[1],
                "Transition state incorrect before buy"
            );

            assert.equal(
                transitionConditionsMet[0],
                false,
                "Token incorectly tansitioned"
            );

            // Time travel 
            await utils.timeTravel(
                deployer.provider, 
                initSettings.tokenInit.colaleralTimeoutInMonths
            );

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

            transitionConditionsMet = await tokenInstance.getTokenStatus();

            assert.equal(
                transitionConditionsMet[0],
                transitionConditionsMet[1],
                "Transition state incorrect after buy"
            );

            assert.equal(
                transitionConditionsMet[0],
                true,
                "Token has not tansitioned"
            );
        });
    });
});