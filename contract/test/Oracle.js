// const truffleAssert = require('truffle-assertions');
const { soliditySha3 } = require("web3-utils");

const Oracle = artifacts.require("Oracle")
const Demo = artifacts.require("Demo")

const
url = 'http://localhost:5000/api/vi',
path = 'data.price',
callbackFunction = "receiveOracle(string)",
reqType = 'string',
oneEther = 1e18

contract("Deploy And Test", (accounts) => {
    let oracle, demo

    before( async () => {
        oracle = await Oracle.new(accounts[0])
        demo = await Demo.new(oracle.address)
    })

    describe('Deploy Test',
        it('Deploy Test', async () => {
            const oreacleAddress = await oracle.getOracleContractAddress()
            const oracleContractAddress = await demo.oracleContractAddress()
            const networkAddress = await oracle.networkAddress()

            assert.equal(oreacleAddress, oracle.address)
            assert.equal(oracleContractAddress, oracle.address)
            assert.equal(networkAddress, accounts[0])
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

    describe('Deposit Ether',
        it('Deposit Ether Test', async () => {
            await oracle.depositEther({ from: accounts[0], value: oneEther })
            const isDeposit = await oracle.isDeposit(accounts[0])

            assert.equal(isDeposit, true)
        })
    )

    describe('Withdraw Ether',
        it('Withdraw Ether Test', async () => {
            await oracle.unlock()
            await oracle.withdrawEther()
            const isDeposit = await oracle.isDeposit(accounts[0])

            assert.equal(isDeposit, false)
        })
    )
})
