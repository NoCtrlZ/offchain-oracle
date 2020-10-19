const truffleAssert = require('truffle-assertions');
const { soliditySha3 } = require("web3-utils");

const Oracle = artifacts.require("Oracle")
const Demo = artifacts.require("Demo")

const
url = 'https://ethgasstation.info/api/ethgasAPI.json',
path = 'gasPriceRange.10',
callbackFunction = "receiveOracle(string)",
minReporter = 100,
oneEther = 1e18,
oneReward = 1e14,
onePunish = 1e17

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

    describe('Request Test',
        it('Request Test', () =>
            expect(async () => {
                const gasFee = (minReporter * oneReward) + (oneEther / 20)
                await demo.createRequest({ from: accounts[0], value: Number(gasFee) }).catch(e => { throw e })
            }).not.throw()
        )
    )

    describe('Deposit Ether',
        it('Deposit Ether Test', async () => {
            await oracle.depositEther({ from: accounts[0], value: oneEther })
            await oracle.depositEther({ from: accounts[1], value: oneEther })
            await oracle.depositEther({ from: accounts[2], value: oneEther })
            const isOneAddressDeposit = await oracle.isDeposit(accounts[0])
            const isTwoAddressDeposit = await oracle.isDeposit(accounts[1])
            const isThreeAddressDeposit = await oracle.isDeposit(accounts[2])

            assert.equal(isOneAddressDeposit, true)
            assert.equal(isTwoAddressDeposit, true)
            assert.equal(isThreeAddressDeposit, true)
        })
    )

    describe('Response Test',
        it('Response Test', async () => {
            const index = soliditySha3(url, path, demo.address, callbackFunction)
            const rewardAddress = [accounts[0]]
            const punishAddress = [accounts[1], accounts[2]]
            await oracle.stringResult(index, "oracle result", rewardAddress, punishAddress)
            const oracleValue = await demo.oracleValue()
            const isDone = await oracle.isRequestComplete(index)

            assert.equal(oracleValue, "oracle result")
            assert.equal(isDone, true)
        })
    )

    describe('Withdraw Ether',
        it('Withdraw Ether Test', async () => {
            await oracle.unlock({ from: accounts[0] })
            const withrawOneTx = await oracle.withdrawEther({ from: accounts[0] })
            truffleAssert.eventEmitted(withrawOneTx, 'WithdrawEther', ev => {
                return Number(ev.amount) === oneEther + oneReward &&
                    ev.withdrawer === accounts[0]
            })

            await oracle.unlock({ from: accounts[1] })
            const withrawTwoTx = await oracle.withdrawEther({ from: accounts[1] })
            truffleAssert.eventEmitted(withrawTwoTx, 'WithdrawEther', ev => {
                return Number(ev.amount) === oneEther - onePunish &&
                    ev.withdrawer === accounts[1]
            })

            await oracle.unlock({ from: accounts[2] })
            const withrawThreeTx = await oracle.withdrawEther({ from: accounts[2] })
            truffleAssert.eventEmitted(withrawThreeTx, 'WithdrawEther', ev => {
                return Number(ev.amount) === oneEther - onePunish &&
                    ev.withdrawer === accounts[2]
            })
        })
    )
})
