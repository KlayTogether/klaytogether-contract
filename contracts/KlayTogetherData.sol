// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.6;

import "./interfaces/IPrizePool.sol";
import "./interfaces/IPrizeCalculator.sol";
import "./interfaces/IKIP7.sol";

/**
 * @title  KlayTogether V1 KlayTogetherData
 * @author KlayTogether Inc Team
 * @notice Collects and processes data from prize pools and prize calculators
 */
contract KlayTogetherData {
    IPrizePool[] public prizePools;
    IPrizeCalculator[] public prizeCalculators;

    address private constant KSP_CONTRACT =
        0xC6a2Ad8cC6e4A7E08FC37cC5954be07d499E7654;
    address private constant ZERO_ADDRESS =
        0x0000000000000000000000000000000000000000;

    /// @notice Deploy the Klay Together Data
    /// @param _prizePools Address of the deployed Prize Pools
    constructor(IPrizePool[] memory _prizePools) {
        require(
            _prizePools.length > 0,
            "KlayTogetherData/require-at-least-one-pool"
        );
        for (uint256 i = 0; i < _prizePools.length; i++) {
            prizeCalculators.push(
                IPrizeCalculator(_prizePools[i].getPrizeCalculator())
            );
        }
        prizePools = _prizePools;
    }

    /// @dev Returns the prize pool's balance that is available to award
    function getExpectedPrize(IPrizePool prizePool)
        public
        view
        returns (uint256)
    {
        return prizePool.awardBalance();
    }

    /// @dev Returns the prize pool's KSP balance
    function getKspAmount(IPrizePool prizePool) public view returns (uint256) {
        return IKIP7(KSP_CONTRACT).balanceOf(address(prizePool));
    }

    /// @dev Returns the prize pool's total deposit
    function getTotalDeposit(IPrizePool prizePool)
        public
        view
        returns (uint256)
    {
        return prizePool.getTotalDeposit();
    }

    /// @dev Returns the prize pool's commission rate
    function getCommissionRate(IPrizePool prizePool)
        public
        view
        returns (uint256)
    {
        return prizePool.getCommissionRate();
    }

    /// @dev Returns the prize pool's deposit from the user
    function getUserDeposit(IPrizePool prizePool, address user)
        public
        view
        returns (uint256)
    {
        return prizePool.getUserDeposit(user);
    }

    /// @dev Returns user's KIP7 allowance to the prize pool
    function getUserAllowance(IPrizePool prizePool, address user)
        public
        view
        returns (uint256)
    {
        return IKIP7(prizePool.getToken()).allowance(user, address(prizePool));
    }

    struct CurrentRoundInfo {
        uint256 currentRound;
        uint256 lastRoundPrize;
        uint256 accumulatedPrize; // accumulated prize (excluding ksp) for this round
        uint256 accumulatedKsp; // accumulated ksp for this round
        uint256 totalDeposit;
        uint256 roundStartedAt;
        uint256 roundEndsAt;
        uint256 commissionRate;
    }

    /// @dev Returns current CurrentRoundInfo list
    function getCurrentRoundInfo()
        public
        view
        returns (CurrentRoundInfo[] memory)
    {
        CurrentRoundInfo[] memory list = new CurrentRoundInfo[](
            prizePools.length
        );
        for (uint256 i = 0; i < prizePools.length; i++) {
            uint256 currentRound = prizeCalculators[i].getCurrentRound();
            list[i].currentRound = currentRound;

            if (currentRound > 1) {
                (, , list[i].lastRoundPrize, ) = prizeCalculators[i]
                    .getRoundInfo(currentRound - 1);
            } else {
                list[i].lastRoundPrize = 0;
            }
            list[i].accumulatedPrize = getExpectedPrize(prizePools[i]);
            list[i].accumulatedKsp = getKspAmount(prizePools[i]);
            list[i].totalDeposit = getTotalDeposit(prizePools[i]);
            (list[i].roundStartedAt, list[i].roundEndsAt, , ) = prizeCalculators[i].getRoundInfo(
                currentRound
            );
            list[i].commissionRate = getCommissionRate(prizePools[i]);
        }

        return list;
    }

    struct UserAccountInfo {
        uint256 allowance; // user's KIP7 allowance to prize pool (in case of KLAY it returns MAX uint256)
        uint256 deposit;
        uint256 averageBalance; // user's time weighted average balance for this round
        uint256 averageTotalSupply; // total time weighted average supply for this round
        uint256 totalWinnings; // user's accumulated prize
        uint256 unclaimedWinnings; // accumulated prize - claimed amount
        uint256[] winningRounds; // list of the rounds that the user has won
        uint64[] winningDates; // list of the end times of the rounds that the user has won
        uint256[] winningPrizes; // list of the prizes of the rounds that the user has won
    }

    /// @dev Returns current UserAccountInfo list
    function getUserInformation(address user)
        public
        view
        returns (UserAccountInfo[] memory)
    {
        UserAccountInfo[] memory list = new UserAccountInfo[](
            prizePools.length
        );
        for (uint256 i = 0; i < prizePools.length; i++) {
            if (prizePools[i].getToken() == ZERO_ADDRESS) {
                list[i].allowance = type(uint256).max;
            } else {
                list[i].allowance = getUserAllowance(prizePools[i], user);
            }
            list[i].deposit = getUserDeposit(prizePools[i], user);
            (
                list[i].averageBalance,
                list[i].averageTotalSupply
            ) = prizeCalculators[i].getUserOdds(user);

            list[i].totalWinnings = prizeCalculators[i].getUserAccumulatedPrize(
                user
            );
            list[i].unclaimedWinnings = prizePools[i].getUserUnclaimedPrize(
                user
            );
            list[i].winningRounds = prizeCalculators[i].getUserWinningRounds(
                user
            );

            uint64[] memory dates = new uint64[](list[i].winningRounds.length);
            uint256[] memory prizes = new uint256[](
                list[i].winningRounds.length
            );

            for (uint256 j = 0; j < list[i].winningRounds.length; j++) {
                (, dates[j], prizes[j], ) = prizeCalculators[i].getRoundInfo(
                    list[i].winningRounds[j]
                );
            }
            list[i].winningDates = dates;
            list[i].winningPrizes = prizes;
        }
        return list;
    }

    struct RoundHistory {
        uint256[] rounds;
        uint64[] endTimes;
        uint256[] prizes;
        address[] winners;
    }

    /**
     * @notice Iterates from the latest settled round and return each round's data.
     * @param count Number of rounds to iterate (when zero, it return the whole history).
     * @return RoundHistory list for every prize pool
     */
    function getRoundHistories(uint256 count)
        public
        view
        returns (RoundHistory[] memory)
    {
        RoundHistory[] memory list = new RoundHistory[](prizePools.length);
        for (uint256 i = 0; i < prizePools.length; i++) {
            (
                list[i].rounds,
                list[i].endTimes,
                list[i].prizes,
                list[i].winners
            ) = prizeCalculators[i].getRoundHistories(count);
        }
        return list;
    }

    function getCurrentBlockNumber() public view returns (uint256) {
        return block.number;
    }

    function getCurrentTimestamp() public view returns (uint256) {
        return block.timestamp;
    }
}
