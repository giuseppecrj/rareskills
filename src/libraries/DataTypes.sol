// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

library DataTypes {
  enum Ballot {
    YES,
    NO,
    MAYBE
  }

  struct Proposal {
    // has of proposal function calls
    bytes32 proposalHash;
    // block of the proposal creation
    uint128 created;
    // timestamp when the proposal can execute
    uint128 unlock;
    // expiration time of a proposal
    uint128 expiration;
    // the quorom required to pass the proposal
    uint128 quorum;
    // [yes, no, maybe] voting power
    uint128[3] votingPower;
    // timestamp after which if the call has not been executed it cannot be executed
    uint128 lastCall;
  }

  struct Vote {
    // the voting power of the voter
    uint128 votingPower;
    // the ballot cast by the voter
    Ballot castBallot;
  }
}
