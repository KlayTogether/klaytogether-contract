


## Structs
### `AccountDetails`
  - uint224 balance
  - uint16 nextTwabIndex
  - uint16 cardinality
### `Account`
  - struct IPrizeCalculator.AccountDetails details
  - struct ObservationLib.Observation[65535] twabs


## Functions
### settleRound
```solidity
  function settleRound(
    uint256 count
  ) external
```
Iterates all participants of the current round and draw winner. Must be called after each round.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`count` | uint256 | Number of participants to iterate (when zero it goes over the whole list).

### deposit
```solidity
  function deposit(
    address user,
    uint256 amount
  ) external
```
Called by prize pool to record user deposit info.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`user` | address | User address.
|`amount` | uint256 | Deposit amount.

### withdraw
```solidity
  function withdraw(
    address user,
    uint256 amount
  ) external
```
Called by prize pool to record user withdarwal info.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`user` | address | User address.
|`amount` | uint256 | Withdrawal amount.

### getUserOdds
```solidity
  function getUserOdds(
    address user
  ) external returns (uint256, uint256)
```
Calculates user's average balance and average total supply of this round.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`user` | address | User address.

#### Return Values:
| Type          | Description                                                                  |
| :------------ | :--------------------------------------------------------------------------- |
| uint256 | s average balance and average total supply. Former divided by Latter becomes user's odds.
### getUserWinningRounds
```solidity
  function getUserWinningRounds(
    address user
  ) external returns (uint256[])
```
Returns all the rounds that the user has won.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`user` | address | User address.

#### Return Values:
| Type          | Description                                                                  |
| :------------ | :--------------------------------------------------------------------------- |
| uint256[] | List of rounds that the user has won.
### getUserAccumulatedPrize
```solidity
  function getUserAccumulatedPrize(
    address user
  ) external returns (uint256)
```
Returns accumulated prize that the user has won.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`user` | address | User address.

#### Return Values:
| Type          | Description                                                                  |
| :------------ | :--------------------------------------------------------------------------- |
| uint256 | Accumulated prize of the user.
### getUserWinHistory
```solidity
  function getUserWinHistory(
    address user
  ) external returns (uint256[], uint256[])
```
Returns the round numbers and prizes that the user has won.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`user` | address | User address.

#### Return Values:
| Type          | Description                                                                  |
| :------------ | :--------------------------------------------------------------------------- |
| uint256[] | Round list and prizes list that the user has won.
### getCurrentRound
```solidity
  function getCurrentRound(
  ) external returns (uint256)
```
Returns currunt round number.



#### Return Values:
| Type          | Description                                                                  |
| :------------ | :--------------------------------------------------------------------------- |
| uint256 | Current round number.
### getRoundInfo
```solidity
  function getRoundInfo(
    uint256 round
  ) external returns (uint64, uint64, uint256, address)
```
Returns the round's info.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`round` | uint256 | Round number.

#### Return Values:
| Type          | Description                                                                  |
| :------------ | :--------------------------------------------------------------------------- |
| uint64 | Start time, end time, prize, winner of the round
### getRoundParticipants
```solidity
  function getRoundParticipants(
    uint256 round
  ) external returns (address[])
```
Returns the round's participants


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`round` | uint256 | Round number.

#### Return Values:
| Type          | Description                                                                  |
| :------------ | :--------------------------------------------------------------------------- |
| address[] | Address list of the round's participants
### getRoundHistories
```solidity
  function getRoundHistories(
    uint256 count
  ) external returns (uint256[], uint64[], uint256[], address[])
```
Iterates from the latest settled round and return each round's data.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`count` | uint256 | Number of rounds to iterate (when zero, it returns the whole history).

#### Return Values:
| Type          | Description                                                                  |
| :------------ | :--------------------------------------------------------------------------- |
| uint256[] | Round number list, end time list, prize list, and winner list
### getPrizePool
```solidity
  function getPrizePool(
  ) external returns (address)
```
Returns the prize pool registered to this calculator.



#### Return Values:
| Type          | Description                                                                  |
| :------------ | :--------------------------------------------------------------------------- |
| address | Prize pool address.
### getAccountDetails
```solidity
  function getAccountDetails(
    address user
  ) external returns (struct TwabLib.AccountDetails)
```
Gets a users twab context.  This is a struct with their balance, next twab index, and cardinality.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`user` | address | The user for whom to fetch the TWAB context.

#### Return Values:
| Type          | Description                                                                  |
| :------------ | :--------------------------------------------------------------------------- |
| struct TwabLib.AccountDetails | The TWAB context, which includes { balance, nextTwabIndex, cardinality }
### getTwab
```solidity
  function getTwab(
    address user,
    uint16 index
  ) external returns (struct ObservationLib.Observation)
```
Gets the TWAB at a specific index for a user.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`user` | address | The user for whom to fetch the TWAB.
|`index` | uint16 | The index of the TWAB to fetch.

#### Return Values:
| Type          | Description                                                                  |
| :------------ | :--------------------------------------------------------------------------- |
| struct ObservationLib.Observation | The TWAB, which includes the twab amount and the timestamp.
### getBalanceAt
```solidity
  function getBalanceAt(
    address user,
    uint64 timestamp
  ) external returns (uint256)
```
Retrieves `user` TWAB balance.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`user` | address | Address of the user whose TWAB is being fetched.
|`timestamp` | uint64 | Timestamp at which we want to retrieve the TWAB balance.

#### Return Values:
| Type          | Description                                                                  |
| :------------ | :--------------------------------------------------------------------------- |
| uint256 | The TWAB balance at the given timestamp.
### getBalancesAt
```solidity
  function getBalancesAt(
    address user,
    uint64[] timestamps
  ) external returns (uint256[])
```
Retrieves `user` TWAB balances.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`user` | address | Address of the user whose TWABs are being fetched.
|`timestamps` | uint64[] | Timestamps range at which we want to retrieve the TWAB balances.

#### Return Values:
| Type          | Description                                                                  |
| :------------ | :--------------------------------------------------------------------------- |
| uint256[] | TWAB balances.
### getAverageBalanceBetween
```solidity
  function getAverageBalanceBetween(
    address user,
    uint64 startTime,
    uint64 endTime
  ) external returns (uint256)
```
Retrieves the average balance held by a user for a given time frame.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`user` | address | The user whose balance is checked.
|`startTime` | uint64 | The start time of the time frame.
|`endTime` | uint64 | The end time of the time frame.

#### Return Values:
| Type          | Description                                                                  |
| :------------ | :--------------------------------------------------------------------------- |
| uint256 | The average balance that the user held during the time frame.
### getAverageBalancesBetween
```solidity
  function getAverageBalancesBetween(
    address user,
    uint64[] startTimes,
    uint64[] endTimes
  ) external returns (uint256[])
```
Retrieves the average balances held by a user for a given time frame.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`user` | address | The user whose balance is checked.
|`startTimes` | uint64[] | The start time of the time frame.
|`endTimes` | uint64[] | The end time of the time frame.

#### Return Values:
| Type          | Description                                                                  |
| :------------ | :--------------------------------------------------------------------------- |
| uint256[] | The average balance that the user held during the time frame.
### getTotalSupplyAt
```solidity
  function getTotalSupplyAt(
    uint64 timestamp
  ) external returns (uint256)
```
Retrieves the total supply TWAB balance at the given timestamp.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`timestamp` | uint64 | Timestamp at which we want to retrieve the total supply TWAB balance.

#### Return Values:
| Type          | Description                                                                  |
| :------------ | :--------------------------------------------------------------------------- |
| uint256 | The total supply TWAB balance at the given timestamp.
### getTotalSuppliesAt
```solidity
  function getTotalSuppliesAt(
    uint64[] timestamps
  ) external returns (uint256[])
```
Retrieves the total supply TWAB balance between the given timestamps range.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`timestamps` | uint64[] | Timestamps range at which we want to retrieve the total supply TWAB balance.

#### Return Values:
| Type          | Description                                                                  |
| :------------ | :--------------------------------------------------------------------------- |
| uint256[] | Total supply TWAB balances.
### getAverageTotalSuppliesBetween
```solidity
  function getAverageTotalSuppliesBetween(
    uint64[] startTimes,
    uint64[] endTimes
  ) external returns (uint256[])
```
Retrieves the average total supply balance for a set of given time frames.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`startTimes` | uint64[] | Array of start times.
|`endTimes` | uint64[] | Array of end times.

#### Return Values:
| Type          | Description                                                                  |
| :------------ | :--------------------------------------------------------------------------- |
| uint256[] | The average total supplies held during the time frame.
## Events
### Winner
```solidity
  event Winner(
    address winner,
    uint256 round,
    uint256 prize
  )
```
Emitted when winner is picked.


#### Parameters:
| Name                           | Type          | Description                                    |
| :----------------------------- | :------------ | :--------------------------------------------- |
|`winner`| address | winner of the round.
|`round`| uint256 | round number.
|`prize`| uint256 | prize of the round.
### RoundSet
```solidity
  event RoundSet(
    uint256 round,
    uint64 startTime,
    uint64 endTime
  )
```
Emitted when round is set.


#### Parameters:
| Name                           | Type          | Description                                    |
| :----------------------------- | :------------ | :--------------------------------------------- |
|`round`| uint256 | round number.
|`startTime`| uint64 | when round starts.
|`endTime`| uint64 | when round finishes.
### NextRound
```solidity
  event NextRound(
    uint256 round,
    uint64 timestamp
  )
```
Emitted when round changes.


#### Parameters:
| Name                           | Type          | Description                                    |
| :----------------------------- | :------------ | :--------------------------------------------- |
|`round`| uint256 | round number.
|`timestamp`| uint64 | current time.
### PrizePoolSet
```solidity
  event PrizePoolSet(
    address prizePool
  )
```
Emitted when contract is initialized.


#### Parameters:
| Name                           | Type          | Description                                    |
| :----------------------------- | :------------ | :--------------------------------------------- |
|`prizePool`| address | prizePool contract address.
### NewUserTwab
```solidity
  event NewUserTwab(
    address user,
    struct ObservationLib.Observation newTwab
  )
```
Emitted when a new TWAB has been recorded.


#### Parameters:
| Name                           | Type          | Description                                    |
| :----------------------------- | :------------ | :--------------------------------------------- |
|`user`| address | Address of the user who newly deposited
|`newTwab`| struct ObservationLib.Observation | Updated TWAB of a the user after a successful TWAB recording.
### NewTotalSupplyTwab
```solidity
  event NewTotalSupplyTwab(
    struct ObservationLib.Observation newTotalSupplyTwab
  )
```
Emitted when a new total supply TWAB has been recorded.


#### Parameters:
| Name                           | Type          | Description                                    |
| :----------------------------- | :------------ | :--------------------------------------------- |
|`newTotalSupplyTwab`| struct ObservationLib.Observation | Updated TWAB of tickets total supply after a successful total supply TWAB recording.
