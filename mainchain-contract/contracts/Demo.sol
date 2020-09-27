// SPDX-License-Identifier: MIT
pragma solidity 0.7.0;

import "./OracleClient.sol";

contract Demo {
    address public oracleContractAddress;
    bool public isOracleOpen;
    string public oracleValue;

    using OracleClient for OracleClient.Request;

    constructor(address _oracleContractAddress) {
        oracleContractAddress = _oracleContractAddress;
    }

    modifier onlyOracle() {
        require(
            msg.sender == oracleContractAddress,
            "this function have to be called by owner"
        );
        isOracleOpen = false;
        _;
    }

    function createRequest(
        string memory _url,
        string memory _path,
        string memory _callbackFunction,
        string memory _resType)
        public
    {
        OracleClient.Request memory req;
        req.init(_url, _path, _callbackFunction, _resType);
        bool isSuccess = req.send(oracleContractAddress, address(this));
        require(isSuccess, "failed to call oracle function");
    }

    function receiveOracle(string memory oracle) external {
        oracleValue = oracle;
    }
}
