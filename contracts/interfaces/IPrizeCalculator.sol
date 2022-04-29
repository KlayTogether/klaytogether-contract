// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.6;

import "../libraries/TwabLib.sol";

interface IPrizeCalculator {
    /**
     * @notice A struct containing details for an Account.
     * @param balance The current balance for an Account.
     * @param nextTwabIndex The next available index to store a new twab.
     * @param cardinality The number of recorded twabs (plus one!).
     */
    struct AccountDetails {
        uint224 balance;
        uint16 nextTwabIndex;
        uint16 cardinality;
    }

    /**
     * @notice Combines account details with their twab history.
     * @param details The account details.
     * @param twabs The history of twabs for this account.
     */
    struct Account {
        AccountDetails details;
        ObservationLib.Observation[65535] twabs;
    }

    /**
     * @notice Emitted when winner is picked.
     * @param winner winner of the round.
     * @param round round number.
     * @param prize prize of the round.
     */
    event Winner(
        address indexed winner,
        uint256 indexed round,
        uint256 indexed prize
    );

    /**
     * @notice Emitted when round is set.
     * @param round round number.
     * @param startTime when round starts.
     * @param endTime when round finishes.
     */
    event RoundSet(
        uint256 indexed round,
        uint64 indexed startTime,
        uint64 indexed endTime
    );

    /**
     * @notice Emitted when round changes.
     * @param round round number.
     * @param timestamp current time.
     */
    event NextRound(
        uint256 indexed round,
        uint64 indexed timestamp
    );

    /**
     * @notice Emitted when contract is initialized.
     * @param prizePool prizePool contract address.
     */
    event PrizePoolSet(address indexed prizePool);

    /**
     * @notice Emitted when a new TWAB has been recorded.
     * @param user Address of the user who newly deposited
     * @param newTwab Updated TWAB of a the user after a successful TWAB recording.
     */
    event NewUserTwab(address indexed user, ObservationLib.Observation newTwab);

    /**
     * @notice Emitted when a new total supply TWAB has been recorded.
     * @param newTotalSupplyTwab Updated TWAB of tickets total supply after a successful total supply TWAB recording.
     */
    event NewTotalSupplyTwab(ObservationLib.Observation newTotalSupplyTwab);

    /**
     * @notice Iterates all participants of the current round and draw winner. Must be called after each round.
     * @param count Number of participants to iterate (when zero it goes over the whole list).
     */
    function settleRound(uint256 count) external;

    /**
     * @notice Called by prize pool to record user deposit info.
     * @param user User address.
     * @param amount Deposit amount.
     */
    function deposit(address user, uint256 amount) external;

    /**
     * @notice Called by prize pool to record user withdarwal info.
     * @param user User address.
     * @param amount Withdrawal amount.
     */
    function withdraw(address user, uint256 amount) external;

    /**
     * @notice Calculates user's average balance and average total supply of this round.
     * @param user User address.
     * @return User's average balance and average total supply. Former divided by Latter becomes user's odds.
     */
    function getUserOdds(address user) external view returns (uint256, uint256);

    /**
     * @notice Returns all the rounds that the user has won.
     * @param user User address.
     * @return List of rounds that the user has won.
     */
    function getUserWinningRounds(address user)
        external
        view
        returns (uint256[] memory);

    /**
     * @notice Returns accumulated prize that the user has won.
     * @param user User address.
     * @return Accumulated prize of the user.
     */
    function getUserAccumulatedPrize(address user)
        external
        view
        returns (uint256);

    /**
     * @notice Returns the round numbers and prizes that the user has won.
     * @param user User address.
     * @return Round list and prizes list that the user has won.
     */
    function getUserWinHistory(address user)
        external
        view
        returns (uint256[] memory, uint256[] memory);

    /**
     * @notice Returns currunt round number.
     * @return Current round number.
     */
    function getCurrentRound() external view returns (uint256);

    /**
     * @notice Returns the round's info.
     * @param round Round number.
     * @return Start time, end time, prize, winner of the round
     */
    function getRoundInfo(uint256 round)
        external
        view
        returns (
            uint64,
            uint64,
            uint256,
            address
        );

    /**
     * @notice Returns the round's participants
     * @param round Round number.
     * @return Address list of the round's participants
     */
    function getRoundParticipants(uint256 round)
        external
        view
        returns (address[] memory);

    /**
     * @notice Iterates from the latest settled round and return each round's data.
     * @param count Number of rounds to iterate (when zero, it returns the whole history).
     * @return Round number list, end time list, prize list, and winner list
     */
    function getRoundHistories(uint256 count)
        external
        view
        returns (
            uint256[] memory,
            uint64[] memory,
            uint256[] memory,
            address[] memory
        );

    /**
     * @notice Returns the prize pool registered to this calculator.
     * @return Prize pool address.
     */
    function getPrizePool() external view returns (address);

    /**
     * @notice Gets a users twab context.  This is a struct with their balance, next twab index, and cardinality.
     * @param user The user for whom to fetch the TWAB context.
     * @return The TWAB context, which includes { balance, nextTwabIndex, cardinality }
     */
    function getAccountDetails(address user)
        external
        view
        returns (TwabLib.AccountDetails memory);

    /**
     * @notice Gets the TWAB at a specific index for a user.
     * @param user The user for whom to fetch the TWAB.
     * @param index The index of the TWAB to fetch.
     * @return The TWAB, which includes the twab amount and the timestamp.
     */
    function getTwab(address user, uint16 index)
        external
        view
        returns (ObservationLib.Observation memory);

    /**
     * @notice Retrieves `user` TWAB balance.
     * @param user Address of the user whose TWAB is being fetched.
     * @param timestamp Timestamp at which we want to retrieve the TWAB balance.
     * @return The TWAB balance at the given timestamp.
     */
    function getBalanceAt(address user, uint64 timestamp)
        external
        view
        returns (uint256);

    /**
     * @notice Retrieves `user` TWAB balances.
     * @param user Address of the user whose TWABs are being fetched.
     * @param timestamps Timestamps range at which we want to retrieve the TWAB balances.
     * @return `user` TWAB balances.
     */
    function getBalancesAt(address user, uint64[] calldata timestamps)
        external
        view
        returns (uint256[] memory);

    /**
     * @notice Retrieves the average balance held by a user for a given time frame.
     * @param user The user whose balance is checked.
     * @param startTime The start time of the time frame.
     * @param endTime The end time of the time frame.
     * @return The average balance that the user held during the time frame.
     */
    function getAverageBalanceBetween(
        address user,
        uint64 startTime,
        uint64 endTime
    ) external view returns (uint256);

    /**
     * @notice Retrieves the average balances held by a user for a given time frame.
     * @param user The user whose balance is checked.
     * @param startTimes The start time of the time frame.
     * @param endTimes The end time of the time frame.
     * @return The average balance that the user held during the time frame.
     */
    function getAverageBalancesBetween(
        address user,
        uint64[] calldata startTimes,
        uint64[] calldata endTimes
    ) external view returns (uint256[] memory);

    /**
     * @notice Retrieves the total supply TWAB balance at the given timestamp.
     * @param timestamp Timestamp at which we want to retrieve the total supply TWAB balance.
     * @return The total supply TWAB balance at the given timestamp.
     */
    function getTotalSupplyAt(uint64 timestamp) external view returns (uint256);

    /**
     * @notice Retrieves the total supply TWAB balance between the given timestamps range.
     * @param timestamps Timestamps range at which we want to retrieve the total supply TWAB balance.
     * @return Total supply TWAB balances.
     */
    function getTotalSuppliesAt(uint64[] calldata timestamps)
        external
        view
        returns (uint256[] memory);

    /**
     * @notice Retrieves the average total supply balance for a set of given time frames.
     * @param startTimes Array of start times.
     * @param endTimes Array of end times.
     * @return The average total supplies held during the time frame.
     */
    function getAverageTotalSuppliesBetween(
        uint64[] calldata startTimes,
        uint64[] calldata endTimes
    ) external view returns (uint256[] memory);
}
