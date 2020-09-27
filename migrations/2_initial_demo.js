const fs =  require('fs')
const path =  require('path')
const { promisify } = require('util')
const writeFileAsync = promisify(fs.readFile)
const Oracle = artifacts.require("Oracle")
const Modules = artifacts.require("Modules")
const Demo = artifacts.require("Demo")

module.exports = async(deployer, network, accounts) => {
  await deployer.deploy(Modules, {from: accounts[0]})
  await deployer.link(Modules, Demo)
  await deployer.deploy(Demo, Oracle.address, {from: accounts[0]})
  emitFile(network, Oracle.address, Demo.address)
};

const emitFile = (network, oracleAddress, demoAddress) => {
  const contents = {
    Oracle: oracleAddress,
    Demo: demoAddress
  }
  fs.writeFileSync(projectFilePath(network), JSON.stringify(contents, null, '    '), err => {
    if (err) throw err
    console.log('Successful in creating file')
})
}

const projectFilePath = network => path.join(__dirname, '..', 'sample', `${network}.json`)
