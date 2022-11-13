// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.17;

import "openzeppelin-contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/access/Ownable.sol";

contract TokenWithSanctions is ERC20, Ownable {
  mapping(address => bool) internal _bannedByAccount;

  constructor(string memory name, string memory symbol) ERC20(name, symbol) {
    _mint(msg.sender, 100_000_000 * 10 ** decimals());
  }

  function _beforeTokenTransfer(address from, address to, uint256) internal view override {
    require(!_bannedByAccount[from], "TokenWithSanctions: account is banned");
    require(!_bannedByAccount[to], "TokenWithSanctions: account is banned");
  }

  function setBan(address account, bool ban) external onlyOwner {
    _bannedByAccount[account] = ban;
  }
}
