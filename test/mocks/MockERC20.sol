// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import {ERC20PermitWithMint} from "council/libraries/ERC20PermitWithMint.sol";

contract MockERC20 is ERC20PermitWithMint {
  constructor(
    string memory name_,
    string memory symbol_,
    address owner_
  ) ERC20PermitWithMint(name_, symbol_, owner_) {}

  function setBalance(address who, uint256 amount) external {
    balanceOf[who] = amount;
  }

  function setAllowance(
    address source,
    address spender,
    uint256 amount
  ) external {
    allowance[source][spender] = amount;
  }
}
