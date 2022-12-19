// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import {TestUtils} from "test/TestUtils.sol";
import "../src/MerkleProofs.sol";

contract MerkleProofsTest is TestUtils {
  MerkleDropHelper immutable helper = new MerkleDropHelper();

  function _createDrop(
    uint256 size
  )
    private
    returns (
      address[] memory members,
      uint256[] memory claimAmounts,
      bytes32[][] memory tree,
      MerkleDrop drop
    )
  {
    uint256 numMembers = size;
    uint256 totalEth = 0;
    members = new address[](numMembers);
    claimAmounts = new uint256[](numMembers);

    for (uint256 i = 0; i < numMembers; ++i) {
      members[i] = _randomAddress();
      uint256 a = 1 + (_randomUint256() % 1e18);
      claimAmounts[i] = a;
      totalEth += a;
    }
    bytes32 root;
    (root, tree) = helper.constructTree(members, claimAmounts);
    vm.deal(address(this), totalEth);
    drop = new MerkleDrop{value: totalEth}(root);
  }

  function testConstructTree1() external {
    (, , bytes32[][] memory tree, MerkleDrop drop) = _createDrop(1);
    assertEq(tree.length, 1);
    assertEq(tree[0].length, 1);
    assertEq(drop.ROOT(), tree[0][0]);
  }
}
