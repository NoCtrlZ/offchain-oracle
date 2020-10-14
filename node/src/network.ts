import KBucket from './kbucket'

export default class Network {
    kBucket: KBucket

    constructor(address: KBucket) {
        this.kBucket = address
    }
}
