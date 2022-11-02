// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import {Governor} from "openzeppelin-contracts/governance/Governor.sol";
import {GovernorVotes} from "openzeppelin-contracts/governance/extensions/GovernorVotes.sol";
import {GovernorCountingSimple} from "openzeppelin-contracts/governance/extensions/GovernorCountingSimple.sol";
import {GovernorTimelockControl} from "openzeppelin-contracts/governance/extensions/GovernorTimelockControl.sol";
import {GovernorVotesQuorumFraction} from "openzeppelin-contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import {IVotes} from "openzeppelin-contracts/governance/utils/IVotes.sol";
import {TimelockController} from "openzeppelin-contracts/governance/TimelockController.sol";

contract GovernorContract is
  Governor,
  GovernorVotes,
  GovernorCountingSimple,
  GovernorTimelockControl,
  GovernorVotesQuorumFraction
{
  uint256 public s_votingDelay;
  uint256 public s_votingPeriod;

  constructor(
    IVotes token_,
    TimelockController timelock_,
    uint256 votingDelay_,
    uint256 votingPeriod_,
    uint256 quorumNumerator_
  )
    Governor("Governor")
    GovernorVotes(token_)
    GovernorTimelockControl(timelock_)
    GovernorVotesQuorumFraction(quorumNumerator_)
  {
    s_votingDelay = votingDelay_;
    s_votingPeriod = votingPeriod_;
  }
}
