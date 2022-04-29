// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.6;

interface IKlayswapPool {
    function depositKlay() external payable;

    function depositKct(uint256 depositAmount) external;

    function withdraw(uint256 withdrawAmount) external;

    function withdrawByAmount(uint256 withdrawTokens) external;

    function claimReward() external;

    function totalBorrows() external view returns (uint256);

    function totalReserves() external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function balanceOf(address user) external view returns (uint256);

    function getCash() external view returns (uint256);

    function token() external view returns (address);
}
