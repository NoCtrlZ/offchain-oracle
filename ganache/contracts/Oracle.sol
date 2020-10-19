// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;
pragma solidity 0.7.0;

import "./Storage.sol";
import "./Modules.sol";
import "./Common.sol";

contract Oracle is Storage {
    using Modules for Modules.Request;
    using Common for Common.ResultType;

    uint8 public difficulty;

    event RequestCreation(string url, string path, address callbackAddress, string callbackFunction, Common.ResultType resType, uint256 minReporter, bytes32 index);
    event RequestAgain(string url, string path, address callbackAddress, string callbackFunction, Common.ResultType resType, bytes32 index);
    event CommitAdmin(bytes32 index, uint256 nonce, address admin);
    event WithdrawEther(address withdrawer, uint256 amount);

    constructor() {
        difficulty = 1;
    }

    modifier isEnoughEther(uint256 _etherValue, uint256 _numberOfReporter)
    {
        require(
            isSatisfiedAmount(_etherValue, _numberOfReporter),
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

    modifier onlyAdmin(bytes32 _index)
    {
        require(
            msg.sender == oracleAdmin[_index],
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
        Modules.Request memory req = requestStorage[keccak256(abi.encode(Common.ResultType.STRING))][_index];
        (bool isSuccess, ) = req.callbackAddress.call(abi.encodeWithSignature(req.callbackFunction, _value));
        require(isSuccess, "failed to execute callback function");
        isRequestComplete[_index] = true;
    }

    function responseUint(bytes32 _index, uint256 _value) internal
    {
        Modules.Request memory req = requestStorage[keccak256(abi.encode(Common.ResultType.UINT256))][_index];
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
        depositStorage[msg.sender] = false;
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
        public onlyAdmin(_index)
    {
        rewardAndPunish(_rewardAddress, _punishAddress);
        responseString(_index, _value);
    }

    function uintResult(
        bytes32 _index,
        uint256 _value,
        address[] memory _rewardAddress,
        address[] memory _punishAddress)
        public onlyAdmin(_index)
    {
        rewardAndPunish(_rewardAddress, _punishAddress);
        responseUint(_index, _value);
    }

    function isSatisfiedAmount(
        uint256 _amountOfEther,
        uint256 _numberOfReporter)
        internal pure returns (bool)
    {
        return _amountOfEther >= Modules.calculateGasFee(_numberOfReporter);
    }

    function commitAdmin(bytes32 _index, uint256 _nonce) isStaking public returns(bool) {
        bytes32 checker = keccak256(abi.encodePacked(_index, _nonce));
        for (uint i = 0; i < difficulty; i++) {
            if (checker[i] != _index[i]) {
                return false;
            }
        }
        oracleAdmin[_index] = msg.sender;
        emit CommitAdmin(_index, _nonce, msg.sender);
        return true;
    }

    function slice(string memory self) public pure returns(bytes32) {
        bytes memory test = bytes(self);
        return test[2];
    }
}
