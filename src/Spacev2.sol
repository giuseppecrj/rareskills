// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import {Initializable} from "openzeppelin-contracts-upgradeable/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "openzeppelin-contracts-upgradeable/access/OwnableUpgradeable.sol";
import {UUPSUpgradeable} from "openzeppelin-contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract Spacev2 is Initializable, UUPSUpgradeable, OwnableUpgradeable {
  string public name;

  function initialize(string memory _name) public initializer {
    __Ownable_init();
    __UUPSUpgradeable_init();

    name = _name;
  }

  function _authorizeUpgrade(address) internal override onlyOwner {}

  function setName(string memory _name) public onlyOwner {
    name = _name;
  }
}
