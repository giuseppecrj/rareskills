// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import {ERC20} from "solmate/tokens/ERC20.sol";

contract Token is ERC20 {
  constructor() ERC20("Token Sale", "TS", 18) {
    _mint(msg.sender, 22_000_000 * 10**uint256(decimals));
  }
}
