// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.17;

import "openzeppelin-contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/access/Ownable.sol";

/** eslint-disable-next-line no-empty-blocks */
contract Token is ERC20("RareSkills", "RR"), Ownable {
  function mint(address to, uint256 amount) external onlyOwner {
    _mint(to, amount);
  }
}
