pragma solidity 0.6.0;

import "@openzeppelin/upgrades/contracts/Initializable.sol";
import "./Storage.sol";
import "./Modules.sol";

contract Oracle is Storage, Initializable {
    using Modules for Modules.Request;

    function Request(string memory _url, string memory _path, address _callbackAddress, bytes4 _callbackFunction) public {
        Modules.Request memory req;
        bytes32 index = keccak256(abi.encodePacked(_url, _path, _callbackAddress, _callbackFunction));
        req.init(_callbackAddress, _callbackFunction);
        requestStorage[index] = req;
    }
}
