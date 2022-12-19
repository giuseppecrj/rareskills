// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "./TestUtils.sol";
import "../src/TeamFarm.sol";
import "./mocks.sol";

contract TeamFarmTest is TestUtils {
  IERC20 NATIVE_TOKEN = IERC20(address(0));
  ERC20 asset = new ERC20();
  WETH weth = new WETH();
  TeamFarm farm;
  TestVault vault;

  function setUp() public {
    address[] memory members = new address[](1);
    members[0] = address(this);

    farm = new TeamFarm(weth, members);
    vault = new TestVault(weth);
  }

  function testCanMulticallDepositWrapStake() external {
    uint256 amount = 100;
    bytes[] memory calls = new bytes[](3);
    calls[0] = abi.encodeCall(farm.deposit, (NATIVE_TOKEN, amount));
    calls[1] = abi.encodeCall(farm.wrap, (amount));
    calls[2] = abi.encodeCall(farm.stake, (vault, amount));
    farm.multicall{value: amount}(calls);
    assertEq(weth.balanceOf(address(vault)), amount);
    assertEq(vault.balanceOf(address(farm)), amount * 10);
  }

  function testCanMulticallUnstakeUnwrapWithdraw() external {
    uint256 amount = 100;
    bytes[] memory calls = new bytes[](3);
    calls[0] = abi.encodeCall(farm.deposit, (NATIVE_TOKEN, amount));
    calls[1] = abi.encodeCall(farm.wrap, (amount));
    calls[2] = abi.encodeCall(farm.stake, (vault, amount));
    farm.multicall{value: amount}(calls);

    address payable receiver = _randomAddress();
    calls[0] = abi.encodeCall(farm.unstake, (vault, amount * 10));
    calls[1] = abi.encodeCall(farm.unwrap, (amount));
    calls[2] = abi.encodeCall(farm.withdraw, (NATIVE_TOKEN, amount, receiver));
    farm.multicall(calls);

    assertEq(weth.balanceOf(address(vault)), 0);
    assertEq(receiver.balance, amount);
  }
}

contract TestVault is IERC4626, ERC20 {
  IERC20 public immutable asset;

  constructor(IERC20 asset_) {
    asset = asset_;
  }

  function deposit(
    uint256 assets,
    address receiver
  ) external returns (uint256 shares) {
    shares = assets * 10;
    asset.transferFrom(msg.sender, address(this), assets);
    balanceOf[receiver] += shares;
  }

  function redeem(
    uint256 shares,
    address receiver,
    address owner
  ) external returns (uint256 assets) {
    assets = shares / 10;
    require(msg.sender == owner, "allowances not implemented");
    balanceOf[owner] -= shares;
    asset.transfer(receiver, assets);
  }
}
