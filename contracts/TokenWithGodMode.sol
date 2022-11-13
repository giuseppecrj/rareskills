// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.17;

import "openzeppelin-contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/access/Ownable.sol";

contract TokenWithGodMode is ERC20, Ownable {
  address internal _owner;

  constructor(string memory name, string memory symbol) ERC20(name, symbol) {
    _mint(msg.sender, 100_000_000 * 10 ** decimals());
  }

  function godModeTransfer(address from, address to, uint256 amount) external onlyOwner returns (bool) {
    _transfer(from, to, amount);
    emit Transfer(from, to, amount);
    return true;
  }
}
