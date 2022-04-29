# KlayTogether V1 Core Smart Contracts

This repository contains the core smart contracts for the KlayTogether V1 Protocol.
KlayTogether is based on [PoolTogether V4](https://github.com/pooltogether/v4-core) with some modifications.

## Documentation

https://klay-together.gitbook.io/product-docs/

## Deployments

- [KlayYieldSourcePrizePool](https://scope.klaytn.com/account/0x4c0ecF35621874ea178e640F15621279E5AF0Cf6)
- [KctYieldSourcePrizePool(kusdt)](https://scope.klaytn.com/account/0x9cc9EA2f20d41A1AdAc927eFFACe8E423b4BF697)
- [PrizeCalculator(klay)](https://scope.klaytn.com/account/0xFE7041c410944EFa6754176bAfDf1C66E3298e75)
- [PrizeCalculator(kusdt)](https://scope.klaytn.com/account/0xf27fE2D50e9F3B0b0DC7A5e886452c41A6359508)
- [KlayTogetherData](https://scope.klaytn.com/account/0xF2468eaC810891DEEF85eABa0BcF49A21D58e400)

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
