const truffleAssert = require('truffle-assertions');

const Oracle = artifacts.require("Oracle")
const Demo = artifacts.require("Demo")

contract("Deploy And Test", () => {
    let oracle, demo

    before( async () => {
        oracle = await Oracle.new()
        demo = await Demo.new(oracle.address)
    })

    describe('Deploy Test',
        it('Deploy Test', async () => {
            const oreacleAddress = await oracle.getOracleContractAddress()
            const oracleContractAddress = await demo.oracleContractAddress()

            assert.equal(oreacleAddress, oracle.address)
            assert.equal(oracleContractAddress, oracle.address)
        })
    )

    describe('Request And Response Test',
        it('Send Request Test', async () => {
            await demo.createRequest('http://localhost:5000/api/vi', 'data.price', 'string')
        })
    )
})
