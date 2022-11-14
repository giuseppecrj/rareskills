// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Space} from "src/Space.sol";
import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";

contract SpaceFactory is Ownable {
  mapping(uint256 => address) internal _spaceById;
  mapping(bytes32 => uint256) internal _spaceIdByHash;

  uint256 internal _spaceId;

  address public spaceImplementation;

  constructor(address _spaceImplementation) {
    spaceImplementation = _spaceImplementation;
  }

  struct CreateSpaceData {
    string spaceName;
    string spaceNetworkId;
  }

  function createSpace(
    CreateSpaceData calldata info
  ) external returns (address) {
    ++_spaceId;

    bytes32 networkHash = keccak256(abi.encodePacked(info.spaceNetworkId));
    require(_spaceIdByHash[networkHash] != 0, "");

    address space = address(
      new ERC1967Proxy(
        spaceImplementation,
        abi.encodeWithSignature(
          "initialize(string,uint256)",
          info.spaceName,
          info.spaceNetworkId
        )
      )
    );

    _spaceById[_spaceId] = space;
    _spaceIdByHash[networkHash] = _spaceId;

    return space;
  }

  function setImplementation(address _spaceImplementation) external onlyOwner {
    spaceImplementation = _spaceImplementation;
  }

  function upgradeSpace(address _space, address _newImplementation) public {
    Space(_space).upgradeTo(_newImplementation);
  }
}
