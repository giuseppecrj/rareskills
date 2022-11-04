// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import {DataTypes} from "./DataTypes.sol";

library Events {
  event ProposalCreated(
    uint256 proposalId,
    uint256 created,
    uint256 execution,
    uint256 expiration
  );

  event ProposalExecuted(uint256 proposalId);

  event Voted(
    address indexed voter,
    uint256 indexed proposalId,
    DataTypes.Vote vote
  );
}
