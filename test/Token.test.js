const { 
    ethers,
    etherlime,
    TokenAbi,
    CurveAbi,
    CollateralTokenAbi,
    initSettings,
    testSettings
} = require("./test.settings.js");

describe("💪 Token Tests", async () => {
    let insecureDeployer = accounts[0];
    let user = accounts[1];
    
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

    it("💰 Get buy token price", async () => {
        let buyPrice = await tokenInstance.getBuyCost(testSettings.buy.mintAmount);

        assert.equal(
            buyPrice.toString(),
            testSettings.buy.mintedTokenCost,
            "Unexpected amount of minted tokens"
        );
    });

    it("🤑 Buy Tokens", async () => {
        let buyPrice = await tokenInstance.getBuyCost(testSettings.buy.mintAmount);
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
            testSettings.buy.mintAmount.toString()
        );

        let userBalance = await tokenInstance.balanceOf(user.signer.address);
        let tokenContractBalanceAfter = await collateralInstance.balanceOf(tokenInstance.contract.address)

        assert.equal(
            tokenContractBalanceAfter.toString(),
            testSettings.buy.mintedTokenCost,
            "Token contract did not start with 0 balance"
        );
        assert.equal(
            userBalance.toString(),
            testSettings.buy.mintAmount.toString(),
            "User balance incorrect"
        );
    });

    it("🏔 Max Buy Tokens", async () => {
        let buyPrice = await tokenInstance.getBuyCost(testSettings.buy.mintAmount);
        let tokenContractBalance = await collateralInstance.balanceOf(tokenInstance.contract.address)

        assert.equal(
            tokenContractBalance.toString(),
            0,
            "Token contract did not start with 0 balance"
        );

        await collateralInstance.from(user).buy(buyPrice);
        await collateralInstance.from(user).approve(
            tokenInstance.contract.address,
            ethers.constants.MaxUint256
        );

        await tokenInstance.from(user).buy(
            testSettings.buy.mintAmount.toString()
        );

        let userBalance = await tokenInstance.balanceOf(user.signer.address);
        let tokenContractBalanceAfter = await collateralInstance.balanceOf(tokenInstance.contract.address)

        assert.equal(
            tokenContractBalanceAfter.toString(),
            testSettings.buy.mintedTokenCost,
            "Token contract did not start with 0 balance"
        );

        assert.equal(
            userBalance.toString(),
            testSettings.buy.mintAmount.toString(),
            "User balance incorrect"
        );
    });

    it("🚫🤑 Negative Buy Tokens", async () => {
        let buyPrice = await tokenInstance.getBuyCost(testSettings.buy.mintAmount);
        let tokenContractBalance = await collateralInstance.balanceOf(tokenInstance.contract.address)

        assert.equal(
            tokenContractBalance.toString(),
            0,
            "Token contract did not start with 0 balance"
        );

        await collateralInstance.from(user).buy(buyPrice);

        await assert.revert(
            tokenInstance.from(user).buy(
                testSettings.buy.mintAmount.toString()
            )
        );

        let userBalance = await tokenInstance.balanceOf(user.signer.address);
        let tokenContractBalanceAfter = await collateralInstance.balanceOf(tokenInstance.contract.address)

        assert.equal(
            tokenContractBalanceAfter.toString(),
            0,
            "Token contract did not start with 0 balance"
        );

        assert.equal(
            userBalance.toString(),
            0,
            "User balance incorrect"
        );
    });

    it("🚫🏔 Max Negative Buy Tokens", async () => {
        let buyPrice = await tokenInstance.getBuyCost(testSettings.buy.mintAmount);
        let tokenContractBalance = await collateralInstance.balanceOf(tokenInstance.contract.address)

        assert.equal(
            tokenContractBalance.toString(),
            0,
            "Token contract did not start with 0 balance"
        );

        await collateralInstance.from(user).buy(buyPrice);
        await collateralInstance.from(user).approve(
            tokenInstance.contract.address,
            testSettings.buy.lessThanMintAmount
        );

        await assert.revert(
            tokenInstance.from(user).buy(
                testSettings.buy.mintAmount.toString()
            )
        );

        let userBalance = await tokenInstance.balanceOf(user.signer.address);
        let tokenContractBalanceAfter = await collateralInstance.balanceOf(tokenInstance.contract.address)

        assert.equal(
            tokenContractBalanceAfter.toString(),
            0,
            "Token contract did not start with 0 balance"
        );

        assert.equal(
            userBalance.toString(),
            0,
            "User balance incorrect"
        );
    });

    it("💰 Get sell token price", async () => {
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

    it("📤 Sell Tokens", async () => {
        let buyPrice = await tokenInstance.getBuyCost(testSettings.buy.mintAmount);
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
            testSettings.buy.mintAmount
        );

        let userBalance = await tokenInstance.balanceOf(user.signer.address);
        let tokenContractBalanceAfter = await collateralInstance.balanceOf(tokenInstance.contract.address)

        assert.equal(
            tokenContractBalanceAfter.toString(),
            testSettings.buy.mintedTokenCost,
            "Token contract did not start with 0 balance"
        );

        assert.equal(
            userBalance.toString(),
            testSettings.buy.mintAmount,
            "User balance incorrect"
        );

        await tokenInstance.from(user).sell(
            testSettings.buy.mintAmount
        );

        let userSellBalance = await tokenInstance.balanceOf(user.signer.address);
        let tokenContractBalanceEnd = await collateralInstance.balanceOf(tokenInstance.contract.address)

        assert.equal(
            tokenContractBalanceEnd.toString(),
            0,
            "Token contract did not start with 0 balance"
        );

        assert.equal(
            userSellBalance.toString(),
            0,
            "User incorrectly has remaining balance after selling all tokens"
        );
    });

    it("🏔 Partial Sell Tokens", async () => {
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
            testSettings.buy.mintAmount,
            "User balance incorrect"
        );

        await tokenInstance.from(user).sell(
            testSettings.buy.lessThanMintAmount
        );

        let userSellBalance = await tokenInstance.balanceOf(user.signer.address);
        
        assert.equal(
            userSellBalance.toString(),
            testSettings.sell.sellPartial.toString(),
            "User incorrectly has remaining balance after selling all tokens"
        );
    });

    it("🚫📤 Negative Sell Tokens", async () => {
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
            testSettings.buy.mintAmount,
            "User balance incorrect"
        );

        await assert.revert(
            tokenInstance.from(user).sell(
                testSettings.buy.moreThanMintAmount
            )
        );

        let userSellBalance = await tokenInstance.balanceOf(user.signer.address);

        assert.equal(
            userSellBalance.toString(),
            userBalance.toString(),
            "User incorrectly was able to sell tokens"
        );
    });
});