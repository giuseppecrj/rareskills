// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {TokenWithSale} from "../src/week-1/TokenWithSale.sol";

contract TokenWithSaleTest is Test {
  TokenWithSale token;

  function setUp() public {
    token = new TokenWithSale("TokenWithSale", "TWS");
  }

  function testBuyTokens() public {
    address bob = address(0x1);

    vm.deal(bob, 1 ether);

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
    address bob = address(0x1);
    uint256 value = 1 ether;

    hoax(bob, value);
    token.buyTokens{value: value}();

    uint256 initialBalance = token.balanceOf(bob);

    vm.prank(bob);
    token.sellTokens(initialBalance);

    uint256 finalBalance = token.balanceOf(bob);
    assertEq(finalBalance, 0);
    assertEq(bob.balance, value - value / 10);
  }
}
