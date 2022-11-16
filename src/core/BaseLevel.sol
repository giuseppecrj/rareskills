// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";

abstract contract Level is Ownable {
  function createInstance(
    address _player
  ) public payable virtual returns (address);

  function validateInstance(
    address payable _instance,
    address _player
  ) public virtual returns (bool);
}
