// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import {Level} from "./BaseLevel.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";

contract Ethernaut is Ownable {
  error LevelNotFound();
  error InvalidValue();

  event LevelInstanceCreatedLog(address indexed player, address instance);
  event LevelCompletedLog(address indexed player, Level level);

  // instance data
  struct EmittedInstanceData {
    address player;
    Level level;
    bool completed;
  }

  // mapping of registered levels
  mapping(address => bool) public levels;

  // mapping of instances
  mapping(address => EmittedInstanceData) public instances;

  // Only registered levels will be allowed to generate and validate level instances
  function registerLevel(Level _level) public onlyOwner {
    levels[address(_level)] = true;
  }

  function createLevelInstance(Level _level) public payable returns (address) {
    if (!levels[address(_level)]) revert LevelNotFound();

    // create instance
    address instance = _level.createInstance{value: msg.value}(msg.sender);

    // store instance data
    instances[instance] = EmittedInstanceData({
      player: msg.sender,
      level: _level,
      completed: false
    });

    // emit event
    emit LevelInstanceCreatedLog(msg.sender, instance);

    return instance; // return instance address
  }

  function submitLevelInstance(
    address payable _instance
  ) public returns (bool) {
    // get player and level
    EmittedInstanceData storage instanceData = instances[_instance];

    // check player is sender
    if (instanceData.player != msg.sender) revert InvalidValue();

    // check not completed
    if (instanceData.completed) revert InvalidValue();

    // validate instance
    if (instanceData.level.validateInstance(_instance, msg.sender)) {
      // mark instance as completed
      instanceData.completed = true;

      // emit event
      emit LevelCompletedLog(msg.sender, instanceData.level);

      return true;
    }

    return false;
  }
}
