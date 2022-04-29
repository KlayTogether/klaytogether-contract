This TwabLib adds on-chain historical lookups to a user(s) time-weighted average balance.
            Each user is mapped to an Account struct containing the TWAB history (ring bufffer) and
            ring buffer parameters. Every token.transfer() creates a new TWAB checkpoint. The new TWAB
            checkpoint is stored in the circular ring buffer, as either a new checkpoint or rewriting
            a previous checkpoint with new parameters. The TwabLib (using existing blocktimes 1block/15sec)
            guarantees minimum 7.4 years of search history.
   Time-Weighted Average Balance Library for ERC20 tokens.


## Structs
### `AccountDetails`
  - uint208 balance
  - uint24 nextTwabIndex
  - uint24 cardinality
### `Account`
  - struct TwabLib.AccountDetails details
  - struct ObservationLib.Observation[16777215] twabs


## Functions
