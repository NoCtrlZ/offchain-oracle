const Web3 = require('web3');
const EthTx = require('ethereumjs-tx');
const host = 'http://ganache:7545'
const contracts = require("../sample/development.json")

require('dotenv').config()
const address = process.env.ADDRESS
const privKey = process.env.PRIVATE_KEY

const demoAddress = contracts.Demo
const demoABI = require('../build/contracts/Demo').abi

const web3 = new Web3(
    new Web3.providers.HttpProvider(host)
)

const contract = new web3.eth.Contract(
    JSON.parse(JSON.stringify(demoABI)),
    demoAddress
)

const encodedABI = contract.methods.createRequest().encodeABI()

const sendSignedTx = (transactionObject, cb) => {
    let transaction = new EthTx(transactionObject);
    const privateKey = new Buffer.from(privKey, 'hex');
    transaction.sign(privateKey);
    const serializedEthTx = transaction.serialize().toString('hex');
    web3.eth.sendSignedTransaction(`0x${serializedEthTx}`, cb);
}

web3.eth.getTransactionCount(address).then(async transactionNonce => {
    const minReporter = 100
    const transactionObject = {
      chainId: 1,
      nonce: web3.utils.toHex(transactionNonce),
      gasLimit: 800000, // pass an appropriate value
      gasPrice: 1500000000, // pass an appropriate value
      to: demoAddress,
      from: address,
      data: encodedABI,
      value: (minReporter * 1e14) + (1e18 / 20)
    };

    sendSignedTx(transactionObject, (error, result) => {
        if (error)
            console.log('error ===>', error);
        else
            console.log('sent ===>', result);
    });
  });
