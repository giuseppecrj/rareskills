// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import {NFTEnumerable} from "../src/Enumerable.sol";
import {Errors} from "../src/library/Errors.sol";

contract NFTEnumerableTest is Test {
  NFTEnumerable internal nft;
  address internal bob = address(1);

  function setUp() public {
    nft = new NFTEnumerable();
  }

  function testMint() public {
    nft.mint(bob);
    assertEq(nft.balanceOf(bob), 1);
  }

  function testMintMax() public {
    for (uint256 i = 0; i < 20; i++) {
      nft.mint(bob);
    }
    assertEq(nft.balanceOf(bob), 20, "Enumerable: Mint Max");
  }

  function testMintMaxPlusOne() public {
    for (uint256 i = 0; i < 20; i++) {
      nft.mint(bob);
    }
    assertEq(nft.balanceOf(bob), 20, "Enumerable: Mint Max");

    vm.expectRevert(abi.encodeWithSelector(Errors.MaxSupplyReached.selector));
    nft.mint(bob);
  }
}
