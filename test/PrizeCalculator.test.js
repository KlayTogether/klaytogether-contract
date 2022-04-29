const { expect } = require("chai");
const { ethers } = require("hardhat");

const DAY_IN_SEC = 86400

describe("PrizeCalculator", function () {
  it("Should able to deposit and withdraw correct amount", async function () {
    accounts = await ethers.getSigners()
    const [
      userA,
      userB,
      userC
    ] = accounts
    let currentTime
    let currentRound
    let currentSupply
    let res

    const PrizeCalculator = await ethers.getContractFactory("PrizeCalculator");
    const prizeCalculator = await PrizeCalculator.deploy();
    await prizeCalculator.deployed();

    currentTime = await prizeCalculator.getCurrentTimestamp()
    console.log("------ DAY 0 ------")
    console.log("current timestamp: ", currentTime.toString())

    await prizeCalculator.setRound(1, currentTime.toNumber() +10, currentTime.toNumber() + DAY_IN_SEC * 7);
    await prizeCalculator.nextRound();
    currentRound = await prizeCalculator.currentRound()
    console.log("current round: ", currentRound.toString())
    console.log("START")

    // 하루 뒤
    console.log("------ DAY 1 ------")

    await ethers.provider.send("evm_increaseTime", [DAY_IN_SEC])
    await ethers.provider.send("evm_mine")
  
    currentTime = await prizeCalculator.getCurrentTimestamp()
    currentSupply = await prizeCalculator.getTotalSupplyAt(currentTime)
    console.log("current timestamp: ", currentTime.toString())
    console.log("current supply: ", currentSupply.toString())

    let userADeposit = 100
    await prizeCalculator.deposit(userA.address, userADeposit);
    console.log("user a deposit 100")

    res = await prizeCalculator.getUserOdds(userA.address)

    console.log("user a twab: ", res[0].toString())
    console.log("supply twab: ", res[1].toString())


    res = await prizeCalculator.getRoundParticipants(currentRound)
    console.log("current participants: ", res)

    // 하루 뒤
    console.log("------ DAY 2 ------")

    await ethers.provider.send("evm_increaseTime", [DAY_IN_SEC])
    await ethers.provider.send("evm_mine")

    currentTime = await prizeCalculator.getCurrentTimestamp()
    res = await prizeCalculator.getUserOdds(userA.address)
    console.log("current timestamp: ", currentTime.toString())
    console.log("user a twab: ", res[0].toString())
    console.log("supply twab: ", res[1].toString())


    res = await prizeCalculator.getRoundParticipants(currentRound)
    console.log("current participants: ", res)

    // 하루 뒤
    console.log("------ DAY 3 ------")

    await ethers.provider.send("evm_increaseTime", [DAY_IN_SEC])
    await ethers.provider.send("evm_mine")

    console.log("user b deposit 100")
    let userBDeposit = 100
    await prizeCalculator.deposit(userB.address, userBDeposit);

    currentTime = await prizeCalculator.getCurrentTimestamp()
    console.log("current timestamp: ", currentTime.toString())
    res = await prizeCalculator.getUserOdds(userA.address)
    console.log("user a twab: ", res[0].toString())
    console.log("supply twab: ", res[1].toString())
    res = await prizeCalculator.getUserOdds(userB.address)
    console.log("user b twab: ", res[0].toString())
    console.log("supply twab: ", res[1].toString())


    res = await prizeCalculator.getRoundParticipants(currentRound)
    console.log("current participants: ", res)

    // 하루 뒤
    console.log("------ DAY 4 ------")
    await ethers.provider.send("evm_increaseTime", [DAY_IN_SEC])
    await ethers.provider.send("evm_mine")
    currentTime = await prizeCalculator.getCurrentTimestamp()
    console.log("current timestamp: ", currentTime.toString())

    console.log("user c deposit 100")
    let userCDeposit = 100

    await prizeCalculator.deposit(userC.address, userCDeposit);
    res = await prizeCalculator.getUserOdds(userA.address)
    console.log("user a twab: ", res[0].toString())
    console.log("supply twab: ", res[1].toString())
    res = await prizeCalculator.getUserOdds(userB.address)
    console.log("user b twab: ", res[0].toString())
    console.log("supply twab: ", res[1].toString())
    res = await prizeCalculator.getUserOdds(userC.address)
    console.log("user b twab: ", res[0].toString())
    console.log("supply twab: ", res[1].toString())

    currentSupply = await prizeCalculator.getTotalSupplyAt(currentTime)
    console.log("current supply: ", currentSupply.toString())


    res = await prizeCalculator.getRoundParticipants(currentRound)
    console.log("current participants: ", res)

    // 하루 뒤
    console.log("------ DAY 5 ------")
    await ethers.provider.send("evm_increaseTime", [DAY_IN_SEC])
    await ethers.provider.send("evm_mine")
    currentTime = await prizeCalculator.getCurrentTimestamp()
    console.log("current timestamp: ", currentTime.toString())

    console.log("user c widthdraw 100")
    await prizeCalculator.withdraw(userC.address, userCDeposit);
    res = await prizeCalculator.getUserOdds(userA.address)
    console.log("user a twab: ", res[0].toString())
    console.log("supply twab: ", res[1].toString())
    res = await prizeCalculator.getUserOdds(userB.address)
    console.log("user b twab: ", res[0].toString())
    console.log("supply twab: ", res[1].toString())
    res = await prizeCalculator.getUserOdds(userC.address)
    console.log("user c twab: ", res[0].toString())
    console.log("supply twab: ", res[1].toString())

    currentSupply = await prizeCalculator.getTotalSupplyAt(currentTime)
    console.log("current supply: ", currentSupply.toString())


    res = await prizeCalculator.getRoundParticipants(currentRound)
    console.log("current participants: ", res)

    // 하루 뒤
    console.log("------ DAY 6 ------")

    await ethers.provider.send("evm_increaseTime", [DAY_IN_SEC])
    await ethers.provider.send("evm_mine")
    currentTime = await prizeCalculator.getCurrentTimestamp()
    console.log("current timestamp: ", currentTime.toString())

    console.log("user a widthdraw 100")
    await prizeCalculator.withdraw(userA.address, userADeposit);
    currentTime = await prizeCalculator.getCurrentTimestamp()

    res = await prizeCalculator.getUserOdds(userA.address)
    console.log("user a twab: ", res[0].toString())
    console.log("supply twab: ", res[1].toString())
    res = await prizeCalculator.getUserOdds(userB.address)
    console.log("user b twab: ", res[0].toString())
    console.log("supply twab: ", res[1].toString())
    res = await prizeCalculator.getUserOdds(userC.address)
    console.log("user c twab: ", res[0].toString())
    console.log("supply twab: ", res[1].toString())

    currentSupply = await prizeCalculator.getTotalSupplyAt(currentTime)
    console.log("current supply: ", currentSupply.toString())

    
    res = await prizeCalculator.getRoundParticipants(currentRound)
    console.log("current participants: ", res)

    // 하루 뒤
    console.log("------ DAY 7 ------")

    await ethers.provider.send("evm_increaseTime", [DAY_IN_SEC])
    await ethers.provider.send("evm_mine")

    currentTime = await prizeCalculator.getCurrentTimestamp()
    console.log("current timestamp: ", currentTime.toString())
  
    res = await prizeCalculator.getUserOdds(userA.address)
    console.log("user a twab: ", res[0].toString())
    console.log("supply twab: ", res[1].toString())
    res = await prizeCalculator.getUserOdds(userB.address)
    console.log("user b twab: ", res[0].toString())
    console.log("supply twab: ", res[1].toString())
    res = await prizeCalculator.getUserOdds(userC.address)
    console.log("user c twab: ", res[0].toString())
    console.log("supply twab: ", res[1].toString())

    currentSupply = await prizeCalculator.getTotalSupplyAt(currentTime)
    console.log("current supply: ", currentSupply.toString())

    res = await prizeCalculator.getRoundInfo(1)
    console.log("start time: ", res[0].toString())
    console.log("end time: ", res[1].toString())
    console.log("luckyNumber: ", res[2].toString())
    console.log("winner: ", res[3])


    res = await prizeCalculator.calculateWinner(0)

    console.log("-----Round 1 End ----")
    res = await prizeCalculator.getRoundInfo(1)
    console.log("start time: ", res[0].toString())
    console.log("end time: ", res[1].toString())
    console.log("luckyNumber: ", res[2].toString())
    console.log("winner: ", res[3])

    res = await prizeCalculator.getRoundParticipants(currentRound)
    console.log("current participants: ", res)


    currentTime = await prizeCalculator.getCurrentTimestamp()
    console.log("current timestamp: ", currentTime.toString())
      await prizeCalculator.setRound(2, currentTime.toNumber(), currentTime.toNumber() + DAY_IN_SEC * 7);
    await prizeCalculator.nextRound();
    currentRound = await prizeCalculator.currentRound()
    console.log("current round: ", currentRound.toString())
    console.log("START")

    res = await prizeCalculator.getUserOdds(userA.address)
    console.log("user a twab: ", res[0].toString())
    console.log("supply twab: ", res[1].toString())
    res = await prizeCalculator.getUserOdds(userB.address)
    console.log("user b twab: ", res[0].toString())
    console.log("supply twab: ", res[1].toString())
    res = await prizeCalculator.getUserOdds(userC.address)
    console.log("user c twab: ", res[0].toString())
    console.log("supply twab: ", res[1].toString())

    // user b 는 자동 재참가 되어 있어야 함

    res = await prizeCalculator.getRoundParticipants(currentRound)
    console.log("current participants: ", res)
  });
});
