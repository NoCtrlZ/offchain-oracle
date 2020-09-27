pragma solidity 0.6.0;

library Modules {
    struct Request {
        address callbackAddress;
        bytes4 callbackFunction;
    }

    function init(
        Request memory self,
        address _callbackAddress,
        bytes4 _callbackFunction
    ) internal pure returns (Modules.Request memory) {
        self.callbackAddress = _callbackAddress;
        self.callbackFunction = _callbackFunction;
    }
}
