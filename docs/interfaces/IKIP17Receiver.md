
Interface for any contract that wants to support safeTransfers
from KIP17 asset contracts.
see http://kips.klaytn.com/KIPs/kip-17-non_fungible_token



## Functions
### onKIP17Received
```solidity
  function onKIP17Received(
    address operator,
    address from,
    uint256 tokenId,
    bytes data
  ) external returns (bytes4)
```
Handle the receipt of an NFT

The KIP17 smart contract calls this function on the recipient
after a `safeTransfer`. This function MUST return the function selector,
otherwise the caller will revert the transaction. The selector to be
returned can be obtained as `this.onKIP17Received.selector`. This
function MAY throw to revert and reject the transfer.
Note: the KIP17 contract address is always the message sender.

#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`operator` | address | The address which called `safeTransferFrom` function
|`from` | address | The address which previously owned the token
|`tokenId` | uint256 | The NFT identifier which is being transferred
|`data` | bytes | Additional data with no specified format

#### Return Values:
| Type          | Description                                                                  |
| :------------ | :--------------------------------------------------------------------------- |
| bytes4 | bytes4 `bytes4(keccak256("onKIP17Received(address,address,uint256,bytes)"))`
