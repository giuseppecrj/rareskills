// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import {TokenWithSale} from "../contracts/TokenWithSale.sol";

contract TokenWithSaleTest is Test {
  TokenWithSale token;
  address bob = address(1);
  address alice = address(2);

  function setUp() public {
    token = new TokenWithSale("TokenWithSale", "TWS");
  }

  function testBuyTokens() public {
    // Bob doesn't send ether
    vm.expectRevert("TokenWithSale: incorrect amount");
    vm.prank(bob);
    token.buyTokens{value: 0 ether}();

    // Bob buys but there are not enough tokens
    vm.expectRevert("TokenWithSale: not enough tokens");
    vm.deal(bob, 10000 ether);
    vm.prank(bob);
    token.buyTokens{value: 10000 ether}();

    // Bob buys tokens
    uint256 initialBalance = token.balanceOf(bob);
    uint256 initialEthBalance = bob.balance;

    vm.prank(bob);
    token.buyTokens{value: 1 ether}();

    uint256 finalBalance = token.balanceOf(bob);
    uint256 finalEthBalance = bob.balance;

    assertEq(finalBalance, initialBalance + 10_000e18);
    assertEq(finalEthBalance, initialEthBalance - 1 ether);
  }

  function testSellTokens() public {
    vm.deal(alice, 1 ether);

    // Alice doesn't have enough tokens
    vm.expectRevert("TokenWithSale: incorrect amount");
    vm.prank(alice);
    token.sellTokens(0);

    // Alice sells but there are not enough ether
    token.godModeTransfer(address(this), alice, 1000000);
    vm.startPrank(alice);
    vm.expectRevert("TokenWithSale: not enough ether");
    token.sellTokens(1000000);
    vm.stopPrank();

    // Alice sells tokens
    token.buyTokens{value: 1 ether}();

    uint256 initialBalance = token.balanceOf(alice);
    uint256 initialEthBalance = alice.balance;

    vm.prank(alice);
    token.sellTokens(initialBalance);

    uint256 finalBalance = token.balanceOf(alice);
    uint256 finalEthBalance = alice.balance;

    assertEq(finalBalance, 0);
    assertGt(finalEthBalance, initialEthBalance);

    // Failed to send
    vm.expectRevert("TokenWithSale: failed to send");
    token.sellTokens(1);
  }

  function testWithdraw() public {
    // Failed to send
    vm.expectRevert("TokenWithSale: failed to send");
    token.withdraw();

    // Withdraw
    vm.deal(bob, 1 ether);

    vm.prank(bob);
    token.buyTokens{value: 1 ether}();

    token.transferOwnership(bob);
    vm.prank(bob);
    token.withdraw();
    assertEq(bob.balance, 1 ether);
  }
}
