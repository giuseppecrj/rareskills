// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import {Initializable} from "openzeppelin-contracts-upgradeable/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "openzeppelin-contracts-upgradeable/access/OwnableUpgradeable.sol";
import {UUPSUpgradeable} from "openzeppelin-contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract Space is Initializable, UUPSUpgradeable, OwnableUpgradeable {
  string public name;
  uint256 public networkId;

  function initialize(
    string memory _name,
    uint256 _networkId
  ) public initializer {
    __Ownable_init();
    __UUPSUpgradeable_init();

    name = _name;
    networkId = _networkId;
  }

  function _authorizeUpgrade(address) internal override onlyOwner {}
}
