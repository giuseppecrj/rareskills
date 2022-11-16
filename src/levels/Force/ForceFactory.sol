// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import {Level} from "src/core/BaseLevel.sol";
import "./Force.sol";

contract ForceFactory is Level {
  function createInstance(
    address _player
  ) public payable override returns (address) {
    _player;
    return address(new Force());
  }

  function validateInstance(
    address payable _instance,
    address _player
  ) public override returns (bool) {
    _player;
    Force instance = Force(_instance);
    return address(instance).balance > 0;
  }
}
