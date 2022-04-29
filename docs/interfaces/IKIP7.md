
Interface of the KIP7 standard as defined in the KIP. Does not include
the optional functions; to access them see `KIP7Metadata`.
See http://kips.klaytn.com/KIPs/kip-7-fungible_token



## Functions
### totalSupply
```solidity
  function totalSupply(
  ) external returns (uint256)
```

Returns the amount of tokens in existence.


### balanceOf
```solidity
  function balanceOf(
  ) external returns (uint256)
```

Returns the amount of tokens owned by `account`.


### transfer
```solidity
  function transfer(
  ) external returns (bool)
```

Moves `amount` tokens from the caller's account to `recipient`.

Returns a boolean value indicating whether the operation succeeded.

Emits a `Transfer` event.


### allowance
```solidity
  function allowance(
  ) external returns (uint256)
```

Returns the remaining number of tokens that `spender` will be
allowed to spend on behalf of `owner` through `transferFrom`. This is
zero by default.

This value changes when `approve` or `transferFrom` are called.


### approve
```solidity
  function approve(
  ) external returns (bool)
```

Sets `amount` as the allowance of `spender` over the caller's tokens.

Returns a boolean value indicating whether the operation succeeded.

> Beware that changing an allowance with this method brings the risk
that someone may use both the old and the new allowance by unfortunate
transaction ordering. One possible solution to mitigate this race
condition is to first reduce the spender's allowance to 0 and set the
desired value afterwards:
https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

Emits an `Approval` event.


### transferFrom
```solidity
  function transferFrom(
  ) external returns (bool)
```

Moves `amount` tokens from `sender` to `recipient` using the
allowance mechanism. `amount` is then deducted from the caller's
allowance.

Returns a boolean value indicating whether the operation succeeded.

Emits a `Transfer` event.


### safeTransfer
```solidity
  function safeTransfer(
  ) external
```

Moves `amount` tokens from the caller's account to `recipient`.


### safeTransfer
```solidity
  function safeTransfer(
  ) external
```

 Moves `amount` tokens from the caller's account to `recipient`.


### safeTransferFrom
```solidity
  function safeTransferFrom(
  ) external
```

Moves `amount` tokens from `sender` to `recipient` using the allowance mechanism.
`amount` is then deducted from the caller's allowance.


### safeTransferFrom
```solidity
  function safeTransferFrom(
  ) external
```

Moves `amount` tokens from `sender` to `recipient` using the allowance mechanism.
`amount` is then deducted from the caller's allowance.


### increaseApproval
```solidity
  function increaseApproval(
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

Emitted when `value` tokens are moved from one account (`from`) to
another (`to`).

Note that `value` may be zero.

### Approval
```solidity
  event Approval(
  )
```

Emitted when the allowance of a `spender` for an `owner` is set by
a call to `approve`. `value` is the new allowance.

