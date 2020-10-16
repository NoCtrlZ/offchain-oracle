import NodeWallet from './wallet'
// import NodeProp from './network'

const createWallet = () => {
  const wallet = new NodeWallet()
  // const node = new NodeProp(wallet.getAddress())
  console.log(wallet)
}

createWallet()
