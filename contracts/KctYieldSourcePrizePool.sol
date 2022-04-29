// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.6;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "./PrizePool.sol";
import "./interfaces/IKlayswapPool.sol";
import "./interfaces/IKIP7.sol";
import "./interfaces/IKSP.sol";

/**
 * @title  KlayTogether V1 KctYieldSourcePrizePool
 * @author KlayTogether Inc Team
 * @notice The Kct Yield Source Prize Pool V1 uses Kct as base asset and KlaySwap as a yield source to generate prizes.
 *         Funds that are deposited into the prize pool are then deposited into KlaySwap to generate yield.
 */
contract KctYieldSourcePrizePool is PrizePool {
    using Address for address;
    using SafeMath for uint256;

    address private constant KSP_CONTRACT =
        0xC6a2Ad8cC6e4A7E08FC37cC5954be07d499E7654;

    IKIP7 public assetToken;
    IKlayswapPool public klayswapPool;

    /// @notice Deploy the Kct Yield Source Prize Pool
    /// @param _owner Address of the Yield Source Prize Pool owner
    /// @param _klayswapPool Address of the yield source
    constructor(
        address _owner,
        IKlayswapPool _klayswapPool,
        address _commissionAccount,
        uint256 _minimumDeposit     
    ) PrizePool(_owner, _commissionAccount, _minimumDeposit) {
        klayswapPool = _klayswapPool;
        assetToken = IKIP7(klayswapPool.token());
        emit Deployed(address(assetToken), address(klayswapPool));
    }

    /// @notice Sweeps any stray balance of deposit tokens into the yield source.
    /// @dev This becomes prize money
    function sweep() external nonReentrant onlyOwner {
        uint256 balance = _token().balanceOf(address(this));
        _supply(balance);

        emit Swept(balance);
    }

    /// @inheritdoc PrizePool
    function _canAwardExternal(address _externalToken)
        internal
        view
        override
        returns (bool)
    {
        IKlayswapPool _klayswapPool = klayswapPool;
        return (_externalToken != address(_klayswapPool) &&
            _externalToken != _klayswapPool.token());
    }

    /// @inheritdoc PrizePool
    function _balance() internal view override returns (uint256) {
        uint256 _principal = klayswapPool
            .getCash()
            .add(klayswapPool.totalBorrows())
            .sub(klayswapPool.totalReserves());
        uint256 _decimal = 10**18;
        return
            (
                ((_principal.mul(_decimal)).div(klayswapPool.totalSupply()))
                    .mul(klayswapPool.balanceOf(address(this)))
            ).div(_decimal);
    }

    /// @inheritdoc PrizePool
    function _token() internal view override returns (IKIP7) {
        return IKIP7(klayswapPool.token());
    }

    /// @inheritdoc PrizePool
    function _supply(uint256 _amount) internal override {
        _token().increaseApproval(address(klayswapPool), _amount);
        klayswapPool.depositKct(_amount);
    }

    /// @inheritdoc PrizePool
    function _redeem(uint256 _redeemAmount) internal override {
        klayswapPool.withdraw(_redeemAmount);
    }

    /// @inheritdoc PrizePool
    function _award(uint256 _basePrize) internal override returns (uint256) {
        // withdraw calculated amount from yield source
        klayswapPool.withdraw(_basePrize);

        // record KLAY balance before swapping KSP into KLAY
        uint256 beforeKspExchange = _token().balanceOf(address(this));
        address[] memory emptyPath;

        uint256 kspBalance = IKSP(KSP_CONTRACT).balanceOf(address(this));

        if (
            IKIP7(KSP_CONTRACT).allowance(address(this), KSP_CONTRACT) <
            kspBalance
        ) {
            IKIP7(KSP_CONTRACT).approve(KSP_CONTRACT, type(uint256).max);
        }

        IKSP(KSP_CONTRACT).exchangeKctPos(
            KSP_CONTRACT,
            kspBalance,
            address(_token()),
            1,
            emptyPath
        );

        // return additional prize amount from KSP token swap
        return _token().balanceOf(address(this)) - beforeKspExchange;
    }

    /// @inheritdoc PrizePool
    function _deposit(address _user, uint256 _amount) internal override {
        _token().transferFrom(_user, address(this), _amount);
        // record amount at Prize Calculator (do not record in case of spondsor)
        if (!isSponsor[msg.sender]) {
            IPrizeCalculator _prizeCalculator = IPrizeCalculator(
                prizeCalculator
            );
            _prizeCalculator.deposit(_user, _amount);
        }

        userBalances[msg.sender] = userBalances[msg.sender].add(_amount);

        _supply(_amount);

        emit Deposited(_user, _amount);
    }

    /// @inheritdoc PrizePool
    function _transferToken(address _to, uint256 _amount) internal override {
        _token().safeTransfer(_to, _amount);
    }
}
