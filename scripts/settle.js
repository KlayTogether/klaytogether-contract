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
	
	const SETTLE_GAS_LIMIT = 9900000
	const KLAY_PRIZE_CALCULATOR = process.env.KLAY_PRIZE_CALCULATOR
	const KUSDT_PRIZE_CALCULATOR = process.env.KUSDT_PRIZE_CALCULATOR

	const PrizeCalculator = await hre.ethers.getContractFactory(
		"PrizeCalculator"
	)

	const klayPrizeCalculator = PrizeCalculator.attach(KLAY_PRIZE_CALCULATOR)
	const kusdtPrizeCalculator = PrizeCalculator.attach(KUSDT_PRIZE_CALCULATOR)

	console.log("settling this round...")

	let tx = await klayPrizeCalculator.settleRound(0, {
		gasLimit: SETTLE_GAS_LIMIT,
	})
	await tx.wait()

	tx = await kusdtPrizeCalculator.settleRound(0, {
		gasLimit: SETTLE_GAS_LIMIT,
	})
	await tx.wait()

	console.log("complete!")
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error)
		process.exit(1)
	})
