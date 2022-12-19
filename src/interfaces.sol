// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

// Minimal ERC20 interface.
interface IERC20 {
  function transfer(address to, uint256 amount) external returns (bool);

  function transferFrom(
    address owner,
    address to,
    uint256 amount
  ) external returns (bool);

  function approve(address spender, uint256 allowance) external returns (bool);
}

// Minimal WETH interface.
interface IWETH is IERC20 {
  function deposit() external payable;

  function withdraw(uint256 weth) external;
}

// Minimal ERC4626 interface.
interface IERC4626 is IERC20 {
  function asset() external returns (IERC20);

  function deposit(
    uint256 assets,
    address receiver
  ) external returns (uint256 shares);

  function redeem(
    uint256 shares,
    address receiver,
    address owner
  ) external returns (uint256 assets);
}
