import Wallet from 'ethereumjs-wallet';

export default class NodeWallet {
  address: string;
  publicKey: string;
  privateKey: string;

  constructor() {
    const wallet = Wallet.generate();
    this.address = wallet.getAddressString();
    this.publicKey = wallet.getPublicKeyString();
    this.privateKey = wallet.getPrivateKeyString();
  }

  getAddress = () => this.address;
  getPublicKey = () => this.publicKey;
  getPrivateKey = () => this.privateKey;
}
