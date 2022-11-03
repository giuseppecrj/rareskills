// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "openzeppelin-contracts/token/ERC721/IERC721.sol";
import "openzeppelin-contracts/security/ReentrancyGuard.sol";

import {Token} from "./Token.sol";
import {DataTypes} from "./library/DataTypes.sol";

contract ERC721Staking is ReentrancyGuard {
  // Interfaces for ERC20 and ERC721
  Token public immutable rewardsToken;
  IERC721 public immutable nftCollection;

  // Constructor function to set the rewards token and the NFT collection addresses
  constructor(IERC721 _nftCollection, Token _rewardsToken) {
    nftCollection = _nftCollection;
    rewardsToken = _rewardsToken;
  }

  // Rewards per hour per token deposited in wei.
  uint256 private rewardsPerHour = 416666666666666666;

  // Mapping of User Address to Staker info
  mapping(address => DataTypes.Staker) public stakers;

  // Mapping of Token Id to staker. Made for the SC to remember
  // who to send back the ERC721 Token to.
  mapping(uint256 => address) public stakerAddress;

  // If address already has ERC721 Token/s staked, calculate the rewards.
  // Increment the amountStaked and map msg.sender to the Token Id of the staked
  // Token to later send back on withdrawal. Finally give timeOfLastUpdate the
  // value of now.
  function stake(uint256 _tokenId) external nonReentrant {
    // If wallet has tokens staked, calculate the rewards before adding the new token
    if (stakers[msg.sender].amountStaked > 0) {
      uint256 rewards = calculateRewards(msg.sender);
      stakers[msg.sender].unclaimedRewards += rewards;
    }

    // Wallet must own the token they are trying to stake
    require(
      nftCollection.ownerOf(_tokenId) == msg.sender,
      "You don't own this token!"
    );

    // Transfer the token from the wallet to the Smart contract
    nftCollection.transferFrom(msg.sender, address(this), _tokenId);

    // Create DataTypes.StakedToken
    DataTypes.StakedToken memory stakedToken = DataTypes.StakedToken(
      msg.sender,
      _tokenId
    );

    // Add the token to the stakedTokens array
    stakers[msg.sender].stakedTokens.push(stakedToken);

    // Increment the amount staked for this wallet
    stakers[msg.sender].amountStaked++;

    // Update the mapping of the tokenId to the staker's address
    stakerAddress[_tokenId] = msg.sender;

    // Update the timeOfLastUpdate for the staker
    stakers[msg.sender].timeOfLastUpdate = block.timestamp;
  }

  // Check if user has any ERC721 Tokens Staked and if they tried to withdraw,
  // calculate the rewards and store them in the unclaimedRewards
  // decrement the amountStaked of the user and transfer the ERC721 token back to them
  function withdraw(uint256 _tokenId) external nonReentrant {
    // Make sure the user has at least one token staked before withdrawing
    require(stakers[msg.sender].amountStaked > 0, "You have no tokens staked");

    // Wallet must own the token they are trying to withdraw
    require(stakerAddress[_tokenId] == msg.sender, "You don't own this token!");

    // Update the rewards for this user, as the amount of rewards decreases with less tokens.
    uint256 rewards = calculateRewards(msg.sender);
    stakers[msg.sender].unclaimedRewards += rewards;

    // Find the index of this token id in the stakedTokens array
    uint256 index = 0;
    uint256 len = stakers[msg.sender].stakedTokens.length;

    for (uint256 i = 0; i < len; ) {
      if (
        stakers[msg.sender].stakedTokens[i].tokenId == _tokenId &&
        stakers[msg.sender].stakedTokens[i].staker != address(0)
      ) {
        index = i;
        break;
      }
      unchecked {
        ++i;
      }
    }

    // Set this token's .staker to be address 0 to mark it as no longer staked
    stakers[msg.sender].stakedTokens[index] = stakers[msg.sender].stakedTokens[
      len - 1
    ];
    stakers[msg.sender].stakedTokens.pop();

    // Decrement the amount staked for this wallet
    stakers[msg.sender].amountStaked--;

    // Update the mapping of the tokenId to the be address(0) to indicate that the token is no longer staked
    stakerAddress[_tokenId] = address(0);

    // Transfer the token back to the withdrawer
    nftCollection.transferFrom(address(this), msg.sender, _tokenId);

    // Update the timeOfLastUpdate for the withdrawer
    stakers[msg.sender].timeOfLastUpdate = block.timestamp;
  }

  // Calculate rewards for the msg.sender, check if there are any rewards
  // claim, set unclaimedRewards to 0 and transfer the ERC20 Reward token
  // to the user.
  function claimRewards() external {
    uint256 rewards = calculateRewards(msg.sender) +
      stakers[msg.sender].unclaimedRewards;
    require(rewards > 0, "You have no rewards to claim");
    stakers[msg.sender].timeOfLastUpdate = block.timestamp;
    stakers[msg.sender].unclaimedRewards = 0;
    // rewardsToken.safeTransfer(msg.sender, rewards);
    rewardsToken.mint(msg.sender, rewards);
  }

  //////////
  // View //
  //////////

  function availableRewards(address _staker) public view returns (uint256) {
    uint256 rewards = calculateRewards(_staker) +
      stakers[_staker].unclaimedRewards;
    return rewards;
  }

  function getStakedTokens(address _user)
    public
    view
    returns (DataTypes.StakedToken[] memory)
  {
    // Check if we know this user
    if (stakers[_user].amountStaked > 0) {
      // Return all the tokens in the stakedToken Array for this user that are not -1
      DataTypes.StakedToken[]
        memory _stakedTokens = new DataTypes.StakedToken[](
          stakers[_user].amountStaked
        );
      uint256 _index = 0;

      for (uint256 j = 0; j < stakers[_user].stakedTokens.length; j++) {
        if (stakers[_user].stakedTokens[j].staker != (address(0))) {
          _stakedTokens[_index] = stakers[_user].stakedTokens[j];
          _index++;
        }
      }

      return _stakedTokens;
    }
    // Otherwise, return empty array
    else {
      return new DataTypes.StakedToken[](0);
    }
  }

  /////////////
  // Internal//
  /////////////

  // Calculate rewards for param _staker by calculating the time passed
  // since last update in hours and mulitplying it to ERC721 Tokens Staked
  // and rewardsPerHour.
  function calculateRewards(address _staker)
    internal
    view
    returns (uint256 _rewards)
  {
    return (((
      ((block.timestamp - stakers[_staker].timeOfLastUpdate) *
        stakers[_staker].amountStaked)
    ) * rewardsPerHour) / 3600);
  }
}
