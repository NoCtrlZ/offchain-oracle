const host = 'http://ganache:7545'
const ethers = require("ethers")
const contracts = require("../sample/development.json")
const provider = new ethers.providers.JsonRpcProvider(host)

const OracleContractAddress = contracts.Oracle
const OracleContractABI = require("../build/contracts/Oracle").abi
const OracleContract = new ethers.Contract(OracleContractAddress, OracleContractABI, provider)

console.log("Start Subscribing Event...")

OracleContract.on("RequestCreation", async (url: string, path: string, callbackAddress: string, callbackFunction: string, resType: number, minReporter: number, index: string) => {
    console.log("url: ", url)
    console.log("path: ", path)
    console.log("callbackAddress: ", callbackAddress)
    console.log("callbackFunction: ", callbackFunction)
    console.log("resType: ", resType)
    console.log("minReporter: ", minReporter)
    console.log("index: ", index)
})
