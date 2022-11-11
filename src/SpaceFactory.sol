// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import {Clones} from "openzeppelin-contracts/proxy/Clones.sol";
import {Space} from "./Space.sol";

contract SpaceFactory {
  uint256 internal _spaceCounter;
  address public spaceImplementation;

  mapping(uint256 => address) public spaceById;

  constructor(address _spaceImplementation) {
    spaceImplementation = _spaceImplementation;
  }

  function createSpace(string memory _name) public returns (address) {
    address space = Clones.clone(spaceImplementation);
    Space(space).initialize(_name);

    spaceById[_spaceCounter] = space;
    _spaceCounter++;

    return space;
  }
}
