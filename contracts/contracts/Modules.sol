// SPDX-License-Identifier: MIT
pragma solidity 0.7.0;

library Modules {
    struct Request {
        address callbackAddress;
        string callbackFunction;
        string resType;
    }

    function init(
        Request memory self,
        address _callbackAddress,
        string memory _callbackFunction,
        string memory _resType)
        internal pure returns (Modules.Request memory)
    {
        self.callbackAddress = _callbackAddress;
        self.callbackFunction = _callbackFunction;
        self.resType = _resType;
    }
}
