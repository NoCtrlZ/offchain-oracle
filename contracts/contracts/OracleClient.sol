// SPDX-License-Identifier: MIT
pragma solidity 0.7.0;

import "./Common.sol";

library OracleClient {
    using Common for Common.ResultType;

    struct Request {
        string url;
        string path;
        string callbackFunction;
        Common.ResultType resType;
        uint256 minReporter;
    }

    function init(
        Request memory self,
        string memory _url,
        string memory _path,
        string memory _callbackFunction,
        Common.ResultType _resType,
        uint256 _minReporter)
        internal pure returns (OracleClient.Request memory)
    {
        self.url = _url;
        self.path = _path;
        self.callbackFunction = _callbackFunction;
        self.resType = _resType;
        self.minReporter = _minReporter;
    }

    function send(
        Request memory self,
        address _oracleContractAddress,
        address _callbackAddress)
        internal returns (bool)
    {
        (bool isSuccess, ) = _oracleContractAddress.call{ value: msg.value }(
            abi.encodeWithSignature("request(string,string,address,string,uint8,uint256)",
            self.url,
            self.path,
            _callbackAddress,
            self.callbackFunction,
            self.resType,
            self.minReporter
        ));
        require(isSuccess, "failed to execute oracle function");
        return isSuccess;
    }
}
