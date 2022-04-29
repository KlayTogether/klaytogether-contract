
Interface of the KIP-13 standard, as defined in the
[KIP-13](http://kips.klaytn.com/KIPs/kip-13-interface_query_standard).

Implementers can declare support of contract interfaces, which can then be
queried by others.

For an implementation, see `KIP13`.



## Functions
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


