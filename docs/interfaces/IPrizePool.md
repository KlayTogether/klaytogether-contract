




## Functions
### award
```solidity
  function award(
    uint256 round,
    address winner
  ) external returns (uint256)
```
Called by the prize calculator to award prizes.

When function is called, it exchanges all the interests to base token and records it to the winner.

#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`round` | uint256 | Round number
|`winner` | address | The winner of the round

#### Return Values:
| Type          | Description                                                                  |
| :------------ | :--------------------------------------------------------------------------- |
| uint256 | The amount awarded to the wiiner
### awardExternalKIP7
```solidity
  function awardExternalKIP7(
    address to,
    address amount,
    uint256 externalToken
  ) external
```
Award external KIP7 prizes when there is any. Only callable by the owner.

Used to award any arbitrary tokens held by the Prize Pool

#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`to` | address | The address of the winner that receives the award
|`amount` | address | The amount of external assets to be awarded
|`externalToken` | uint256 | The address of the external asset token being awarded

### awardExternalKIP17
```solidity
  function awardExternalKIP17(
    address to,
    address externalToken,
    uint256[] tokenIds
  ) external
```
Award external KIP7 prizes when there is any. Only callable by the owner.

Used to award any arbitrary NFTs held by the Prize Pool

#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`to` | address | The address of the winner that receives the award
|`externalToken` | address | The address of the external NFT token being awarded
|`tokenIds` | uint256[] | An array of NFT Token IDs to be transferred

### setPrizeCalculator
```solidity
  function setPrizeCalculator(
    address newPrizeCalculator
  ) external
```
Sets the prize calculator of the prize pool. Only callable by the owner.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`newPrizeCalculator` | address | The new prize calculator.

### deposit
```solidity
  function deposit(
    uint256 amount
  ) external
```
Deposit token into the Prize Pool. Reverts when base asset is not token contract.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`amount` | uint256 | The amount of token to deposit.

### depositKlay
```solidity
  function depositKlay(
  ) external
```
Deposit KLAY into the Prize Pool. Reverts when base asset is not KLAY.



### withdraw
```solidity
  function withdraw(
    uint256 amount
  ) external
```
Withdraw assets from the Prize Pool instantly.


#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`amount` | uint256 | Amount to withdraw

### withdrawPrize
```solidity
  function withdrawPrize(
  ) external
```
Withdraw all the prize that user has won from the Prize Pool.



### addSponsor
```solidity
  function addSponsor(
  ) external
```
Registers msg.sender to sponser list.



### removeSponsor
```solidity
  function removeSponsor(
  ) external
```
Removes msg.sender from sponser list.



### getCommissionRate
```solidity
  function getCommissionRate(
  ) external returns (uint256)
```
Returns commission rate.



#### Return Values:
| Type          | Description                                                                  |
| :------------ | :--------------------------------------------------------------------------- |
| uint256 | Commission rate in BP.
### getTotalDeposit
```solidity
  function getTotalDeposit(
  ) external returns (uint256)
```
Returns total deposit that Prize Pool holds.



### getUserDeposit
```solidity
  function getUserDeposit(
  ) external returns (uint256)
```
Returns user's total deposit.



### getUserUnclaimedPrize
```solidity
  function getUserUnclaimedPrize(
  ) external returns (uint256)
```
Returns user's unclaimed prize.



### balance
```solidity
  function balance(
  ) external returns (uint256)
```



#### Return Values:
| Type          | Description                                                                  |
| :------------ | :--------------------------------------------------------------------------- |
| uint256 | The underlying balance of assets
### awardBalance
```solidity
  function awardBalance(
  ) external returns (uint256)
```
Returns the balance that is available to award.

total underlying balance of all assets - total deposit


#### Return Values:
| Type          | Description                                                                  |
| :------------ | :--------------------------------------------------------------------------- |
| uint256 | The total amount of assets to be awarded for the current round
### canAwardExternal
```solidity
  function canAwardExternal(
    address externalToken
  ) external returns (bool)
```

Checks with the Prize Pool if a specific token type may be awarded as an external prize

#### Parameters:
| Name | Type | Description                                                          |
| :--- | :--- | :------------------------------------------------------------------- |
|`externalToken` | address | The address of the token to check

#### Return Values:
| Type          | Description                                                                  |
| :------------ | :--------------------------------------------------------------------------- |
| bool | True if the token may be awarded, false otherwise
### getToken
```solidity
  function getToken(
  ) external returns (address)
```
Read token variable



### getPrizeCalculator
```solidity
  function getPrizeCalculator(
  ) external returns (address)
```
Read prizeCalculator variable



## Events
### Deposited
```solidity
  event Deposited(
  )
```

Event emitted when assets are deposited

### Awarded
```solidity
  event Awarded(
  )
```

Event emitted when interest is awarded to a winner

### Withdrew
```solidity
  event Withdrew(
  )
```

Event emitted when assets are withdrawn

### AwardedExternalKIP7
```solidity
  event AwardedExternalKIP7(
  )
```

Event emitted when external KIP7s are awarded to a winner

### AwardedExternalKIP17
```solidity
  event AwardedExternalKIP17(
  )
```

Event emitted when external KIP17s are awarded to a winner

### UpdateCommissionAccount
```solidity
  event UpdateCommissionAccount(
  )
```

Event emitted when commission account is updated

### UpdateCommissionRate
```solidity
  event UpdateCommissionRate(
  )
```

Event emitted when commission rate is updated

### UpdateMinimumDeposit
```solidity
  event UpdateMinimumDeposit(
  )
```

Event emitted when minimum deposit is updated

### PrizeCalculatorSet
```solidity
  event PrizeCalculatorSet(
  )
```

Event emitted when the Prize Calculator is set

### ErrorAwardingExternalKIP17
```solidity
  event ErrorAwardingExternalKIP17(
  )
```

Emitted when there was an error thrown awarding an External KIP17

### Deployed
```solidity
  event Deployed(
    address assetTokenContract
  )
```

Emitted when yield source prize pool is deployed.

#### Parameters:
| Name                           | Type          | Description                                    |
| :----------------------------- | :------------ | :--------------------------------------------- |
|`assetTokenContract`| address | Address of the yield source.
### Swept
```solidity
  event Swept(
    uint256 amount
  )
```
Emitted when stray deposit token balance in this contract is swept


#### Parameters:
| Name                           | Type          | Description                                    |
| :----------------------------- | :------------ | :--------------------------------------------- |
|`amount`| uint256 | The amount that was swept
