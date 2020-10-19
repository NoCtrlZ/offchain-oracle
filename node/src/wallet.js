"use strict";
exports.__esModule = true;
var ethereumjs_wallet_1 = require("ethereumjs-wallet");
var NodeWallet = /** @class */ (function () {
    function NodeWallet() {
        var _this = this;
        this.getAddress = function () { return _this.address; };
        this.getPublicKey = function () { return _this.publicKey; };
        this.getPrivateKey = function () { return _this.privateKey; };
        var wallet = ethereumjs_wallet_1["default"].generate();
        this.address = wallet.getAddressString();
        this.publicKey = wallet.getPublicKeyString();
        this.privateKey = wallet.getPrivateKeyString();
    }
    return NodeWallet;
}());
exports["default"] = NodeWallet;
