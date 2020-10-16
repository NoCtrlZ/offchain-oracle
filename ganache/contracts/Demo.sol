// SPDX-License-Identifier: MIT
pragma solidity 0.7.0;

import "./OracleClient.sol";
import "./Common.sol";

contract Demo {
    address public oracleContractAddress;
    bool public isOracleOpen;
    string public oracleValue;

    using OracleClient for OracleClient.Request;
    using Common for Common.ResultType;

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

    function createRequest()
        public
        payable
    {
        OracleClient.Request memory req;
        string memory _url = "https://ethgasstation.info/api/ethgasAPI.json";
        string memory _path = "gasPriceRange.10";
        string memory _callbackFunction = "receiveOracle(string)";
        uint256 _minReporter = 100;

        req.init(_url, _path, _callbackFunction, Common.ResultType.STRING, _minReporter);
        bool isSuccess = req.send(oracleContractAddress, address(this));
        require(isSuccess, "failed to call oracle function");
    }

    function receiveOracle(string memory oracle) external {
        oracleValue = oracle;
    }
}
