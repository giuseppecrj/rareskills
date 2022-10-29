// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {TokenWithBondingCurve} from "../src/week-1/TokenWithBondingCurve.sol";

contract TokenWithBondingCurveTest is Test {
  address internal bob = address(0x1);
  TokenWithBondingCurve internal token;

  function setUp() public {
    token = new TokenWithBondingCurve("TokenWithBondingCurve", "TWS");
  }

  function testBuyCurveToken() public {
    // vm.deal(bob, 1 ether);
    // vm.prank(bob);
    hoax(bob, 10 ether);
    token.buyTokens{value: 1 ether}();
    token.buyTokens{value: 1 ether}();
    token.buyTokens{value: 1 ether}();
    token.buyTokens{value: 1 ether}();
    token.buyTokens{value: 1 ether}();
    token.buyTokens{value: 1 ether}();
  }
}
