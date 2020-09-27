pragma solidity 0.6.0;

import "./Modules.sol";

contract Storage {
    using Modules for Modules.Request;

    mapping (bytes32 => Modules.Request) public requestStorage;
}
