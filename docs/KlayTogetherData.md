Collects and processes data from prize pools and prize calculators


## Structs
### `CurrentRoundInfo`
  - uint256 currentRound
  - uint256 lastRoundPrize
  - uint256 accumulatedPrize
  - uint256 accumulatedKsp
  - uint256 totalDeposit
  - uint256 roundStartedAt
  - uint256 roundEndsAt
  - uint256 commissionRate
### `UserAccountInfo`
  - uint256 allowance
  - uint256 deposit
  - uint256 averageBalance
  - uint256 averageTotalSupply
  - uint256 totalWinnings
  - uint256 unclaimedWinnings
  - uint256[] winningRounds
  - uint64[] winningDates
  - uint256[] winningPrizes
### `RoundHistory`
  - uint256[] rounds
  - uint64[] endTimes
  - uint256[] prizes
  - address[] winners


## Functions
### constructor
```solidity
  function constructor(
    contract IPrizePool[] _prizePools
  ) public
```
Deploy the Klay Together Data


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`_prizePools` | contract IPrizePool[] | Address of the deployed Prize Pools

### getExpectedPrize
```solidity
  function getExpectedPrize(
  ) public returns (uint256)
```

Returns the prize pool's balance that is available to award


### getKspAmount
```solidity
  function getKspAmount(
  ) public returns (uint256)
```

Returns the prize pool's KSP balance


### getTotalDeposit
```solidity
  function getTotalDeposit(
  ) public returns (uint256)
```

Returns the prize pool's total deposit


### getCommissionRate
```solidity
  function getCommissionRate(
  ) public returns (uint256)
```

Returns the prize pool's commission rate


### getUserDeposit
```solidity
  function getUserDeposit(
  ) public returns (uint256)
```

Returns the prize pool's deposit from the user


### getUserAllowance
```solidity
  function getUserAllowance(
  ) public returns (uint256)
```

Returns user's KIP7 allowance to the prize pool


### getCurrentRoundInfo
```solidity
  function getCurrentRoundInfo(
  ) public returns (struct KlayTogetherData.CurrentRoundInfo[])
```

Returns current CurrentRoundInfo list


### getUserInformation
```solidity
  function getUserInformation(
  ) public returns (struct KlayTogetherData.UserAccountInfo[])
```

Returns current UserAccountInfo list


### getRoundHistories
```solidity
  function getRoundHistories(
    uint256 count
  ) public returns (struct KlayTogetherData.RoundHistory[])
```
Iterates from the latest settled round and return each round's data.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`count` | uint256 | Number of rounds to iterate (when zero, it return the whole history).

#### Return Values:
| Type          | Description                                                                  |
| :------------ | :--------------------------------------------------------------------------- |
| struct KlayTogetherData.RoundHistory[] | RoundHistory list for every prize pool
### getCurrentBlockNumber
```solidity
  function getCurrentBlockNumber(
  ) public returns (uint256)
```




### getCurrentTimestamp
```solidity
  function getCurrentTimestamp(
  ) public returns (uint256)
```




