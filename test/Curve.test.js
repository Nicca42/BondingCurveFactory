const Curve = artifacts.require("Curve");

contract("💰 Curve Tests", async accounts => {

    it("💰 Get token price", async () => {
        let instance = await MetaCoin.deployed();
        let balance = await instance.getBalance.call(accounts[0]);

        assert.equal(balance.valueOf(), 10000);
    });

    it("💰 Get token price", async () => {

    });
});