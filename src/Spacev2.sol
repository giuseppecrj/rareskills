// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import {Initializable} from "openzeppelin-contracts-upgradeable/proxy/utils/Initializable.sol";
import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";

contract Spacev2 is Initializable, Ownable {
  string public name;

  function initialize(string memory _name) public initializer {
    name = _name;
  }

  function setName(string memory _name) public onlyOwner {
    name = _name;
  }
}
