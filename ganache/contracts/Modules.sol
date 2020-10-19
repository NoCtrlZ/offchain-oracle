// SPDX-License-Identifier: MIT
pragma solidity 0.7.0;

import "./Common.sol";

library Modules {
    using Common for Common.ResultType;

    uint256 constant returnFunctionGasFee = 1 ether / 20;

    struct Request {
        string url;
        string path;
        address callbackAddress;
        string callbackFunction;
        uint256 minReporter;
        uint256 timestamp;
        Common.ResultType resType;
    }

    function init(
        Request memory self,
        string memory _url,
        string memory _path,
        address _callbackAddress,
        string memory _callbackFunction,
        uint256 _minReporter,
        uint256 _timestamp,
        Common.ResultType _resType)
        internal pure returns (Modules.Request memory)
    {
        self.url = _url;
        self.path = _path;
        self.callbackAddress = _callbackAddress;
        self.callbackFunction = _callbackFunction;
        self.minReporter = _minReporter;
        self.timestamp = _timestamp;
        self.resType = _resType;
    }

    function calculateGasFee(uint256 _minReporter) public pure returns(uint256)
    {
        return (_minReporter * 1e14) + returnFunctionGasFee;
    }
}
