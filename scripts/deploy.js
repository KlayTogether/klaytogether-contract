// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat")
require('dotenv').config()

async function main() {
	// Hardhat always runs the compile task when running scripts with its command
	// line interface.
	//
	// If this script is run directly using `node` you may want to call compile
	// manually to make sure everything is compiled
	// await hre.run('compile');

	const signer = await hre.ethers.getSigner()

	const IKLAY_CONTRACT_ADDRESS = process.env.IKLAY_CONTRACT_ADDRESS
	const IKUSDT_CONTRACT_ADDRESS = process.env.IKUSDT_CONTRACT_ADDRESS

	const OWNER_ACCOUNT = process.env.OWNER_ACCOUNT
	const COMMISSION_ACCOUNT = process.env.COMMISSION_ACCOUNT

	const klayMinimumDeposit = "1000000000000000000"
	const kusdtMinimumDeposit = "1000000"

	// We get the contract to deploy
	const KlayYieldSourcePrizePool = await hre.ethers.getContractFactory(
		"KlayYieldSourcePrizePool"
	)

	const klayYieldSourcePrizePool = await KlayYieldSourcePrizePool.deploy(
		OWNER_ACCOUNT,
		IKLAY_CONTRACT_ADDRESS,
		COMMISSION_ACCOUNT,
		klayMinimumDeposit
	)

	console.log(
		"KlayYieldSourcePrizePool deployed to:",
		klayYieldSourcePrizePool.address
	)

	const KctYieldSourcePrizePool = await hre.ethers.getContractFactory(
		"KctYieldSourcePrizePool"
	)

	const kctYieldSourcePrizePool = await KctYieldSourcePrizePool.deploy(
		OWNER_ACCOUNT,
		IKUSDT_CONTRACT_ADDRESS,
		COMMISSION_ACCOUNT,
		kusdtMinimumDeposit
	)

	console.log(
		"KctYieldSourcePrizePool(kusdt) deployed to:",
		kctYieldSourcePrizePool.address
	)

	await kctYieldSourcePrizePool.deployed()

	const KlayPrizeCalculator = await hre.ethers.getContractFactory(
		"PrizeCalculator"
	)

	const klayPrizeCalculator = await KlayPrizeCalculator.deploy(
		OWNER_ACCOUNT,
		klayYieldSourcePrizePool.address
	)
	
	console.log("KlayPrizeCalculator deployed to:", klayPrizeCalculator.address)
	
	const KctPrizeCalculator = await hre.ethers.getContractFactory(
		"PrizeCalculator"
	)

	const kctPrizeCalculator = await KctPrizeCalculator.deploy(
		OWNER_ACCOUNT,
		kctYieldSourcePrizePool.address
	)

	console.log(
		"KctPrizeCalculator(kusdt) deployed to:",
		kctPrizeCalculator.address
	)

	await kctPrizeCalculator.deployed()

	console.log("setting prize calculators to prize pools...")
	let tx = await klayYieldSourcePrizePool.setPrizeCalculator(
		klayPrizeCalculator.address
	)
	await tx.wait()
	tx = await kctYieldSourcePrizePool.setPrizeCalculator(
		kctPrizeCalculator.address
	)
	await tx.wait()
	console.log("complete!")

	const KlayTogetherData = await hre.ethers.getContractFactory(
		"KlayTogetherData"
	)

	const klayTogetherData = await KlayTogetherData.deploy([
		klayYieldSourcePrizePool.address,
		kctYieldSourcePrizePool.address,
	])

	console.log("KlayTogetherData deployed to:", klayTogetherData.address)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error)
		process.exit(1)
	})
