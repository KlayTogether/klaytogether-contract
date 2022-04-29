// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.6;

import "./libraries/ExtendedSafeCastLib.sol";
import "./libraries/TwabLib.sol";
import "./interfaces/IPrizeCalculator.sol";
import "./interfaces/IPrizePool.sol";
import "@pooltogether/owner-manager-contracts/contracts/Ownable.sol";

/**
  * @title  KlayTogether V1 PrizeCalculator
  * @author KlayTogether Inc Team
  * @notice PrizeCalculator keeps track of each round's time-weighted average balance. 
            The average balance held by a user between two timestamps can be calculated, as well as the historic balance.
            The historic total supply is available as well as the average total supply between two timestamps.
            It calculates each user's odds for the round, and after every round it draws the winner. 
*/
contract PrizeCalculator is IPrizeCalculator, Ownable {
    using ExtendedSafeCastLib for uint256;

    /* ============ Variables ============ */

    /// @notice Record of token holders TWABs for each account.
    mapping(address => TwabLib.Account) internal userTwabs;

    /// @notice Record of prize pool's total supply and ring buff parameters used for observation.
    TwabLib.Account internal totalSupplyTwab;

    address private prizePool;
    uint256 private currentRound;

    uint256 public accumulatedPrize;
    mapping(address => uint256[]) private userWinningRounds;
    mapping(address => uint256) private userAccumulatedPrize;

    mapping(uint256 => Round) public roundInfo;

    struct Round {
        uint64 startTime;
        uint64 endTime;
        mapping(address => bool) hasJoined;
        address[] participants;
        uint256 currentIndex;
        uint256 currentPortion;
        uint256 luckyNumber;
        address winner;
        uint256 prize;
        bool settled;
    }

    /* ============ Modifiers ============ */

    /// @dev Function modifier to ensure caller is the prize-pool
    modifier onlyPrizePool() {
        require(msg.sender == prizePool, "PrizeCalculator/only-prizePool");
        _;
    }

    /* ============ Constructor ============ */

    constructor(address _owner, address _prizePool) Ownable(_owner) {
        _setPrizePool(_prizePool);
    }

    function setPrizePool(address _prizePool) external onlyOwner {
        _setPrizePool(_prizePool);
    }

    /* ============ Restricted Functions ============ */

    function setRound(
        uint256 _round,
        uint64 _startTime,
        uint64 _endTime
    ) public onlyOwner {
        require(currentRound < _round, "PrizeCalculator/only-future-rounds");
        require(_startTime < _endTime, "PrizeCalculator/invalid-time");
        if (_round > 1) {
            require(
                roundInfo[_round - 1].endTime > 0,
                "PrizeCalculator/do-not-skip-rounds"
            );
            require(
                roundInfo[_round - 1].endTime < _startTime,
                "PrizeCalculator/invalid-start-time"
            );
        }
        roundInfo[_round].startTime = _startTime;
        roundInfo[_round].endTime = _endTime;
        emit RoundSet(_round, _startTime, _endTime);
    }

    function setRounds(
        uint256[] memory _rounds,
        uint64[] memory _startTimes,
        uint64[] memory _endTimes
    ) external onlyOwner {
        require(
            _rounds.length == _startTimes.length &&
                _startTimes.length == _endTimes.length,
            "PrizeCalculator/must-have-the-same-length"
        );
        for (uint256 i = 0; i < _rounds.length; i++) {
            setRound(_rounds[i], _startTimes[i], _endTimes[i]);
        }
    }

    function nextRound() external onlyOwner {
        require(
            roundInfo[currentRound + 1].startTime > 0,
            "PrizeCalculator/next-round-not-set"
        );
        if (currentRound > 0) {
            require(
                roundInfo[currentRound].currentIndex ==
                    roundInfo[currentRound].participants.length,
                "PrizeCalculator/round-not-settled"
            );
            roundInfo[currentRound].settled = true;
        }
        currentRound++;
        emit NextRound(currentRound, uint64(block.timestamp));
    }

    /// @inheritdoc IPrizeCalculator
    function deposit(address user, uint256 amount)
        external
        override
        onlyPrizePool
    {
        uint256 _currentRound = currentRound;
        if (currentRound == 0) {
            _currentRound = 1;
        } else if (
            roundInfo[_currentRound].endTime < block.timestamp &&
            !roundInfo[_currentRound].settled
        ) {
            // in case current round has ended but has not been settled yet
            _currentRound = currentRound + 1; // joins the next round
        }

        if (!roundInfo[_currentRound].hasJoined[user]) {
            roundInfo[_currentRound].hasJoined[user] = true;
            roundInfo[_currentRound].participants.push(user);
        }
        _increaseUserTwab(user, amount);
        _increaseTotalSupplyTwab(amount);
    }

    /// @inheritdoc IPrizeCalculator
    function withdraw(address user, uint256 amount)
        external
        override
        onlyPrizePool
    {
        _decreaseUserTwab(user, amount);
        _decreaseTotalSupplyTwab(amount);
    }

    /* ============ External Functions ============ */

    /// @inheritdoc IPrizeCalculator
    function settleRound(uint256 count) external override {
        require(
            block.timestamp > roundInfo[currentRound].endTime,
            "PrizeCalculator/round-not-finished"
        );

        uint256 numberOfParticipants = roundInfo[currentRound]
            .participants
            .length;

        if (numberOfParticipants == 0) {
            emit Winner(address(0), currentRound, 0);

            // if next round is set
            if (roundInfo[currentRound + 1].startTime > 0) {
                roundInfo[currentRound].settled = true;
                currentRound++;
                emit NextRound(currentRound, uint64(block.timestamp));
            }
            return;
        }

        uint256 totalSupply = getAverageTotalSuppliesBetween(
            roundInfo[currentRound].startTime,
            roundInfo[currentRound].endTime
        );

        // when first called
        if (roundInfo[currentRound].currentIndex == 0) {
            // assuming that block producers do not have incentives to abuse black hashes
            // considering chainlink integration in upcoming versions
            roundInfo[currentRound].luckyNumber =
                uint256(
                    keccak256(
                        abi.encodePacked(
                            blockhash(block.number),
                            block.timestamp
                        )
                    )
                ) %
                (totalSupply);
        }

        uint256 endIndex;

        if (count == 0) {
            endIndex = numberOfParticipants - 1;
        } else if (
            numberOfParticipants - roundInfo[currentRound].currentIndex <= count
        ) {
            endIndex = numberOfParticipants - 1;
        } else {
            endIndex = roundInfo[currentRound].currentIndex + count - 1;
        }

        for (
            uint256 i = roundInfo[currentRound].currentIndex;
            i <= endIndex;
            i++
        ) {
            address currentUser = roundInfo[currentRound].participants[i];

            if (roundInfo[currentRound].winner == address(0)) {
                uint256 userPortion = getAverageBalancesBetween(
                    currentUser,
                    roundInfo[currentRound].startTime,
                    roundInfo[currentRound].endTime
                );

                roundInfo[currentRound].currentPortion =
                    roundInfo[currentRound].currentPortion +
                    userPortion;

                if (
                    roundInfo[currentRound].currentPortion >=
                    roundInfo[currentRound].luckyNumber
                ) {
                    uint256 prize = IPrizePool(prizePool).award(
                        currentRound,
                        currentUser
                    );
                    roundInfo[currentRound].winner = currentUser;
                    roundInfo[currentRound].prize = prize;
                    accumulatedPrize += prize;
                    userAccumulatedPrize[currentUser] += prize;
                    userWinningRounds[currentUser].push(currentRound);
                    emit Winner(currentUser, currentRound, prize);
                }
            }

            // if user has balance and has not yet joined next round, put the user in the next round
            if (
                getBalanceAt(currentUser, uint64(block.timestamp)) > 0 &&
                roundInfo[currentRound + 1].hasJoined[currentUser] == false
            ) {
                roundInfo[currentRound + 1].participants.push(currentUser);
                roundInfo[currentRound + 1].hasJoined[currentUser] = true;
            }

            roundInfo[currentRound].currentIndex++;

            if (roundInfo[currentRound].currentIndex == numberOfParticipants) {
                // in case if winner is not drawn at the last idnex
                if (roundInfo[currentRound].winner == address(0)) {
                    uint256 prize = IPrizePool(prizePool).award(
                        currentRound,
                        currentUser
                    );
                    roundInfo[currentRound].winner = currentUser;
                    roundInfo[currentRound].prize = prize;
                    accumulatedPrize += prize;
                    userAccumulatedPrize[currentUser] += prize;
                    userWinningRounds[currentUser].push(currentRound);
                    emit Winner(currentUser, currentRound, prize);
                }

                // if next round is set
                if (roundInfo[currentRound + 1].startTime > 0) {
                    roundInfo[currentRound].settled = true;
                    currentRound++;
                    emit NextRound(currentRound, uint64(block.timestamp));
                }
            }
        }
    }

    /// @inheritdoc IPrizeCalculator
    function getUserOdds(address user)
        external
        view
        override
        returns (uint256, uint256)
    {
        uint64 startTime = roundInfo[currentRound].startTime >
            uint64(block.timestamp)
            ? uint64(block.timestamp)
            : roundInfo[currentRound].startTime;

        return (
            getAverageBalancesBetween(user, startTime, uint32(block.timestamp)),
            getAverageTotalSuppliesBetween(startTime, uint32(block.timestamp))
        );
    }

    /// @inheritdoc IPrizeCalculator
    function getUserWinningRounds(address user)
        external
        view
        override
        returns (uint256[] memory)
    {
        return userWinningRounds[user];
    }

    /// @inheritdoc IPrizeCalculator
    function getUserAccumulatedPrize(address user)
        external
        view
        override
        returns (uint256)
    {
        return userAccumulatedPrize[user];
    }

    /// @inheritdoc IPrizeCalculator
    function getUserWinHistory(address user)
        external
        view
        override
        returns (uint256[] memory rounds, uint256[] memory prizes)
    {
        uint256[] memory _prizes = new uint256[](
            userWinningRounds[user].length
        );

        for (uint256 i = 0; i < userWinningRounds[user].length; i++) {
            _prizes[i] = roundInfo[userWinningRounds[user][i]].prize;
        }

        return (userWinningRounds[user], _prizes);
    }

    /// @inheritdoc IPrizeCalculator
    function getCurrentRound() external view override returns (uint256) {
        return currentRound;
    }

    /// @inheritdoc IPrizeCalculator
    function getRoundInfo(uint256 round)
        external
        view
        override
        returns (
            uint64 startTime,
            uint64 endTime,
            uint256 prize,
            address winner
        )
    {
        return (
            roundInfo[round].startTime,
            roundInfo[round].endTime,
            roundInfo[round].prize,
            roundInfo[round].winner
        );
    }

    /// @inheritdoc IPrizeCalculator
    function getRoundParticipants(uint256 round)
        external
        view
        override
        returns (address[] memory)
    {
        return roundInfo[round].participants;
    }

    /// @inheritdoc IPrizeCalculator
    function getRoundHistories(uint256 count)
        external
        view
        override
        returns (
            uint256[] memory rounds,
            uint64[] memory endTimes,
            uint256[] memory prizes,
            address[] memory winners
        )
    {
        require(currentRound >= 1, "PrizeCalculator/round-not-started");
        uint256 cnt;
        if (count > currentRound - 1) {
            cnt = currentRound - 1;
        } else {
            cnt = count;
        }
        uint256[] memory _rounds = new uint256[](cnt);
        uint64[] memory _endTimes = new uint64[](cnt);
        uint256[] memory _prizes = new uint256[](cnt);
        address[] memory _winners = new address[](cnt);

        for (uint256 i = 0; i < cnt; i++) {
            uint256 round = currentRound - i - 1;
            _rounds[i] = round;
            _endTimes[i] = roundInfo[round].endTime;
            _prizes[i] = roundInfo[round].prize;
            _winners[i] = roundInfo[round].winner;
        }
        return (_rounds, _endTimes, _prizes, _winners);
    }

    /// @inheritdoc IPrizeCalculator
    function getPrizePool() external view override returns (address) {
        return prizePool;
    }

    /// @inheritdoc IPrizeCalculator
    function getAccountDetails(address _user)
        external
        view
        override
        returns (TwabLib.AccountDetails memory)
    {
        return userTwabs[_user].details;
    }

    /// @inheritdoc IPrizeCalculator
    function getTwab(address _user, uint16 _index)
        external
        view
        override
        returns (ObservationLib.Observation memory)
    {
        return userTwabs[_user].twabs[_index];
    }

    /// @inheritdoc IPrizeCalculator
    function getBalanceAt(address _user, uint64 _target)
        public
        view
        override
        returns (uint256)
    {
        TwabLib.Account storage account = userTwabs[_user];
        return
            TwabLib.getBalanceAt(
                account.twabs,
                account.details,
                uint32(_target),
                uint32(block.timestamp)
            );
    }

    function getAverageBalancesBetween(
        address _user,
        uint64 _startTime,
        uint64 _endTime
    ) public view returns (uint256) {
        return
            _getAverageBalancesBetween(userTwabs[_user], _startTime, _endTime);
    }

    function getAverageTotalSuppliesBetween(uint64 _startTime, uint64 _endTime)
        public
        view
        returns (uint256)
    {
        return
            _getAverageBalancesBetween(totalSupplyTwab, _startTime, _endTime);
    }

    /// @inheritdoc IPrizeCalculator
    function getAverageBalancesBetween(
        address _user,
        uint64[] calldata _startTimes,
        uint64[] calldata _endTimes
    ) external view override returns (uint256[] memory) {
        return
            _getAverageBalancesBetween(
                userTwabs[_user],
                _startTimes,
                _endTimes
            );
    }

    /// @inheritdoc IPrizeCalculator
    function getAverageTotalSuppliesBetween(
        uint64[] calldata _startTimes,
        uint64[] calldata _endTimes
    ) external view override returns (uint256[] memory) {
        return
            _getAverageBalancesBetween(totalSupplyTwab, _startTimes, _endTimes);
    }

    /// @inheritdoc IPrizeCalculator
    function getAverageBalanceBetween(
        address _user,
        uint64 _startTime,
        uint64 _endTime
    ) external view override returns (uint256) {
        TwabLib.Account storage account = userTwabs[_user];

        return
            TwabLib.getAverageBalanceBetween(
                account.twabs,
                account.details,
                uint32(_startTime),
                uint32(_endTime),
                uint32(block.timestamp)
            );
    }

    /// @inheritdoc IPrizeCalculator
    function getBalancesAt(address _user, uint64[] calldata _targets)
        external
        view
        override
        returns (uint256[] memory)
    {
        uint256 length = _targets.length;
        uint256[] memory _balances = new uint256[](length);

        TwabLib.Account storage twabContext = userTwabs[_user];
        TwabLib.AccountDetails memory details = twabContext.details;

        for (uint256 i = 0; i < length; i++) {
            _balances[i] = TwabLib.getBalanceAt(
                twabContext.twabs,
                details,
                uint32(_targets[i]),
                uint32(block.timestamp)
            );
        }

        return _balances;
    }

    /// @inheritdoc IPrizeCalculator
    function getTotalSupplyAt(uint64 _target)
        external
        view
        override
        returns (uint256)
    {
        return
            TwabLib.getBalanceAt(
                totalSupplyTwab.twabs,
                totalSupplyTwab.details,
                uint32(_target),
                uint32(block.timestamp)
            );
    }

    /// @inheritdoc IPrizeCalculator
    function getTotalSuppliesAt(uint64[] calldata _targets)
        external
        view
        override
        returns (uint256[] memory)
    {
        uint256 length = _targets.length;
        uint256[] memory totalSupplies = new uint256[](length);

        TwabLib.AccountDetails memory details = totalSupplyTwab.details;

        for (uint256 i = 0; i < length; i++) {
            totalSupplies[i] = TwabLib.getBalanceAt(
                totalSupplyTwab.twabs,
                details,
                uint32(_targets[i]),
                uint32(block.timestamp)
            );
        }

        return totalSupplies;
    }

    /* ============ Internal Functions ============ */

    function _setPrizePool(address _prizePool) internal {
        require(_prizePool != address(0), "PrizeCalculator/prizePool-not-zero");
        prizePool = _prizePool;
        IPrizePool(prizePool).getToken();
        emit PrizePoolSet(prizePool);
    }

    /**
     * @notice Retrieves the average balances held by a user for a given time frame.
     * @param _account The user whose balance is checked.
     * @param _startTimes The start time of the time frame.
     * @param _endTimes The end time of the time frame.
     * @return The average balance that the user held during the time frame.
     */
    function _getAverageBalancesBetween(
        TwabLib.Account storage _account,
        uint64[] calldata _startTimes,
        uint64[] calldata _endTimes
    ) internal view returns (uint256[] memory) {
        uint256 startTimesLength = _startTimes.length;
        require(
            startTimesLength == _endTimes.length,
            "PrizeCalculator/start-end-times-length-match"
        );

        TwabLib.AccountDetails memory accountDetails = _account.details;

        uint256[] memory averageBalances = new uint256[](startTimesLength);
        uint32 currentTimestamp = uint32(block.timestamp);

        for (uint256 i = 0; i < startTimesLength; i++) {
            averageBalances[i] = TwabLib.getAverageBalanceBetween(
                _account.twabs,
                accountDetails,
                uint32(_startTimes[i]),
                uint32(_endTimes[i]),
                currentTimestamp
            );
        }

        return averageBalances;
    }

    function _getAverageBalancesBetween(
        TwabLib.Account storage _account,
        uint64 _startTime,
        uint64 _endTime
    ) internal view returns (uint256) {
        TwabLib.AccountDetails memory accountDetails = _account.details;
        uint32 currentTimestamp = uint32(block.timestamp);

        return
            TwabLib.getAverageBalanceBetween(
                _account.twabs,
                accountDetails,
                uint32(_startTime),
                uint32(_endTime),
                currentTimestamp
            );
    }

    /**
     * @notice Increase `_to` TWAB balance.
     * @param _to Address of the user who deposits.
     * @param _amount Amount of tokens to be added to `_to` TWAB balance.
     */
    function _increaseUserTwab(address _to, uint256 _amount) internal {
        if (_amount == 0) {
            return;
        }

        TwabLib.Account storage _account = userTwabs[_to];

        (
            TwabLib.AccountDetails memory accountDetails,
            ObservationLib.Observation memory twab,
            bool isNew
        ) = TwabLib.increaseBalance(
                _account,
                _amount.toUint208(),
                uint32(block.timestamp)
            );

        _account.details = accountDetails;

        if (isNew) {
            emit NewUserTwab(_to, twab);
        }
    }

    /**
     * @notice Decrease `_to` TWAB balance.
     * @param _to Address of the user who withdraws.
     * @param _amount Amount of tokens to be added to `_to` TWAB balance.
     */
    function _decreaseUserTwab(address _to, uint256 _amount) internal {
        if (_amount == 0) {
            return;
        }

        TwabLib.Account storage _account = userTwabs[_to];

        (
            TwabLib.AccountDetails memory accountDetails,
            ObservationLib.Observation memory twab,
            bool isNew
        ) = TwabLib.decreaseBalance(
                _account,
                _amount.toUint208(),
                "PrizeCalculator/twab-burn-lt-balance",
                uint32(block.timestamp)
            );

        _account.details = accountDetails;

        if (isNew) {
            emit NewUserTwab(_to, twab);
        }
    }

    /// @notice Decreases the total supply twab. Should be called when user withdraws.
    /// @param _amount The amount to decrease the total by
    function _decreaseTotalSupplyTwab(uint256 _amount) internal {
        if (_amount == 0) {
            return;
        }

        (
            TwabLib.AccountDetails memory accountDetails,
            ObservationLib.Observation memory tsTwab,
            bool tsIsNew
        ) = TwabLib.decreaseBalance(
                totalSupplyTwab,
                _amount.toUint208(),
                "PrizeCalculator/burn-amount-exceeds-total-supply-twab",
                uint32(block.timestamp)
            );

        totalSupplyTwab.details = accountDetails;

        if (tsIsNew) {
            emit NewTotalSupplyTwab(tsTwab);
        }
    }

    /// @notice Increases the total supply twab. Should be called when user deposits.
    /// @param _amount The amount to increase the total by
    function _increaseTotalSupplyTwab(uint256 _amount) internal {
        if (_amount == 0) {
            return;
        }

        (
            TwabLib.AccountDetails memory accountDetails,
            ObservationLib.Observation memory _totalSupply,
            bool tsIsNew
        ) = TwabLib.increaseBalance(
                totalSupplyTwab,
                _amount.toUint208(),
                uint32(block.timestamp)
            );

        totalSupplyTwab.details = accountDetails;

        if (tsIsNew) {
            emit NewTotalSupplyTwab(_totalSupply);
        }
    }
}
