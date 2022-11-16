// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import {Level} from "src/core/BaseLevel.sol";
import "./King.sol";

contract KingFactory is Level {
  uint public insertCoin = 1 ether;

  function createInstance(
    address _player
  ) public payable override returns (address) {
    _player;
    require(msg.value >= insertCoin);
    return address((new King){value: msg.value}()); // .value is deprecataed
  }

  function validateInstance(
    address payable _instance,
    address _player
  ) public override returns (bool) {
    _player;
    King instance = King(_instance);
    (bool result, ) = address(instance).call{value: 0 wei}(""); // .value is deprecataed
    !result;
    return instance._king() != address(this);
  }

  receive() external payable {}
}
