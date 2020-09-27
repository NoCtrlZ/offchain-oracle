const truffleAssert = require('truffle-assertions');

const Oracle = artifacts.require("Oracle")

contract("Deploy And Test", () => {
    let oracle

    before( async () => {
        oracle = await Oracle.new()
    })

    describe('Deploy Test',
        it('Dploy Test', async () => {
            const oreacleAddress = await oracle.getOracleContractAddress()
            assert.equal(oreacleAddress, oracle.address)
        })
    )
})
