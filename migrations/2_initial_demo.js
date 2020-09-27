const Oracle = artifacts.require("Oracle")
const Modules = artifacts.require("Modules")
const Demo = artifacts.require("Demo")

module.exports = async(deployer, _, accounts) => {
  await deployer.deploy(Modules, {from: accounts[0]})
  await deployer.link(Modules, Demo)
  await deployer.deploy(Demo, Oracle.address, {from: accounts[0]})
};
