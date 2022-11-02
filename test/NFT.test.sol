// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.17;

import "forge-std/Test.sol";

import {NFT} from "../src/NFT.sol";

contract NFTTest is Test {
  NFT internal nft;
  address internal bob = address(1);

  function setUp() public {
    nft = new NFT();
  }

  function testMint() public {
    hoax(bob, 0.2 ether);
    nft.mint{value: 0.1 ether}(bob);
    assertEq(nft.balanceOf(bob), 1);
  }
}
