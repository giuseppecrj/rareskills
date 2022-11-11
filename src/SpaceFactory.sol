// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {Space} from "./Space.sol";

contract SpaceFactory {
  uint256 internal _spaceCounter;
  address public immutable spaceImplementation;

  mapping(uint256 => address) public _spaceById;

  constructor(address _spaceImplementation) {
    spaceImplementation = _spaceImplementation;
  }

  function createSpace(string memory _name) public returns (address) {
    address space = address(
      new ERC1967Proxy(
        spaceImplementation,
        abi.encodeWithSignature("initialize(string)", _name)
      )
    );

    _spaceById[_spaceCounter] = space;
    _spaceCounter++;

    return space;
  }

  function upgradeSpace(address _space, address _newImplementation) public {
    Space(_space).upgradeTo(_newImplementation);
  }
}
