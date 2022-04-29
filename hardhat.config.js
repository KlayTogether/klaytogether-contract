require("@nomiclabs/hardhat-waffle")
require('dotenv').config()

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
	const accounts = await hre.ethers.getSigners()

	for (const account of accounts) {
		console.log(account.address)
	}
})

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
	solidity: {
		compilers: [
			{
				version: "0.8.6",
				settings: {
					optimizer: {
						enabled: true,
						runs: 9999,
					},
					evmVersion: "istanbul",
				},
			},
		],
	},
	networks: {
		cypress: {
			url: "https://public-node-api.klaytnapi.com/v1/cypress",
			accounts: [
				process.env.DEPLOYER_PK,
			],
			gas: 9500000,
			timeout: 3000000,
			gasPrice: 750000000000,
		},
	},
}
