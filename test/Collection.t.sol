// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import {Collection} from "../src/Collection.sol";
import {NFTEnumerable} from "../src/Enumerable.sol";

contract CollectionTest is Test {
  NFTEnumerable internal nft;
  Collection internal collection;
  address internal bob = address(1);
  address internal alice = address(2);

  function setUp() public {
    nft = new NFTEnumerable();
    collection = new Collection(nft);
  }

  function testMint() public {
    nft.mint(bob);
    nft.mint(alice);
    nft.mint(alice);
    nft.mint(alice);
    nft.mint(alice);
    nft.mint(alice);
    nft.mint(alice);
    nft.mint(alice);
    nft.mint(alice);
    nft.mint(bob); // 10
    nft.mint(bob);
    nft.mint(bob);
    nft.mint(bob);
    assertEq(collection.getPrimeTokenIdCount(bob), 2);
  }
}
