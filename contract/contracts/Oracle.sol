// SPDX-License-Identifier: MIT
pragma solidity 0.7.0;

import "./Storage.sol";
import "./Modules.sol";

contract Oracle is Storage {
    address public networkAddress;
    event RequestCreation(string url, string path, address callbackAddress, string callbackFunction, string resType, bytes32 index);
    using Modules for Modules.Request;

    constructor(address _networkAddress) {
        networkAddress = _networkAddress;
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

    modifier isFromNetwork(address _caller)
    {
        require(
            _caller == networkAddress,
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
        string memory _resType)
        public
        isValidRequest(_resType)
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

    function responseString(bytes32 _index, string memory _value) public isFromNetwork(msg.sender)
    {
        Modules.Request memory req = requestStorage[keccak256(bytes("string"))][_index];
        (bool isSuccess, ) = req.callbackAddress.call(abi.encodeWithSignature(req.callbackFunction, _value));
        require(isSuccess, "failed to execute callback function");
    }

    function responseUint(bytes32 _index, uint256 _value) public isFromNetwork(msg.sender)
    {
        Modules.Request memory req = requestStorage[keccak256(bytes("uint"))][_index];
        (bool isSuccess, ) = req.callbackAddress.call(abi.encodeWithSignature(req.callbackFunction, _value));
        require(isSuccess, "failed to execute callback function");
        isRequestComplete[_index] = true;
    }

    function getOracleContractAddress() view public returns (address)
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
        msg.sender.transfer(1 ether);
    }

    function unlock() public isLock
    {
        lockAddressStorage[msg.sender] = false;
    }

    function isDeposit(address _checkAddress) public view returns(bool)
    {
        return depositStorage[_checkAddress];
    }
}
