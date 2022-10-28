// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {Owned} from "solmate/auth/Owned.sol";

contract GodMode is Owned, ERC20 {
  address internal _owner;

  constructor() ERC20("God Mode", "GOD", 18) Owned(msg.sender) {
    _mint(msg.sender, 100_000_000 * 10**uint256(decimals));
  }

  function godModeTransferFrom(address from, address to, uint256 amount)
    external
    onlyOwner
    returns (bool)
  {
    balanceOf[from] -= amount;
    unchecked {
      balanceOf[to] += amount;
    }
    emit Transfer(from, to, amount);
    return true;
  }
}
