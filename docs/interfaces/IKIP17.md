
Required interface of an KIP17 compliant contract.



## Functions
### balanceOf
```solidity
  function balanceOf(
  ) external returns (uint256 balance)
```

Returns the number of NFTs in `owner`'s account.


### ownerOf
```solidity
  function ownerOf(
  ) external returns (address owner)
```

Returns the owner of the NFT specified by `tokenId`.


### safeTransferFrom
```solidity
  function safeTransferFrom(
  ) external
```

Transfers a specific NFT (`tokenId`) from one account (`from`) to
another (`to`).

Requirements:
- `from`, `to` cannot be zero.
- `tokenId` must be owned by `from`.
- If the caller is not `from`, it must be have been allowed to move this
NFT by either `approve` or `setApproveForAll`.


### transferFrom
```solidity
  function transferFrom(
  ) external
```

Transfers a specific NFT (`tokenId`) from one account (`from`) to
another (`to`).

Requirements:
- If the caller is not `from`, it must be approved to move this NFT by
either `approve` or `setApproveForAll`.


### approve
```solidity
  function approve(
  ) external
```




### getApproved
```solidity
  function getApproved(
  ) external returns (address operator)
```




### setApprovalForAll
```solidity
  function setApprovalForAll(
  ) external
```




### isApprovedForAll
```solidity
  function isApprovedForAll(
  ) external returns (bool)
```




### safeTransferFrom
```solidity
  function safeTransferFrom(
  ) external
```




### supportsInterface
```solidity
  function supportsInterface(
  ) external returns (bool)
```

Returns true if this contract implements the interface defined by
`interfaceId`. See the corresponding
[KIP-13 section](http://kips.klaytn.com/KIPs/kip-13-interface_query_standard#how-interface-identifiers-are-defined)
to learn more about how these ids are created.

This function call must use less than 30 000 gas.


## Events
### Transfer
```solidity
  event Transfer(
  )
```



### Approval
```solidity
  event Approval(
  )
```



### ApprovalForAll
```solidity
  event ApprovalForAll(
  )
```



