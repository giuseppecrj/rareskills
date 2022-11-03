// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "openzeppelin-contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/access/Ownable.sol";

/** eslint-disable-next-line no-empty-blocks */
contract Token is ERC20("RareSkills", "RR"), Ownable {
  constructor() {
    _mint(msg.sender, 100_000_000 * 10**decimals());
  }
}
