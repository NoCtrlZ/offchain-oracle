const Web3 = require('web3');
const EthTx = require('ethereumjs-tx');
const host = 'http://localhost:7545'
const contracts = require("../sample/development.json")

require('dotenv').config()
const address = process.env.ADDRESS
const privKey = process.env.PRIVATE_KEY

const demoAddress = contracts.Demo
const demoABI = require('../build/contracts/Demo').abi

const url = 'http://localhost:5000'
const path = "data.price"
const callbackFunction = "receiveOracle(string)"
const resType = "string"

const web3 = new Web3(
    new Web3.providers.HttpProvider(host)
)

const contract = new web3.eth.Contract(
    JSON.parse(JSON.stringify(demoABI)),
    demoAddress
)

const encodedABI = contract.methods.createRequest(url, path, callbackFunction, resType).encodeABI()

const sendSignedTx = (transactionObject, cb) => {
    let transaction = new EthTx(transactionObject);
    const privateKey = new Buffer.from(privKey, 'hex');
    transaction.sign(privateKey);
    const serializedEthTx = transaction.serialize().toString('hex');
    web3.eth.sendSignedTransaction(`0x${serializedEthTx}`, cb);
}

web3.eth.getTransactionCount(address).then((transactionNonce) => {
    const transactionObject = {
      chainId: 1,
      nonce: web3.utils.toHex(transactionNonce),
      gasLimit: 8000000, // pass an appropriate value
      gasPrice: 150000000000, // pass an appropriate value
      to: demoAddress,
      from: address,
      data: encodedABI
    };

    sendSignedTx(transactionObject, (error, result) => {
        if (error)
            console.log('error ===>', error);
        else
            console.log('sent ===>', result);
    });
  });
