const Oracle = artifacts.require("Oracle")
const Modules = artifacts.require("Modules")

module.exports = async(deployer, _, accounts) => {
  await deployer.deploy(Modules, {from: accounts[0]})
  await deployer.link(Modules, Oracle)
  await deployer.deploy(Oracle, accounts[0], {from: accounts[0]})
};
