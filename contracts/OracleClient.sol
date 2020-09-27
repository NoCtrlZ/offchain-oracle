// SPDX-License-Identifier: MIT
pragma solidity 0.7.0;

library OracleClient {
    struct Request {
        string url;
        string path;
        string callbackFunction;
        string resType;
    }

    function init(
        Request memory self,
        string memory _url,
        string memory _path,
        string memory _callbackFunction,
        string memory _resType)
        internal pure returns (OracleClient.Request memory)
    {
        self.url = _url;
        self.path = _path;
        self.callbackFunction = _callbackFunction;
        self.resType = _resType;
    }

    function send(
        Request memory self,
        address _oracleContractAddress,
        address _callbackAddress)
        internal returns (bool)
    {
        (bool isSuccess, ) = _oracleContractAddress.call(
            abi.encodeWithSignature("request(string,string,address,string,string)",
            self.url,
            self.path,
            _callbackAddress,
            self.callbackFunction,
            self.resType
        ));
        require(isSuccess, "failed to execute oracle function");
        return isSuccess;
    }
}
