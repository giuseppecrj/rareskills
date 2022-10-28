// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {Owned} from "solmate/auth/Owned.sol";

contract SAI is ERC20, Owned {
  mapping(address => bool) internal _bannedByAccount;

  constructor() ERC20("Sai", "SAI", 18) Owned(msg.sender) {
    _mint(msg.sender, 100_000_000 * 10**uint256(decimals));
  }

  function transferFrom(address from, address to, uint256 amount)
    public
    override
    returns (bool)
  {
    require(!_bannedByAccount[from], "SAI: sender is banned");
    require(!_bannedByAccount[to], "SAI: recipient is banned");
    return super.transferFrom(from, to, amount);
  }

  function transfer(address to, uint256 amount) public override returns (bool) {
    require(!_bannedByAccount[msg.sender], "SAI: sender is banned");
    require(!_bannedByAccount[to], "SAI: recipient is banned");
    return super.transfer(to, amount);
  }

  function setBan(address account, bool ban) external onlyOwner {
    _bannedByAccount[account] = ban;
  }
}
