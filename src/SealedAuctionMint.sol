// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

contract SealedAuctionMint {
  struct SealedBid {
    uint ethAttached;
    bytes32 commitHash;
  }

  uint public constant AUCTION_COMMIT_DURATION = 1 days;
  uint public constant AUCTION_REVEAL_DURATION = 1 days;
  uint public constant AUCTION_TOTAL_DURATION =
    AUCTION_COMMIT_DURATION + AUCTION_REVEAL_DURATION;

  uint public immutable launchTime;
  uint public lastTokenId;

  mapping(uint => mapping(address => SealedBid)) public bidsByAuction;
  mapping(uint => address) public winningBidderByAuction;
  mapping(uint => uint) public winningBidAmountByAuction;
  mapping(uint => address) public ownerOf;

  constructor() {
    launchTime = block.timestamp;
  }

  // Place a sealed bid on the current auction
  // This can only be called during the commit phase of an auction
  // The amount of ETH attached should exceed the true bid by orders of magnitude to
  // adequately mask the true bid
  // `commitHash` is the `keccak256(bidAmount, salt)` where `bidAmount` and `salt`
  // are only known to the bidder
  function bid(uint auctionId, bytes32 commitHash) external payable {
    require(auctionId == getCurrentAuctionId(), "auction not accepting bids");
    require(commitHash != 0, "invalid commit hash");
    require(
      bidsByAuction[auctionId][msg.sender].commitHash == 0,
      "bid already placed"
    );
    require(msg.value != 0, "invalid bid");
    bidsByAuction[auctionId][msg.sender] = SealedBid({
      ethAttached: msg.value,
      commitHash: commitHash
    });
  }

  function reveal(uint auctionId, uint bidAmount, bytes32 salt) external {
    require(auctionId < getCurrentAuctionId(), "bidding still ongoing");
    require(!isAuctionOver(auctionId), "auction over");

    SealedBid memory _bid = bidsByAuction[auctionId][msg.sender];
    require(
      _bid.commitHash == keccak256(abi.encode(bidAmount, salt)),
      "invalid reveal"
    );

    uint256 cappedBidAmount = bidAmount > _bid.ethAttached
      ? _bid.ethAttached
      : bidAmount;

    // if caller's bid is > the winning bid amount, they're the new winner
    uint winningBidAmount = winningBidAmountByAuction[auctionId];
    if (cappedBidAmount > winningBidAmount) {
      winningBidderByAuction[auctionId] = msg.sender;
      winningBidAmountByAuction[auctionId] = cappedBidAmount;
    }
  }

  function reclaim(uint auctionId) external {
    require(auctionId < getCurrentAuctionId(), "bidding still ongoing");
    address winningBidder = winningBidderByAuction[auctionId];
    require(winningBidder != msg.sender, "winner cannot reclaim");

    uint refund = bidsByAuction[auctionId][msg.sender].ethAttached;
    require(refund != 0, "already reclaimed");

    bidsByAuction[auctionId][msg.sender].ethAttached = 0;
    (bool success, ) = msg.sender.call{value: refund}("");
    require(success, "refund failed");
  }

  function mint(uint auctionId) external {
    require(isAuctionOver(auctionId), "auction not over");
    require(winningBidderByAuction[auctionId] == msg.sender, "not winner");
    require(
      bidsByAuction[auctionId][msg.sender].ethAttached != 0,
      "already minted"
    );

    uint ethAttached = bidsByAuction[auctionId][msg.sender].ethAttached;
    bidsByAuction[auctionId][msg.sender].ethAttached = 0;

    _mintTo(msg.sender);

    uint refund = ethAttached - winningBidAmountByAuction[auctionId];
    if (refund != 0) {
      (bool success, ) = msg.sender.call{value: refund}("");
      require(success, "refund failed");
    }
  }

  function getCurrentAuctionId() public view returns (uint256 auctionId) {
    return (block.timestamp - launchTime) / AUCTION_COMMIT_DURATION + 1;
  }

  function getAuctionStartTime(
    uint256 auctionId
  ) public pure returns (uint256 startTime) {
    return ((auctionId - 1) * AUCTION_COMMIT_DURATION) + startTime;
  }

  function isAuctionOver(uint256 auctionId) public view returns (bool) {
    return
      getAuctionStartTime(auctionId) + AUCTION_TOTAL_DURATION <=
      block.timestamp;
  }

  function _mintTo(address owner) private {
    ownerOf[++lastTokenId] = owner;
  }
}
