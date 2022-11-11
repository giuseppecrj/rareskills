// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.17;

import "forge-std/Test.sol";

import {TestCoreVoting} from "./mocks/TestCoreVoting.sol";
import {MockVotingVault} from "./mocks/MockVotingVault.sol";
import {DataTypes} from "../src/libraries/DataTypes.sol";

contract CoreVotingTest is Test {
  TestCoreVoting internal coreVoting;
  address[] internal votingVaults;
  bytes[] internal zeroExtraData = new bytes[](3);
  uint256 internal max = type(uint256).max;
  uint256 internal baseVotingPower = 10;

  function setUp() public {
    zeroExtraData[0] = "";
    zeroExtraData[1] = "";
    zeroExtraData[2] = "";

    for (uint256 i = 0; i < 3; i++) {
      MockVotingVault votingVault = new MockVotingVault();
      votingVault.setVotingPower(address(0), baseVotingPower);
      votingVault.setVotingPower(address(1), baseVotingPower);
      votingVault.setVotingPower(address(2), baseVotingPower);
      votingVaults.push(address(votingVault));
    }

    coreVoting = new TestCoreVoting(
      address(this),
      0,
      0,
      address(0),
      votingVaults
    );
    coreVoting.setLockDuration(0);
    coreVoting.changeExtraVotingTime(500);

    vm.roll(2);
  }

  function testCreateProposal() public {
    address[] memory targets = new address[](2);
    targets[0] = address(0);
    targets[1] = address(1);

    bytes[] memory calldatas = new bytes[](2);
    calldatas[0] = "0x12345678ffffffff";
    calldatas[1] = "0x12345678ffffffff";

    vm.prank(address(0));
    coreVoting.proposal(
      votingVaults,
      zeroExtraData,
      targets,
      calldatas,
      max,
      DataTypes.Ballot.YES
    );

    DataTypes.Proposal memory proposal = coreVoting.getProposalData(0);

    assertEq(proposal.created, block.number - 1);
    assertEq(proposal.unlock, block.number);
  }
}
