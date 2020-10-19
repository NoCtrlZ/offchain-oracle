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

const DemoContractAddress = contracts.Demo;
const DemoContractABI = require('../build/contracts/Demo').abi;
const DemoContract = new ethers.Contract(
  DemoContractAddress,
  DemoContractABI,
  provider
);

const ethereumWallet = new ethers.Wallet('0x' + privKey, provider);
const contract = new ethers.Contract(
  DemoContractAddress,
  DemoContractABI,
  ethereumWallet
);

console.log('Start Network Node...');

const start = async () => {
  const res = await contract.oracleValue().catch(console.log);
  console.log(res);
};

start();
