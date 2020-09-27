pragma solidity 0.7.0;

import "./Modules.sol";

contract Storage {
    using Modules for Modules.Request;

    mapping (bytes32 => mapping(bytes32 => Modules.Request)) public requestStorage;
}