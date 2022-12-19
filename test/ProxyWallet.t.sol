// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import {console} from "forge-std/console.sol";
import {TestUtils} from "test/TestUtils.sol";
import {WalletProxy, WalletLogicV1, WalletLogicV2, IERC20} from "src/ProxyWallet.sol";

contract ProxyWalletTest is TestUtils {
  WalletProxy internal proxy;
  WalletLogicV1 internal logicV1 = new WalletLogicV1();
  WalletLogicV2 internal logicV2 = new WalletLogicV2();
  DummyERC20 internal erc20 = new DummyERC20();

  function setUp() public {
    proxy = new WalletProxy(address(logicV1));
  }

  function testUpgrade() public {
    WalletLogicV1 wallet = WalletLogicV1(payable(proxy));
    assertEq(wallet.version(), "V1");

    proxy.upgrade(address(logicV2));
    assertEq(wallet.version(), "V2");
  }

  function testOnlyOwnerCanUpgrade() public {
    vm.prank(_randomAddress());
    vm.expectRevert("only owner");
    proxy.upgrade(address(logicV2));
  }

  function testV1CanTransferEth() public {
    WalletLogicV1 wallet = WalletLogicV1(payable(proxy));
    payable(address(wallet)).transfer(100);

    address payable recipient = _randomAddress();
    wallet.transferETH(recipient, 1);

    assertEq(recipient.balance, 1);
  }

  function testV1CanOnlyTransferETHAsOwner() public {
    WalletLogicV1 wallet = WalletLogicV1(payable(proxy));
    payable(address(wallet)).transfer(100);
    address payable recipient = _randomAddress();
    vm.expectRevert("only owner");
    vm.prank(_randomAddress());
    wallet.transferETH(recipient, 1);
  }

  function testV2CanTransferERC20() public {
    proxy.upgrade(address(logicV2));
    WalletLogicV2 wallet = WalletLogicV2(payable(proxy));
    erc20.mint(address(wallet), 100);
    address recipient = _randomAddress();
    wallet.transferERC20(erc20, recipient, 1);
    assertEq(erc20.balanceOf(recipient), 1);
  }

  function testV2CanOnlyTransferERC20AsOwner() public {
    proxy.upgrade(address(logicV2));
    WalletLogicV2 wallet = WalletLogicV2(payable(proxy));
    erc20.mint(address(wallet), 100);
    address recipient = _randomAddress();
    vm.expectRevert("only owner");
    vm.prank(_randomAddress());
    wallet.transferERC20(erc20, recipient, 1);
  }
}

contract DummyERC20 is IERC20 {
  mapping(address => uint256) public balanceOf;

  function mint(address owner, uint256 amount) external {
    balanceOf[owner] += amount;
  }

  function transfer(address to, uint256 amount) external returns (bool) {
    balanceOf[msg.sender] -= amount;
    balanceOf[to] += amount;
    return true;
  }
}
