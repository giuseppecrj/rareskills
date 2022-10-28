pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {Vendor} from "../src/token-sale/Vendor.sol";
import {Token} from "../src/token-sale/Token.sol";

contract VendorTest is Test {
  Vendor public vendor;
  Token public token;

  function setUp() public {
    token = new Token();
    vendor = new Vendor(address(token));

    token.transfer(address(vendor), 22_000_000 * 10**uint256(token.decimals()));
  }

  function testBuyTokens() public {
    uint256 amountEth = 1 ether;
    uint256 amountToken = amountEth * vendor.tokensPerEth();

    address bob = address(1);
    vm.deal(bob, amountEth);
    vm.prank(bob);
    vendor.buyTokens{value: amountEth}();

    assertEq(token.balanceOf(bob), amountToken);
    assertEq(
      token.balanceOf(address(vendor)),
      22_000_000 * 10**uint256(token.decimals()) - amountToken
    );
  }
}
