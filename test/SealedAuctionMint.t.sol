// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import {TestUtils} from "test/TestUtils.sol";
import {SealedAuctionMint} from "src/SealedAuctionMint.sol";

contract SealedAuctionMintTest is TestUtils {
  SealedAuctionMint internal proto;

  function setUp() public {
    proto = new SealedAuctionMint();
  }

  function testCanBid() public {
    uint auctionId = proto.getCurrentAuctionId();
    uint bidAmount = _getRandomBidAmount();

    (address bidder, uint maskAmount, , bytes32 commitHash) = _placeBid(
      auctionId,
      bidAmount
    );

    (uint bidEthAttached, bytes32 bidCommitHash) = proto.bidsByAuction(
      auctionId,
      bidder
    );

    assertEq(bidEthAttached, maskAmount);
    assertEq(bidCommitHash, commitHash);
  }

  function testCannotBidWithZeroCommitHash() public {
    uint auctionId = proto.getCurrentAuctionId();
    uint bidAmount = _getRandomBidAmount();
    uint maskAmount = bidAmount + 10;
    address bidder = _randomAddress();

    vm.deal(bidder, maskAmount);
    vm.prank(bidder);
    vm.expectRevert("invalid commit hash");
    proto.bid{value: maskAmount}(auctionId, 0);
  }

  function testCannnotBidOnFutureAuction() public {
    uint256 auctionId = proto.getCurrentAuctionId();
    vm.expectRevert("auction not accepting bids");
    _placeBid(auctionId + 1, _getRandomBidAmount());
  }

  function testCannotBidWithZeroValue() public {
    uint auctionId = proto.getCurrentAuctionId();
    vm.expectRevert("invalid bid");
    _placeBid(auctionId, 0);
  }

  function testCannotBidPastCommitPhase() public {
    uint auctionId = proto.getCurrentAuctionId();
    uint bidAmount = _getRandomBidAmount();
    skip(proto.AUCTION_COMMIT_DURATION());
    vm.expectRevert("auction not accepting bids");
    _placeBid(auctionId, bidAmount);
  }

  function testCannotBidPastRevealPhase() public {
    uint auctionId = proto.getCurrentAuctionId();
    uint bidAmount = _getRandomBidAmount();
    skip(proto.AUCTION_TOTAL_DURATION());
    vm.expectRevert("auction not accepting bids");
    _placeBid(auctionId, bidAmount);
  }

  function testCanRevealAndWin() public {
    uint bidAmount = _getRandomBidAmount();
    uint auctionId = proto.getCurrentAuctionId();

    (address bidder, , bytes32 salt, ) = _placeBid(auctionId, bidAmount);
    skip(proto.AUCTION_COMMIT_DURATION());
    vm.prank(bidder);
    proto.reveal(auctionId, bidAmount, salt);
    assertEq(proto.winningBidderByAuction(auctionId), bidder);
  }

  function _placeBid(
    uint auctionId,
    uint bidAmount
  )
    private
    returns (address bidder, uint maskAmount, bytes32 salt, bytes32 commitHash)
  {
    maskAmount = bidAmount * 10;
    salt = _randomBytes32();
    bidder = _randomAddress();
    commitHash = _getCommitHash(bidAmount, salt);
    vm.deal(bidder, maskAmount);
    vm.prank(bidder);
    proto.bid{value: maskAmount}(auctionId, commitHash);
  }

  function _getRandomBidAmount() private view returns (uint) {
    return (_randomUint256() % 1 ether) + 1;
  }

  function _getCommitHash(
    uint bidAmount,
    bytes32 salt
  ) private pure returns (bytes32) {
    return keccak256(abi.encodePacked(bidAmount, salt));
  }
}
