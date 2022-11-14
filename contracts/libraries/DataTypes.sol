// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.17;

library DataTypes {
  struct StakedToken {
    address staker;
    uint256 tokenId;
  }

  // Staker info
  struct Staker {
    // Amount of tokens staked by the staker
    uint256 amountStaked;
    // Staked token ids
    StakedToken[] stakedTokens;
    // Last time of the rewards were calculated for this user
    uint256 timeOfLastUpdate;
    // Calculated, but unclaimed rewards for the User. The rewards are
    // calculated each time the user writes to the Smart Contract
    uint256 unclaimedRewards;
  }
}
