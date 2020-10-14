# Oracle Mainchain Contract
## Usage
```solidity
using OracleClient for OracleClient.Request;

function createRequest(
        string memory _url,
        string memory _path,
        string memory _callbackFunction,
        string memory _resType)
        public
    {
        OracleClient.Request memory req;
        req.init(_url, _path, _callbackFunction, _resType);
        bool isSuccess = req.send(oracleContractAddress, address(this));
        require(isSuccess, "failed to call oracle function");
    }
```

## Test
```
$ yarn test
```
