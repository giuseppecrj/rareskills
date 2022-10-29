// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import {console} from "forge-std/console.sol";
import "./Token.sol";
import "openzeppelin-contracts/utils/math/SafeMath.sol";

contract TokenWithBondingCurve is Token {
  using SafeMath for uint256;

  uint256 internal poolBalance;
  uint256 internal scale = 1e18;
  uint256 internal fees;

  constructor(string memory name, string memory symbol) Token(name, symbol) {
    _mint(address(this), 100_000_000 * scale);
    poolBalance = totalSupply();
  }

  function buyTokens() external payable returns (uint256 tokenAmount) {
    require(msg.value > 0, "TokenWithBondingCurve: incorrect amount");

    _mint(address(this), msg.value);
    tokenAmount = msg.value.mul(totalSupply()).div(poolBalance);

    require(
      tokenAmount <= balanceOf(address(this)),
      "TokenWithBondingCurve: not enough tokens"
    );

    _transfer(address(this), msg.sender, tokenAmount);
  }

  function sellTokens(uint256 tokenAmount) external {
    require(tokenAmount > 0, "TokenWithBondingCurve: incorrect amount");
    require(
      balanceOf(msg.sender) >= tokenAmount,
      "TokenWithBondingCurve: not enough tokens"
    );

    uint256 ethAmount = tokenAmount.div(totalSupply()).div(100).mul(90);
    uint256 ethFee = tokenAmount.div(totalSupply()).div(100).mul(10);

    fees = fees.add(ethFee);

    require(
      address(this).balance >= ethAmount,
      "TokenWithBondingCurve: not enough ether"
    );

    _transfer(msg.sender, address(this), tokenAmount);
    _burn(address(this), tokenAmount);

    // solhint-disable-next-line avoid-low-level-calls
    (bool sent, ) = msg.sender.call{value: ethAmount}("");
    require(sent, "TokenWithBondingCurve: failed to send");
  }

  function withdraw() external onlyOwner {
    // solhint-disable-next-line avoid-low-level-calls
    (bool sent, ) = msg.sender.call{value: fees}("");
    require(sent, "TokenWithBondingCurve: failed to send");
  }
}
