// SPDX-License-Identifier: MIT
pragma solidity 0.7.0;

import "./Storage.sol";
import "./Modules.sol";
import "./Common.sol";

contract Oracle is Storage {
    using Modules for Modules.Request;
    using Common for Common.ResultType;

    address public networkAddress;
    uint256 constant returnFunctionGasFee = 1 ether / 20;
    event RequestCreation(string url, string path, address callbackAddress, string callbackFunction, Common.ResultType resType, uint256 minReporter, bytes32 index);
    event RequestAgain(string url, string path, address callbackAddress, string callbackFunction, Common.ResultType resType, bytes32 index);
    event WithdrawEther(address withdrawer, uint256 amount);

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

    function request(
        string memory _url,
        string memory _path,
        address _callbackAddress,
        string memory _callbackFunction,
        Common.ResultType _resType,
        uint256 _numberOfReporter)
        public
        payable
        isEnoughEther(msg.value, _numberOfReporter)
    {
        Modules.Request memory req;
        bytes32 index = keccak256(abi.encodePacked(_url, _path, _callbackAddress, _callbackFunction));
        req.init(_callbackAddress, _callbackFunction, _resType);
        requestStorage[keccak256(abi.encode(_resType))][index] = req;
        isRequestComplete[index] = false;
        emit RequestCreation(_url, _path, _callbackAddress, _callbackFunction, _resType, _numberOfReporter, index);
    }

    function requestAgain(
        string memory _url,
        string memory _path,
        address _callbackAddress,
        string memory _callbackFunction,
        Common.ResultType _resType)
        public
    {
        bytes32 index = keccak256(abi.encodePacked(_url, _path, _callbackAddress, _callbackFunction));
        require(!isRequestComplete[index], "request was already completed");
        emit RequestAgain(_url, _path, _callbackAddress, _callbackFunction, _resType, index);
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
        uint256 withdrawAmout = 1 ether - (punishStorage[msg.sender] * 1e17) + (rewardStorage[msg.sender] * 1e14);
        msg.sender.transfer(withdrawAmout);
        WithdrawEther(msg.sender, withdrawAmout);
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
