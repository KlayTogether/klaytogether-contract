// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.6;

interface IPrizePool {
    /// @dev Event emitted when assets are deposited
    event Deposited(address indexed operator, uint256 amount);

    /// @dev Event emitted when interest is awarded to a winner
    event Awarded(address indexed winner, uint256 round, uint256 amount);

    /// @dev Event emitted when assets are withdrawn
    event Withdrew(address indexed to, uint256 indexed amount);

    /// @dev Event emitted when external KIP7s are awarded to a winner
    event AwardedExternalKIP7(
        address indexed winner,
        address indexed token,
        uint256 amount
    );

    /// @dev Event emitted when external KIP17s are awarded to a winner
    event AwardedExternalKIP17(
        address indexed winner,
        address indexed token,
        uint256[] tokenIds
    );

    /// @dev Event emitted when commission account is updated
    event UpdateCommissionAccount(address indexed commissionAccount);

    /// @dev Event emitted when commission rate is updated
    event UpdateCommissionRate(uint256 indexed commissionRate);

    /// @dev Event emitted when minimum deposit is updated
    event UpdateMinimumDeposit(uint256 indexed minimumDeposit);

    /// @dev Event emitted when the Prize Calculator is set
    event PrizeCalculatorSet(address indexed prizeCalculator);

    /// @dev Emitted when there was an error thrown awarding an External KIP17
    event ErrorAwardingExternalKIP17(bytes error);

    /// @dev Emitted when yield source prize pool is deployed.
    /// @param assetTokenContract Address of the yield source.
    event Deployed(
        address indexed assetTokenContract,
        address indexed klayswapPool
    );

    /// @notice Emitted when stray deposit token balance in this contract is swept
    /// @param amount The amount that was swept
    event Swept(uint256 amount);

    /// @notice Called by the prize calculator to award prizes.
    /// @dev When function is called, it exchanges all the interests to base token and records it to the winner.
    /// @param round Round number
    /// @param winner The winner of the round
    /// @return The amount awarded to the wiiner
    function award(uint256 round, address winner) external returns (uint256);

    /// @notice Award external KIP7 prizes when there is any. Only callable by the owner.
    /// @dev Used to award any arbitrary tokens held by the Prize Pool
    /// @param to The address of the winner that receives the award
    /// @param amount The amount of external assets to be awarded
    /// @param externalToken The address of the external asset token being awarded
    function awardExternalKIP7(
        address to,
        address externalToken,
        uint256 amount
    ) external;

    /// @notice Award external KIP7 prizes when there is any. Only callable by the owner.
    /// @dev Used to award any arbitrary NFTs held by the Prize Pool
    /// @param to The address of the winner that receives the award
    /// @param externalToken The address of the external NFT token being awarded
    /// @param tokenIds An array of NFT Token IDs to be transferred
    function awardExternalKIP17(
        address to,
        address externalToken,
        uint256[] calldata tokenIds
    ) external;

    /// @notice Sets the prize calculator of the prize pool. Only callable by the owner.
    /// @param newPrizeCalculator The new prize calculator.
    function setPrizeCalculator(address newPrizeCalculator) external;

    /// @notice Deposit token into the Prize Pool. Reverts when base asset is not token contract.
    /// @param amount The amount of token to deposit.
    function deposit(uint256 amount) external;

    /// @notice Deposit KLAY into the Prize Pool. Reverts when base asset is not KLAY.
    function depositKlay() external payable;

    /// @notice Withdraw assets from the Prize Pool instantly.
    /// @param amount Amount to withdraw
    function withdraw(uint256 amount) external;

    /// @notice Withdraw all the prize that user has won from the Prize Pool.
    function withdrawPrize() external;

    /// @notice Registers msg.sender to sponser list.
    function addSponsor() external;

    /// @notice Removes msg.sender from sponser list.
    function removeSponsor() external;

    /**
     * @notice Returns commission rate.
     * @return Commission rate in BP.
     */
    function getCommissionRate() external view returns (uint256);

    /// @notice Returns total deposit that Prize Pool holds.
    function getTotalDeposit() external view returns (uint256);

    /// @notice Returns user's total deposit.
    function getUserDeposit(address user) external view returns (uint256);

    /// @notice Returns user's unclaimed prize.
    function getUserUnclaimedPrize(address user)
        external
        view
        returns (uint256);

    // @notice Returns the total underlying balance of all assets. This includes both principal and interest.
    /// @return The underlying balance of assets
    function balance() external view returns (uint256);

    /// @notice Returns the balance that is available to award.
    /// @dev total underlying balance of all assets - total deposit
    /// @return The total amount of assets to be awarded for the current round
    function awardBalance() external view returns (uint256);

    /// @dev Checks with the Prize Pool if a specific token type may be awarded as an external prize
    /// @param externalToken The address of the token to check
    /// @return True if the token may be awarded, false otherwise
    function canAwardExternal(address externalToken)
        external
        view
        returns (bool);

    /**
     * @notice Read token variable
     */
    function getToken() external view returns (address);

    /**
     * @notice Read prizeCalculator variable
     */
    function getPrizeCalculator() external view returns (address);
}
