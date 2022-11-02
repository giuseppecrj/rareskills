// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import {TimelockController} from "openzeppelin-contracts/governance/TimelockController.sol";

contract GovernanceTimeLock is TimelockController {
  constructor(
    uint256 minDelay,
    address[] memory proposers,
    address[] memory executors
  ) TimelockController(minDelay, proposers, executors, address(0)) {}
}
