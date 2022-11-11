// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import {console} from "forge-std/console.sol";
import {ICoreVoting} from "council/interfaces/ICoreVoting.sol";
import {Authorizable} from "council/libraries/Authorizable.sol";
import {ReentrancyBlock} from "council/libraries/ReentrancyBlock.sol";

import {IVotingVault} from "council/interfaces/IVotingVault.sol";

import {DataTypes} from "./libraries/DataTypes.sol";
import {Events} from "./libraries/Events.sol";

contract CoreVoting is Authorizable, ReentrancyBlock, ICoreVoting {
  // If function selector does not have a base qurom, it will use this value
  uint256 public baseQuorum;

  // Assumes avg block time of 13.3 seconds
  uint256 public constant DAY_IN_BLOCKS = 7000;

  // Minimum time a proposal must be active before execution
  // Default to 3 days, this avoids weekend proposals
  uint256 public lockDuration = DAY_IN_BLOCKS * 3;

  // The number of blocks after a proposal is unlocked during which voting can continue
  // Max vote time = lockDuration + extraVoteTime
  // Default ~5 days of blocks
  uint256 public extraVoteTime = DAY_IN_BLOCKS * 5;

  // minimum amount of voting power require to submit a proposal
  uint256 public minProposalPower;

  // number of proposals created
  uint256 public proposalCount;

  // mapping of address and selector to quorum
  mapping(address => mapping(bytes4 => uint256)) public _quorums;

  // mapping of approved voting vaults
  mapping(address => bool) public approvedVaults;

  // mapping of proposalId to proposal
  mapping(uint256 => DataTypes.Proposal) public proposals;

  // mapping of address and proposal ids to vote struct representing
  // the voting actions taken for each proposal
  mapping(address => mapping(uint256 => DataTypes.Vote)) public votes;

  /// @notice constructor
  /// @param _timelock Timelock contract
  /// @param _baseQuorum Default quorum for proposals with no quorum set
  /// @param _minProposalPower Minimum voting power required to submit a proposal
  /// @param _gsc governance steering committee contract
  /// @param _votingVaults list of approved voting vaults
  constructor(
    address _timelock,
    uint256 _baseQuorum,
    uint256 _minProposalPower,
    address _gsc,
    address[] memory _votingVaults
  ) {
    baseQuorum = _baseQuorum;
    minProposalPower = _minProposalPower;

    for (uint256 i = 0; i < _votingVaults.length; i++) {
      approvedVaults[_votingVaults[i]] = true;
    }

    setOwner(_timelock);
    _authorize(_gsc);
  }

  /// @notice Override of the getter for the quoroms mapping which returns the default quorum
  /// if the selector is not found
  /// @param target The address of the contract
  /// @param functionSelector The function which is callable
  /// @return The quorum needed to pass the function at this point in time
  function quorums(address target, bytes4 functionSelector)
    public
    view
    returns (uint256)
  {
    return
      _quorums[target][functionSelector] == 0
        ? baseQuorum
        : _quorums[target][functionSelector];
  }

  /// @notice Create a new proposal
  /// @dev all provided voting vaults must be approved `approvedVaults`
  /// @param votingVaults list of voting vaults to use for voting power
  /// @param extraVaultData an encoded list of extra data to provide to vaults
  /// @param targets list of targets the timelock contract will interact with
  /// @param calldatas execution calldata for each target
  /// @param lastCall timestamp after which if the call has not been executed it cannot be executed
  ///        should be more the voting time period
  /// @param ballot vote direction (yes, no, maybe)
  function proposal(
    address[] calldata votingVaults,
    bytes[] calldata extraVaultData,
    address[] calldata targets,
    bytes[] calldata calldatas,
    uint256 lastCall,
    DataTypes.Ballot ballot
  ) external {
    require(targets.length == calldatas.length, "CoreVoting: length mismatch");
    require(targets.length != 0, "CoreVoting: empty proposal");

    // the hash is only used to verify the proposal data, proposals are tracked by ID
    // so there is no need to hash with proposalCount nonce.
    bytes32 proposalHash = keccak256(abi.encode(targets, calldatas));

    // get the quorum requirement for this proposal. The quorum requirement is equal to
    // the greatest quorum item in the proposal
    uint256 qurom;
    for (uint256 i = 0; i < targets.length; ) {
      // function selector should be the first 4 bytes of calldata
      bytes4 selector = _getSelector(calldatas[i]);
      uint256 unitQuorum = _quorums[targets[i]][selector];

      // don't assum base Quorum is the highest
      unitQuorum = unitQuorum == 0 ? baseQuorum : unitQuorum;
      if (unitQuorum > qurom) {
        qurom = unitQuorum;
      }

      unchecked {
        ++i;
      }
    }

    // check expiration
    require(
      lastCall > block.number + lockDuration + extraVoteTime,
      "CoreVoting: expires before ends"
    );

    // create the proposal
    proposals[proposalCount] = DataTypes.Proposal({
      proposalHash: proposalHash,
      // we use block number - 1 here as a flashloan mitigation
      created: uint128(block.number - 1),
      unlock: uint128(block.number + lockDuration),
      expiration: uint128(block.number + lockDuration + extraVoteTime),
      quorum: uint128(qurom),
      votingPower: proposals[proposalCount].votingPower,
      lastCall: uint128(lastCall)
    });

    // get the voting power for the proposal
    uint256 votingPower = vote(
      votingVaults,
      extraVaultData,
      proposalCount,
      ballot
    );

    // the proposal quorum is the lowest of minProposalPower and the proposal quorum
    // because it is awkward for the proposal to require more voting power than the execution
    uint256 minPower = qurom <= minProposalPower ? qurom : minProposalPower;

    // the GSC contract does not have a voting power requirement to submit a proposal
    if (!isAuthorized(msg.sender)) {
      require(votingPower >= minPower, "CoreVoting: insufficient power");
    }

    emit Events.ProposalCreated(
      proposalCount,
      block.number,
      block.number + lockDuration,
      block.number + lockDuration + extraVoteTime
    );

    unchecked {
      ++proposalCount;
    }
  }

  /// @notice Vote on a proposal
  /// @dev all provided voting vaults must be approved `approvedVaults`.
  /// Addresses can revote but the previous vote will be overwritten.
  /// @param votingVaults voting vaults to draw voting power from
  /// @param extraVaultData an encoded list of extra data to provide to vaults
  /// @param proposalId proposal to vote on
  /// @param ballot vote direction (yes, no, maybe)
  /// @return votingPower voting power used to vote
  function vote(
    address[] memory votingVaults,
    bytes[] memory extraVaultData,
    uint256 proposalId,
    DataTypes.Ballot ballot
  ) public returns (uint256) {
    require(
      votingVaults.length == extraVaultData.length,
      "CoreVoting: length mismatch"
    );

    require(
      proposals[proposalId].created != 0,
      "CoreVoting: proposal not exists"
    );

    require(
      block.number <= proposals[proposalId].expiration,
      "CoreVoting: proposal expired"
    );

    uint128 votingPower;

    for (uint256 i = 0; i < votingVaults.length; ) {
      for (uint256 j = i + 1; j < votingVaults.length; ) {
        require(
          votingVaults[i] != votingVaults[j],
          "CoreVoting: duplicate vault"
        );
        unchecked {
          ++j;
        }
      }

      require(
        approvedVaults[votingVaults[i]],
        "CoreVoting: vault not approved"
      );

      votingPower += uint128(
        IVotingVault(votingVaults[i]).queryVotePower(
          msg.sender,
          proposals[proposalId].created,
          extraVaultData[i]
        )
      );

      unchecked {
        ++i;
      }
    }

    // if a user has already voted, undo the previous vote
    // NOTE: A new vote can have less voting power
    if (votes[msg.sender][proposalId].votingPower > 0) {
      proposals[proposalId].votingPower[
        uint256(votes[msg.sender][proposalId].castBallot)
      ] -= votes[msg.sender][proposalId].votingPower;
    }

    // update the vote
    votes[msg.sender][proposalId] = DataTypes.Vote({
      votingPower: votingPower,
      castBallot: ballot
    });

    // update the proposal
    proposals[proposalId].votingPower[uint256(ballot)] += votingPower;

    // emit the event
    emit Events.Voted(msg.sender, proposalId, votes[msg.sender][proposalId]);

    return votingPower;
  }

  /// @notice Execute a proposal
  /// @dev the proposal must be approved and the timelock must be expired
  /// @param proposalId proposal to execute
  /// @param targets list of targets the timelock contract will interact with
  /// @param calldatas execution calldata for each target
  function execute(
    uint256 proposalId,
    address[] calldata targets,
    bytes[] calldata calldatas
  ) external nonReentrant {
    // We have to execute after min voting period
    require(block.number >= proposals[proposalId].unlock, "CoreVoting: locked");

    // If executed the proposal will be deleted and this is zero
    require(
      proposals[proposalId].unlock == 0,
      "CoreVoting: previously executed"
    );

    // Check if proposal has expired
    require(
      block.number < proposals[proposalId].lastCall,
      "CoreVoting: proposal passed"
    );

    // Ensure the data matches the hash
    require(
      keccak256(abi.encode(targets, calldatas)) ==
        proposals[proposalId].proposalHash,
      "CoreVoting: invalid proposal"
    );

    uint128[3] memory results = proposals[proposalId].votingPower;

    // if there are enough votes to meet the quorum and there are more yes votes than no votes
    // execute the proposal
    bool passedQuorum = results[0] + results[1] + results[2] >=
      proposals[proposalId].quorum;
    bool majorityInFavor = results[0] > results[1];

    require(passedQuorum && majorityInFavor, "CoreVoting: not approved");

    // execute the proposal
    for (uint256 i = 0; i < targets.length; ) {
      (bool success, ) = targets[i].call(calldatas[i]);
      require(success, "CoreVoting: call failed");
      unchecked {
        ++i;
      }
    }

    // Notification of proposal execution
    emit Events.ProposalExecuted(proposalId);

    // Delete the proposal for some gas savings,
    // proposals are only deleted when they are actually executed, failed proposals
    // are never deleted
    delete proposals[proposalId];
  }

  /// @notice gets the current voting power for a proposal
  /// @param proposalId proposal to get voting power for
  /// @return voting power for the proposal
  function getProposalVotingPower(uint256 proposalId)
    external
    view
    returns (uint128[3] memory)
  {
    return proposals[proposalId].votingPower;
  }

  /// @notice sets a quorum for a specific address and selector
  /// @param target target contract
  /// @param selector function selector
  /// @param quorum quorum to set
  function setQuorum(address target, bytes4 selector, uint256 quorum)
    external
    onlyOwner
  {
    _quorums[target][selector] = quorum;
  }

  /// @notice Updates the satus of a voting vault
  /// @param vault voting vault to update
  /// @param isValid new status of the vault
  function changeVaultStatus(address vault, bool isValid) external onlyOwner {
    approvedVaults[vault] = isValid;
  }

  /// @notice Updates the default quorum
  /// @param quorum new default quorum
  function setDefaultQuorum(uint256 quorum) external onlyOwner {
    baseQuorum = quorum;
  }

  /// @notice Updates the minimum voting power needed to submit a proposal
  /// @param _minProposalPower new minimum proposal power
  function setMinProposalPower(uint256 _minProposalPower) external onlyOwner {
    minProposalPower = _minProposalPower;
  }

  /// @notice Updates the lock duration of a proposal
  /// @param _lockDuration new lock duration
  function setLockDuration(uint256 _lockDuration) external onlyOwner {
    lockDuration = _lockDuration;
  }

  /// @notice Updates the extra voting time
  /// @param _extraVoteTime new extra voting time
  function changeExtraVotingTime(uint256 _extraVoteTime) external onlyOwner {
    extraVoteTime = _extraVoteTime;
  }

  /// @notice Internal helper function to get the function selector of a calldata string
  /// @param _calldata The calldata string
  /// @return _out The function selector
  function _getSelector(bytes memory _calldata)
    internal
    pure
    returns (bytes4 _out)
  {
    // solhint-disable-next-line no-inline-assembly
    assembly {
      _out := and(
        mload(add(_calldata, 32)),
        0xFFFFFFFFF0000000000000000000000000000000000000000000000000000000
      )
    }
  }
}
