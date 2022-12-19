// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "../src/interfaces.sol";

contract ERC20 is IERC20 {
  mapping(address => uint256) public balanceOf;
  mapping(address => mapping(address => uint256)) public allowance;

  function transfer(address to, uint256 amount) external returns (bool) {
    transferFrom(msg.sender, to, amount);
    return true;
  }

  function transferFrom(
    address owner,
    address to,
    uint256 amount
  ) public returns (bool) {
    if (msg.sender != owner) {
      allowance[owner][msg.sender] -= amount;
    }
    balanceOf[owner] -= amount;
    balanceOf[to] += amount;
    return true;
  }

  function approve(
    address spender,
    uint256 allowance_
  ) external returns (bool) {
    allowance[msg.sender][spender] = allowance_;
    return true;
  }
}

contract WETH is IWETH, ERC20 {
  function deposit() external payable {
    balanceOf[msg.sender] += msg.value;
  }

  function withdraw(uint256 amt) external {
    balanceOf[msg.sender] -= amt;
    (bool s, bytes memory r) = payable(msg.sender).call{value: amt}("");
    if (!s) {
      assembly {
        revert(add(r, 0x20), mload(r))
      }
    }
  }
}
