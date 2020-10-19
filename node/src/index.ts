import NodeWallet from './wallet';
// import NodeProp from './network'
require('dotenv').config();
const env = process.env.ENV;
const address = process.env.ADDRESS;
const privKey = process.env.PRIVATE_KEY;
const host = env === 'local' ? 'http://127.0.0.1:7545' : 'http://ganache:7545';
const ethers = require('ethers');
const contracts = require('../sample/development.json');
const provider = new ethers.providers.JsonRpcProvider(host, {
  chainId: 1,
  name: 'unknown',
});

const OracleContractAddress = contracts.Oracle;
const OracleContractABI = require('../build/contracts/Oracle').abi;
const OracleContract = new ethers.Contract(
  OracleContractAddress,
  OracleContractABI,
  provider
);

const ethereumWallet = new ethers.Wallet('0x' + privKey, provider);
const contract = new ethers.Contract(
  OracleContractAddress,
  OracleContractABI,
  ethereumWallet
);

console.log('Start Network Node...');

const start = async () => {
  const wallet = new NodeWallet();
  OracleContract.on(
    'RequestCreation',
    async (
      url: string,
      path: string,
      callbackAddress: string,
      callbackFunction: string,
      resType: number,
      minReporter: number,
      index: string
    ) => {
      console.log('url: ', url);
      console.log('path: ', path);
      console.log('callbackAddress: ', callbackAddress);
      console.log('callbackFunction: ', callbackFunction);
      console.log('resType: ', resType);
      console.log('minReporter: ', minReporter);
      console.log('index: ', index);
      console.log(
        await contract
          .stringResult(index, 'hello', [address], [])
          .catch(console.log)
      );
    }
  );
};

start();
