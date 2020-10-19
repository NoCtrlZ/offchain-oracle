// SPDX-License-Identifier: MIT
pragma solidity 0.7.0;

import "./Common.sol";

library Modules {
    using Common for Common.ResultType;

    uint256 constant returnFunctionGasFee = 1 ether / 20;

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

    function calculateGasFee(uint256 _minReporter) public pure returns(uint256)
    {
        return (_minReporter * 1e14) + returnFunctionGasFee;
    }
}
