pragma solidity 0.7.0;

contract Demo {
    address public oracleContractAddress;
    bool public isOracleOpen;
    string public oracleValue;

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

    function createRequest(
        string memory _url,
        string memory _path,
        string memory _callbackFunction,
        string memory _resType)
        public
    {
            (bool isSuccess, ) = oracleContractAddress.call(
                abi.encodeWithSignature("request(string,string,address,string,string)",
                _url,
                _path,
                address(this),
                _callbackFunction,
                _resType));
            require(isSuccess, "failed to execute oracle function");
            isOracleOpen = true;
    }

    function receiveOracle(string memory oracle) external {
        oracleValue = oracle;
    }
}
