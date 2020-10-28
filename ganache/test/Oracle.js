var Web3 = require('web3');
var utils = require('ethereumjs-util');

var web3 = new Web3();

var defaultProvider = new web3.providers.HttpProvider('http://localhost:7545');
web3.setProvider(defaultProvider);

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
    let oracle, demo, index

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

    describe('Request Test',
        it('Request Test', () =>
            expect(async () => {
                const gasFee = (minReporter * oneReward) + (oneEther / 20)
                await demo.createRequest({ from: accounts[0], value: Number(gasFee) }).catch(e => { throw e })
                const event = await oracle.getPastEvents('RequestCreation')
                index = soliditySha3(url, path, demo.address, callbackFunction, event[0].returnValues.timestamp)
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

    describe('Register Admin',
        it('Register Admin Test', async() => {
            let i = 0;
            let nonce = soliditySha3(index, i)
            while(!nonce.startsWith(index.slice(0, 5))) {
                i++
                nonce = soliditySha3(index, i)
            }
            await oracle.commitAdmin(index, i, { from: accounts[1]})
            const admin = await oracle.oracleAdmin(index)
            assert.equal(admin, accounts[1])
        })
    )

    describe('Register Verifier',
        it('Register Verifier Test', async () => {
            const oracleNonce = await oracle.oracleNonce(index)
            let i = 0;
            let nonce = soliditySha3(index, oracleNonce, i)
            while(!nonce.startsWith(index.slice(0, 5))) {
                i++
                nonce = soliditySha3(index, oracleNonce, i)
            }
            const { v, r, s } = await getSignature(index, accounts[0]);
            await oracle.commitVerifier(index, i, v, r, s, { from: accounts[2] })
            const verifier = await oracle.oracleVerifier(index)

            assert.equal(verifier, accounts[0])
        }))

    describe('Response Test',
        it('Response Test', async () => {
            const { v, r, s } = await getSignature(index, accounts[0])
            const rewardAddress = [accounts[0]]
            const punishAddress = [accounts[1], accounts[2]]
            await oracle.stringResult(index, "oracle result", rewardAddress, punishAddress, v, r, s, { from: accounts[1] })
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

const getSignature = async (index, account) => {
    let signature = await web3.eth.sign(index, account);
    signature = signature.split('x')[1];
    const r = '0x' + signature.substring(0, 64)
    const s = '0x' + signature.substring(64, 128)
    let v = '0x' + signature.slice(128, 130)
    if (v == '0x00')
        v = '0x1b'
    else if (v == '0x01')
        v = '0x1c'
    return {
        r, s, v
    }
}
