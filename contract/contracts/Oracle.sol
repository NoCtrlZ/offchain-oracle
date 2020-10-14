// SPDX-License-Identifier: MIT
pragma solidity 0.7.0;

import "./Storage.sol";
import "./Modules.sol";

contract Oracle is Storage {
    address public networkAddress;
    uint256 constant returnFunctionGasFee = 1 ether / 20;
    event RequestCreation(string url, string path, address callbackAddress, string callbackFunction, string resType, bytes32 index);
    using Modules for Modules.Request;

    constructor(address _networkAddress) {
        networkAddress = _networkAddress;
    }

    modifier isEnoughEther(uint256 _etherValue, uint256 _numberOfReporter)
    {
        require(
            isSatisfiedAmount(_etherValue, returnFunctionGasFee, _numberOfReporter),
            "value is not enough"
        );
        _;
    }

    modifier isLock()
    {
        require(
            lockAddressStorage[msg.sender],
            "address is not locked"
        );
        _;
    }

    modifier isNotLock()
    {
        require(
            !lockAddressStorage[msg.sender],
            "address is locked"
        );
        _;
    }

    modifier isStaking()
    {
        require(
            depositStorage[msg.sender],
            "address owner is not staking"
        );
        depositStorage[msg.sender] = false;
        _;
    }

    modifier isNotStaking()
    {
        require(
            !depositStorage[msg.sender],
            "address owner is already staking"
        );
        _;
    }

    modifier isEtherSatisfied()
    {
        require(
            msg.value >= 1 ether,
            "ether value is not satisfied"
        );
        _;
    }

    modifier onlyNetwork()
    {
        require(
            msg.sender == networkAddress,
            "caller is invalid"
        );
        _;
    }

    modifier isValidRequest(string memory _resType)
    {
        require(
            keccak256(bytes(_resType)) == keccak256(bytes("string")) || keccak256(bytes(_resType)) == keccak256(bytes("uint")),
            "return type is invalid"
        );
        _;
    }

    function request(
        string memory _url,
        string memory _path,
        address _callbackAddress,
        string memory _callbackFunction,
        string memory _resType,
        uint256 _numberOfReporter)
        public
        payable
        isValidRequest(_resType)
        isEnoughEther(msg.value, _numberOfReporter)
    {
        Modules.Request memory req;
        bytes32 index = keccak256(abi.encodePacked(_url, _path, _callbackAddress, _callbackFunction));
        req.init(_callbackAddress, _callbackFunction, _resType);
        requestStorage[keccak256(bytes(_resType))][index] = req;
        isRequestComplete[index] = false;
        emit RequestCreation(_url, _path, _callbackAddress, _callbackFunction, _resType, index);
    }

    function requestAgain(
        string memory _url,
        string memory _path,
        address _callbackAddress,
        string memory _callbackFunction,
        string memory _resType)
        public
        isValidRequest(_resType)
    {
        bytes32 index = keccak256(abi.encodePacked(_url, _path, _callbackAddress, _callbackFunction));
        require(!isRequestComplete[index], "request was already completed");
        emit RequestCreation(_url, _path, _callbackAddress, _callbackFunction, _resType, index);
    }

    function responseString(bytes32 _index, string memory _value) internal
    {
        Modules.Request memory req = requestStorage[keccak256(bytes("string"))][_index];
        (bool isSuccess, ) = req.callbackAddress.call(abi.encodeWithSignature(req.callbackFunction, _value));
        require(isSuccess, "failed to execute callback function");
        isRequestComplete[_index] = true;
    }

    function responseUint(bytes32 _index, uint256 _value) internal
    {
        Modules.Request memory req = requestStorage[keccak256(bytes("uint"))][_index];
        (bool isSuccess, ) = req.callbackAddress.call(abi.encodeWithSignature(req.callbackFunction, _value));
        require(isSuccess, "failed to execute callback function");
        isRequestComplete[_index] = true;
    }

    function getOracleContractAddress() view public returns(address)
    {
        return address(this);
    }

    function depositEther() public payable isEtherSatisfied isNotStaking
    {
        depositStorage[msg.sender] = true;
        lockAddressStorage[msg.sender] = true;
    }

    function withdrawEther() public payable isStaking isNotLock
    {
        msg.sender.transfer(1 ether - (punishStorage[msg.sender] * 1e17) + (rewardStorage[msg.sender] * 1e14));
    }

    function unlock() public isLock
    {
        lockAddressStorage[msg.sender] = false;
    }

    function isDeposit(address _checkAddress) public view returns(bool)
    {
        return depositStorage[_checkAddress];
    }

    function rewardAndPunish(address[] memory _rewardAddress, address[] memory _punishAddress) internal
    {
        for (uint i = 0; i < _rewardAddress.length; i++) {
            rewardStorage[_rewardAddress[i]]++;
        }
        for (uint i = 0; i < _punishAddress.length; i++) {
            if (punishStorage[_punishAddress[i]] == 9) {
                depositStorage[_punishAddress[i]] = false;
            } else {
                punishStorage[_punishAddress[i]]++;
            }
        }
    }

    function stringResult(
        bytes32 _index,
        string memory _value,
        address[] memory _rewardAddress,
        address[] memory _punishAddress)
        public onlyNetwork
    {
        rewardAndPunish(_rewardAddress, _punishAddress);
        responseString(_index, _value);
    }

    function uintResult(
        bytes32 _index,
        uint256 _value,
        address[] memory _rewardAddress,
        address[] memory _punishAddress)
        public onlyNetwork
    {
        rewardAndPunish(_rewardAddress, _punishAddress);
        responseUint(_index, _value);
    }

    function isSatisfiedAmount(
        uint256 _amountOfEther,
        uint256 _returnFunctionGasFee,
        uint256 _numberOfReporter)
        internal pure returns (bool)
    {
        return (_amountOfEther >= (_numberOfReporter * 1e14) + _returnFunctionGasFee);
    }

    function calculateGasFee(uint256 _minReporter) public pure returns(uint256)
    {
        return (_minReporter * 1e14) + returnFunctionGasFee;
    }
}
