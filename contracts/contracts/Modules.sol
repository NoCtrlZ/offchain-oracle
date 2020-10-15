// SPDX-License-Identifier: MIT
pragma solidity 0.7.0;

import "./Common.sol";

library Modules {
    using Common for Common.ResultType;

    struct Request {
        address callbackAddress;
        string callbackFunction;
        Common.ResultType resType;
    }

    function init(
        Request memory self,
        address _callbackAddress,
        string memory _callbackFunction,
        Common.ResultType _resType)
        internal pure returns (Modules.Request memory)
    {
        self.callbackAddress = _callbackAddress;
        self.callbackFunction = _callbackFunction;
        self.resType = _resType;
    }
}
