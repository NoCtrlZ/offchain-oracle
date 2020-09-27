pragma solidity 0.7.0;

contract Demo {
    address oracleContractAddress;
    bool isOracleOpen;
    string oracleValue;

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
        string memory _resType)
        public
    {
            (bool isSuccess, ) = oracleContractAddress.delegatecall(
                abi.encodeWithSignature("request(string,string,address,string,string",
                _url,
                _path,
                address(this),
                "receiveOracle(string)",
                _resType));
            require(isSuccess, "failed to execute callback function");
            isOracleOpen = true;
    }

    function receiveOracle(string memory oracle) external {
        oracleValue = oracle;
    }
}
