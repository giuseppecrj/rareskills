// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import {CoreVoting} from "../../src/CoreVoting.sol";
import {DataTypes} from "../../src/libraries/DataTypes.sol";

contract TestCoreVoting is CoreVoting {
  // public dummy value used to test calldata calls
  uint256 public dummyValue;

  constructor(
    address _timelock,
    uint256 _baseQuorum,
    uint256 _minProposalPower,
    address _gsc,
    address[] memory votingVaults
  ) CoreVoting(_timelock, _baseQuorum, _minProposalPower, _gsc, votingVaults) {}

  function getProposalData(uint256 _proposalId)
    public
    view
    returns (DataTypes.Proposal memory)
  {
    return proposals[_proposalId];
  }

  function updateDummy(uint256 _newValue) public {
    dummyValue = _newValue;
  }

  function getVaultStatus(address _vault) public view returns (bool) {
    return approvedVaults[_vault];
  }

  function getCustomQuorum(address _target, bytes4 _selector)
    public
    view
    returns (uint256)
  {
    return quorums(_target, _selector);
  }
}
