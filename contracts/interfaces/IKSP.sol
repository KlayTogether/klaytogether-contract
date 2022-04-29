// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.6;

interface IKSP {
    function transfer(address _to, uint256 _value) external returns (bool);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool);

    function approve(address _spender, uint256 _value) external returns (bool);

    function exchangeKlayPos(
        address token,
        uint256 amount,
        address[] memory path
    ) external payable;

    function exchangeKctPos(
        address tokenA,
        uint256 amountA,
        address tokenB,
        uint256 amountB,
        address[] memory path
    ) external;

    function exchangeKlayNeg(
        address token,
        uint256 amount,
        address[] memory path
    ) external payable;

    function exchangeKctNeg(
        address tokenA,
        uint256 amountA,
        address tokenB,
        uint256 amountB,
        address[] memory path
    ) external;

    function getPoolCount() external view returns (uint256);

    function getPoolAddress(uint256 index) external view returns (address);

    function mined() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);
}
