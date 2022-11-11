// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import {Initializable} from "openzeppelin-contracts-upgradeable/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "openzeppelin-contracts-upgradeable/access/OwnableUpgradeable.sol";

contract Space is Initializable, OwnableUpgradeable {
  string public name;

  function initialize(string memory _name) public initializer {
    __Ownable_init();

    name = _name;
  }
}
