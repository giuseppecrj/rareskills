// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import {console} from "forge-std/console.sol";
import "council/interfaces/IVotingVault.sol";

contract MockVotingVault is IVotingVault {
  // address => votingPower
  mapping(address => uint256) public votingPower;

  function setVotingPower(address _user, uint256 _votingPower) external {
    votingPower[_user] = _votingPower;
  }

  function queryVotePower(address _user, uint256 _blockNumber, bytes calldata)
    public
    view
    returns (uint256)
  {
    _blockNumber;
    return votingPower[_user];
  }
}
