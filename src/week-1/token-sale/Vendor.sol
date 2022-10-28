// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import {console} from "forge-std/console.sol";
import {Token} from "./Token.sol";
import {Owned} from "solmate/auth/Owned.sol";

contract Vendor is Owned {
  Token public token;

  uint256 public tokensPerEth = 10_000;

  event TokensPurchased(
    address indexed buyer,
    uint256 amountEth,
    uint256 amountToken
  );

  constructor(address _token) Owned(msg.sender) {
    token = Token(_token);
  }

  function buyTokens() external payable returns (uint256 tokenAmount) {
    require(msg.value > 0, "Vendor: incorrect amount");

    tokenAmount = msg.value * tokensPerEth;

    require(
      tokenAmount <= token.balanceOf(address(this)),
      "Vendor: not enough tokens"
    );

    bool sent = token.transfer(msg.sender, tokenAmount);
    require(sent, "Vendor: failed to send tokens");
  }

  function sellTokens(uint256 tokenAmount) external {
    require(tokenAmount > 0, "Vendor: incorrect amount");

    uint256 ethAmount = tokenAmount / tokensPerEth;

    require(
      address(this).balance >= ethAmount,
      "Vendor: not enough ether to sell"
    );

    bool sent = token.transferFrom(msg.sender, address(this), tokenAmount);
    require(sent, "Vendor: failed to send tokens");

    // solhint-disable-next-line avoid-low-level-calls
    (sent, ) = msg.sender.call{value: ethAmount}("");
    require(sent, "Vendor: failed to send ether");
  }

  function withdraw() external onlyOwner {
    require(address(this).balance > 0, "Vendor: no funds to withdraw");

    // solhint-disable-next-line avoid-low-level-calls
    (bool sent, ) = msg.sender.call{value: address(this).balance}("");
    require(sent, "Vendor: failed to send ether");
  }
}
