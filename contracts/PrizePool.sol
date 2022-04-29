// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.6;

import "@openzeppelin/contracts/utils/math/SafeCast.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@pooltogether/owner-manager-contracts/contracts/Ownable.sol";

import "./interfaces/IPrizePool.sol";
import "./interfaces/IPrizeCalculator.sol";
import "./interfaces/IKIP7.sol";
import "./interfaces/IKIP17.sol";
import "./interfaces/IKIP17Receiver.sol";

/**
  * @title  KlayTogether V1 PrizePool
  * @author KlayTogether Inc Team
  * @notice Escrows assets and deposits them into a yield source. Exposes interest to Prize Calculator.
            Users deposit and withdraw from this contract to participate in Prize Pool.
            Accounting is managed using Prize Calculator contract, whose deposit and withdraw functions can only be called by this contract.
            Must be inherited to provide specific yield-bearing asset control.
*/
abstract contract PrizePool is
    IPrizePool,
    Ownable,
    ReentrancyGuard,
    IKIP17Receiver
{
    using SafeCast for uint256;
    using SafeMath for uint256;

    /* ============ Variables ============ */

    /// @notice Semver Version
    string public constant VERSION = "1.0.0";
    uint256 private constant _COMMISSION_BASE_UNIT = 10000; // one basis point (1/10000)
    address internal constant ZERO_ADDRESS =
        0x0000000000000000000000000000000000000000;

    /// @notice The Prize Calculator that this Prize Pool is bound to.
    address internal prizeCalculator;

    /// @notice The total deposits for each user.
    mapping(address => uint256) public userBalances;

    mapping(address => uint256) public userPrizes;

    /// @notice Deposits from sponsors are not included when calculating winners.
    mapping(address => bool) public isSponsor;

    uint256 private _totalDeposit;
    address public commissionAccount; // account that receives commissions.
    uint256 public commissionRate; // in bp
    uint256 public minimumDeposit; // minimum deposit to prevent abuse

    /* ============ Modifiers ============ */

    /// @dev Function modifier to ensure caller is the prize-calculator
    modifier onlyPrizeCalculator() {
        require(
            msg.sender == prizeCalculator,
            "PrizePool/only-prize-calculator"
        );
        _;
    }

    /* ============ Constructor ============ */

    /// @notice Deploy the Prize Pool
    /// @param _owner Address of the Prize Pool owner
    constructor(address _owner, address _commissionAccount, uint256 _minimumDeposit)
        Ownable(_owner)
        ReentrancyGuard()
    {
        updateCommissionAccount(_commissionAccount);
        updateMinimumDeposit(_minimumDeposit);
    }

    /* ============ Restricted Functions ============ */

    function updateCommissionRate(uint256 _commissionRate) public onlyOwner {
        require(
            _commissionRate <= _COMMISSION_BASE_UNIT,
            "PrizePool/invalid-commission-rate"
        );

        commissionRate = _commissionRate;
        emit UpdateCommissionRate(commissionRate);
    }

    function updateCommissionAccount(address _commissionAccount)
        public
        onlyOwner
    {
        require(_commissionAccount != address(0), "PrizePool/no-zero-address");

        commissionAccount = _commissionAccount;
        emit UpdateCommissionAccount(commissionAccount);
    }

    function updateMinimumDeposit(uint256 _minimumDeposit) public onlyOwner {
        minimumDeposit = _minimumDeposit;
        emit UpdateMinimumDeposit(minimumDeposit);
    }

    /// @inheritdoc IPrizePool
    function award(uint256 round, address winner)
        external
        override
        onlyPrizeCalculator
        returns (uint256)
    {
        uint256 basePrize = _balance().sub(_totalDeposit);
        uint256 additionalPrize = _award(basePrize);
        uint256 prize = basePrize.add(additionalPrize);

        // calculate and transfer commission to commission account
        uint256 fee = prize.mul(commissionRate).div(_COMMISSION_BASE_UNIT);
        _transferToken(commissionAccount, fee);
        emit Withdrew(commissionAccount, fee);

        uint256 reward = prize.sub(fee);
        userPrizes[winner] = userPrizes[winner].add(reward);
        emit Awarded(winner, round, reward);

        return reward;
    }

    /// @inheritdoc IPrizePool
    function awardExternalKIP7(
        address _to,
        address _externalToken,
        uint256 _amount
    ) external override onlyOwner {
        if (_transferOut(_to, _externalToken, _amount)) {
            emit AwardedExternalKIP7(_to, _externalToken, _amount);
        }
    }

    /// @inheritdoc IPrizePool
    function awardExternalKIP17(
        address _to,
        address _externalToken,
        uint256[] calldata _tokenIds
    ) external override onlyOwner {
        require(
            _canAwardExternal(_externalToken),
            "PrizePool/invalid-external-token"
        );

        if (_tokenIds.length == 0) {
            return;
        }

        uint256[] memory _awardedTokenIds = new uint256[](_tokenIds.length);
        bool hasAwardedTokenIds;

        for (uint256 i = 0; i < _tokenIds.length; i++) {
            try
                IKIP17(_externalToken).safeTransferFrom(
                    address(this),
                    _to,
                    _tokenIds[i]
                )
            {
                hasAwardedTokenIds = true;
                _awardedTokenIds[i] = _tokenIds[i];
            } catch (bytes memory error) {
                emit ErrorAwardingExternalKIP17(error);
            }
        }
        if (hasAwardedTokenIds) {
            emit AwardedExternalKIP17(_to, _externalToken, _awardedTokenIds);
        }
    }

    /// @inheritdoc IPrizePool
    function setPrizeCalculator(address newPrizeCalculator)
        external
        override
        onlyOwner
    {
        _setPrizeCalculator(newPrizeCalculator);
    }

    /* ============ External Functions ============ */

    /// @inheritdoc IPrizePool
    function deposit(uint256 amount) external override nonReentrant {
        require(
            address(_token()) != ZERO_ADDRESS,
            "PrizePool/only-kct-contract"
        );
        require(
            amount >= minimumDeposit,
            "PrizePool/less-than-minimum-deposit"
        );
        _totalDeposit = _totalDeposit.add(amount);
        _deposit(msg.sender, amount);
    }

    /// @inheritdoc IPrizePool
    function depositKlay() external payable override nonReentrant {
        require(
            address(_token()) == ZERO_ADDRESS,
            "PrizePool/only-klay-contract"
        );
        require(
            msg.value >= minimumDeposit,
            "PrizePool/less-than-minimum-deposit"
        );
        _totalDeposit = _totalDeposit.add(msg.value);
        _deposit(msg.sender, msg.value);
    }

    /// @inheritdoc IPrizePool
    function withdraw(uint256 amount) external override nonReentrant {
        // redeems amount from yield source
        _redeem(amount);
        // record amount at Prize Calculator (do not record in case of spondsor)
        if (!isSponsor[msg.sender]) {
            IPrizeCalculator _prizeCalculator = IPrizeCalculator(
                prizeCalculator
            );
            _prizeCalculator.withdraw(msg.sender, amount);
        }

        _transferToken(msg.sender, amount);

        userBalances[msg.sender] = userBalances[msg.sender].sub(amount);
        _totalDeposit = _totalDeposit.sub(amount);

        emit Withdrew(msg.sender, amount);
    }

    /// @inheritdoc IPrizePool
    function withdrawPrize() external override nonReentrant {
        require(userPrizes[msg.sender] > 0, "PrizePool/no-prize-yet");

        _transferToken(msg.sender, userPrizes[msg.sender]);

        emit Withdrew(msg.sender, userPrizes[msg.sender]);

        userPrizes[msg.sender] = 0;
    }

    /// @inheritdoc IPrizePool
    function addSponsor() external override {
        require(
            userBalances[msg.sender] == 0,
            "PrizePool/cannot-add-sponsor-with-nonzero-balance"
        );
        require(isSponsor[msg.sender] == false, "PrizePool/already-sponsor");

        isSponsor[msg.sender] = true;
    }

    /// @inheritdoc IPrizePool
    function removeSponsor() external override {
        require(
            userBalances[msg.sender] == 0,
            "PrizePool/remove-balance-first"
        );
        require(isSponsor[msg.sender] == true, "PrizePool/not-sponsor");

        isSponsor[msg.sender] = false;
    }

    function getCommissionRate() external view override returns (uint256) {
        return commissionRate;
    }

    /// @inheritdoc IPrizePool
    function getTotalDeposit() external view override returns (uint256) {
        return _totalDeposit;
    }

    /// @inheritdoc IPrizePool
    function getUserDeposit(address user)
        external
        view
        override
        returns (uint256)
    {
        return userBalances[user];
    }

    function getUserUnclaimedPrize(address user)
        external
        view
        override
        returns (uint256)
    {
        return userPrizes[user];
    }

    /// @inheritdoc IPrizePool
    function balance() external view override returns (uint256) {
        return _balance();
    }

    /// @inheritdoc IPrizePool
    function awardBalance() external view override returns (uint256) {
        return _balance().sub(_totalDeposit);
    }

    /// @inheritdoc IPrizePool
    function canAwardExternal(address _externalToken)
        external
        view
        override
        returns (bool)
    {
        return _canAwardExternal(_externalToken);
    }

    /// @inheritdoc IPrizePool
    function getToken() external view override returns (address) {
        return address(_token());
    }

    /// @inheritdoc IPrizePool
    function getPrizeCalculator() external view override returns (address) {
        return prizeCalculator;
    }

    /// @inheritdoc IKIP17Receiver
    function onKIP17Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return IKIP17Receiver.onKIP17Received.selector;
    }

    /* ============ Internal Functions ============ */

    /// @notice Transfer out `amount` of `externalToken` to recipient `to`
    /// @dev Only awardable `externalToken` can be transferred out
    /// @param _to Recipient address
    /// @param _externalToken Address of the external asset token being transferred
    /// @param _amount Amount of external assets to be transferred
    /// @return True if transfer is successful
    function _transferOut(
        address _to,
        address _externalToken,
        uint256 _amount
    ) internal returns (bool) {
        require(
            _canAwardExternal(_externalToken),
            "PrizePool/invalid-external-token"
        );

        if (_amount == 0) {
            return false;
        }

        IKIP7(_externalToken).safeTransfer(_to, _amount);

        return true;
    }

    /// @notice Sets the prize calculator of the prize pool.
    /// @param _prizeCalculator The new prize calculator.
    function _setPrizeCalculator(address _prizeCalculator) internal {
        require(
            IPrizeCalculator(_prizeCalculator).getPrizePool() == address(this),
            "PrizePool/invalid-calculator"
        );
        prizeCalculator = _prizeCalculator;

        emit PrizeCalculatorSet(_prizeCalculator);
    }

    /* ============ Abstract Contract Implementatiton ============ */

    /// @notice Redeems interest from yield source and swaps additional token interest (such as KSP)
    ///         to base token to award prize.
    /// @dev Prize Pool holds the awarded prize in base token until the winner withdraws prize.
    /// @param _basePrize Amount of prize to award
    /// @return Amount of additional prize from token swap
    function _award(uint256 _basePrize) internal virtual returns (uint256);

    /// @notice Determines whether the passed token can be transferred out as an external award.
    /// @dev Different yield sources will hold the deposits as another kind of token: such a Compound's cToken.
    /// @param _externalToken The address of the token to check
    /// @return True if the token may be awarded, false otherwise
    function _canAwardExternal(address _externalToken)
        internal
        view
        virtual
        returns (bool);

    /// @notice Returns the KIP7 asset token used for deposits. In case of KLAY it returns zero address.
    /// @return The KIP7 asset token
    function _token() internal view virtual returns (IKIP7);

    /// @notice Returns the total balance (in asset tokens). This includes the deposits and interest.
    /// @return The underlying balance of asset tokens
    function _balance() internal view virtual returns (uint256);

    /// @notice Supplies asset tokens to the yield source.
    /// @param _mintAmount The amount of asset tokens to be supplied
    function _supply(uint256 _mintAmount) internal virtual;

    /// @notice Redeems asset tokens from the yield source.
    /// @param _redeemAmount The amount of yield-bearing tokens to be redeemed
    function _redeem(uint256 _redeemAmount) internal virtual;

    /// @notice deposit tokens in from one user
    /// @notice _user The user who deposits
    /// @notice _amount The amount to deposit
    function _deposit(address _user, uint256 _amount) internal virtual;

    /// @notice Transfers token to user
    /// @notice _user The user to transfer tokens
    /// @notice _amount The amount to transfer
    function _transferToken(address _to, uint256 _amount) internal virtual;
}
