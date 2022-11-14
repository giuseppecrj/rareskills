// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.17;

import "forge-std/Test.sol";

import {Token} from "contracts/Token.sol";
import {NFT} from "contracts/NFT.sol";
import {DataTypes} from "contracts/libraries/DataTypes.sol";
import {TokenWithStaking} from "contracts/TokenWithStaking.sol";

contract TokenWithStakingTest is Test {
  Token token;
  NFT nft;
  TokenWithStaking staking;

  address bob = address(1);
  address alice = address(2);

  function setUp() public {
    token = new Token();
    nft = new NFT();
    staking = new TokenWithStaking(address(nft), address(token));
  }

  function testMintNFT() public {
    vm.deal(bob, 1000 ether);

    // Max supply reached
    vm.startPrank(bob);
    vm.expectRevert("Not enough ETH");
    nft.mint{value: 0.01 ether}(bob);

    for (uint256 i = 0; i < 10; i++) {
      nft.mint{value: 0.1 ether}(bob);
    }

    assertEq(
      nft.tokenURI(0),
      "ipfs://bafybeiejf7vk35dcczls4eeg7m42hxpvhp2qmiktsowxkpvr5tm74b3yxq/0.json"
    );

    vm.expectRevert("Max supply reached");
    nft.mint{value: 0.1 ether}(bob);
    vm.stopPrank();
  }

  function testBurnNFT() public {
    vm.deal(bob, 1000 ether);

    // Bob burns NFT
    nft.mint{value: 0.1 ether}(bob);
    nft.mint{value: 0.1 ether}(bob);
    uint256 initialBalance = nft.balanceOf(bob);

    // Alice tries to burn Bob's NFT
    vm.prank(alice);
    vm.expectRevert("Caller is not owner nor approved");
    nft.burn(0);

    // Bob burns NFT
    vm.prank(bob);
    nft.burn(0);
    uint256 finalBalance = nft.balanceOf(bob);
    assertEq(finalBalance, initialBalance - 1);
  }

  function testWithdraw() public {
    // Failed to send
    vm.expectRevert("Failed to send Ether");
    nft.withdraw();

    // Withdraw
    vm.deal(alice, 1 ether);

    vm.prank(alice);
    nft.mint{value: 0.1 ether}(alice);

    nft.transferOwnership(bob);
    vm.prank(bob);
    nft.withdraw();
    assertEq(bob.balance, 0.1 ether);
  }

  function testStakeNFT() public {
    token.transferOwnership(address(staking));
    nft.mint{value: 0.1 ether}(bob);
    nft.mint{value: 0.1 ether}(bob);

    // Alice tries to stake NFT
    vm.startPrank(alice);
    vm.expectRevert("You don't own this token!");
    staking.stake(0);
    vm.stopPrank();

    // Alice tries to claim rewards
    vm.startPrank(alice);
    vm.expectRevert("You have no rewards to claim");
    staking.claimRewards();
    vm.stopPrank();

    // Bob stakes NFT
    vm.startPrank(bob);
    nft.approve(address(staking), 0);
    staking.stake(0);
    vm.stopPrank();

    // Bob stakes another NFT
    vm.startPrank(bob);
    nft.approve(address(staking), 1);
    staking.stake(1);
    vm.stopPrank();

    // Bob claims rewards
    vm.warp(1 days);

    // Bob checks available rewards
    vm.prank(bob);
    staking.availableRewards(bob);

    // Bob claims rewards
    vm.prank(bob);
    staking.claimRewards();

    // Alice tries to withdraw NFT
    vm.prank(alice);
    vm.expectRevert("You have no tokens staked");
    staking.withdraw(0);

    // Bob unstakes wrong token
    vm.prank(bob);
    vm.expectRevert("You don't own this token!");
    staking.withdraw(2);

    // Check bob's staked tokens
    staking.getStakedTokens(bob);

    // Check alice's staked tokens
    DataTypes.StakedToken[] memory aliceStakedTokens = staking.getStakedTokens(
      alice
    );

    assertEq(aliceStakedTokens.length, 0);

    // Bob unstakes NFT
    vm.prank(bob);
    staking.withdraw(0);
  }
}
