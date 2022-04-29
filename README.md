# KlayTogether V1 Core Smart Contracts

This repository contains the core smart contracts for the KlayTogether V3 Protocol.
KlayTogether is based on [PoolTogether V4](https://github.com/pooltogether/v4-core) with some modifications. 

## Documentation
https://docs.klaytogether.com

## Deployments
- [KlayYieldSourcePrizePool](https://scope.klaytn.com/account/0x)
- [KctYieldSourcePrizePool(kusdt)](https://scope.klaytn.com/account/0x)
- [PrizeCalculator(klay)](https://scope.klaytn.com/account/0x)
- [PrizeCalculator(kusdt)](https://scope.klaytn.com/account/0x)
- [KlayTogetherData](https://scope.klaytn.com/account/0x)

## Deploy Contracts

Install NPM packages via yarn

```sh
$ yarn
```

To compile contracts,

```sh
$ yarn compile
```

Before deployment, create `.env` file in root directory.

```sh
$ cp .env.example .env
```

Fill in `DEPLOYER_PK` with a private key that has enough KLAY to pay fees for deployment.
Fill in `OWNER_ACCOUNT` and `COMMISSION_ACCOUNT` with valid klaytn addresses, then

```sh
$ yarn deploy
```

## Settle Round

For round settlement, fill in `KLAY_PRIZE_CALCULATOR` and `KUSDT_PRIZE_CALCULATOR` with appropriate
contract addresses, then 

```sh
$ yarn settle
```
