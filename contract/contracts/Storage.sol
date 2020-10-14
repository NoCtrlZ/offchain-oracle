// SPDX-License-Identifier: MIT
pragma solidity 0.7.0;

import "./Modules.sol";

contract Storage {
    using Modules for Modules.Request;

    mapping (bytes32 => mapping(bytes32 => Modules.Request)) public requestStorage;
    mapping (bytes32 => bool) public isRequestComplete;
    mapping (address => bool) public depositStorage;
    mapping (address => uint256) public rewardStorage;
    mapping (address => bool) public lockAddressStorage;
}
