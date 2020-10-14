const truffleAssert = require('truffle-assertions');
const { soliditySha3 } = require("web3-utils");

const Oracle = artifacts.require("Oracle")
const Demo = artifacts.require("Demo")

const
url = 'http://localhost:5000/api/vi',
path = 'data.price',
callbackFunction = "receiveOracle(string)",
reqType = 'string'

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
        it('Request And Response Flow Test', async () => {
            await demo.createRequest(url, path, callbackFunction, reqType)
            const index = soliditySha3(url, path, demo.address, callbackFunction)
            await oracle.responseString(index, "25")
            const oracleValue = await demo.oracleValue()

            assert.equal(oracleValue, "25")
        })
    )
})