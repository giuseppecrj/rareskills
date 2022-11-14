// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.17;

import {console} from "forge-std/console.sol";
import {TokenWithGodMode} from "./TokenWithGodMode.sol";
import "openzeppelin-contracts/utils/math/SafeMath.sol";

contract TokenWithSale is TokenWithGodMode {
  uint256 internal _tokensPerEth = 10_000;

  constructor(string memory name, string memory symbol)
    TokenWithGodMode(name, symbol)
  {
    _mint(address(this), 22_000_000 * 10**decimals());
  }

  function buyTokens() external payable returns (uint256 tokenAmount) {
    require(msg.value > 0, "TokenWithSale: incorrect amount");

    tokenAmount = msg.value * _tokensPerEth;

    require(
      tokenAmount <= balanceOf(address(this)),
      "TokenWithSale: not enough tokens"
    );

    _transfer(address(this), msg.sender, tokenAmount);
  }

  function sellTokens(uint256 tokenAmount) external {
    require(tokenAmount > 0, "TokenWithSale: incorrect amount");

    uint256 ethAmount = ((tokenAmount / _tokensPerEth) / 100) * 90;

    require(
      address(this).balance >= ethAmount,
      "TokenWithSale: not enough ether"
    );

    _transfer(msg.sender, address(this), tokenAmount);

    // solhint-disable-next-line avoid-low-level-calls
    (bool sent, ) = msg.sender.call{value: ethAmount}("");
    require(sent, "TokenWithSale: failed to send");
  }

  function withdraw() external onlyOwner {
    // solhint-disable-next-line avoid-low-level-calls
    (bool sent, ) = msg.sender.call{value: address(this).balance}("");
    require(sent, "TokenWithSale: failed to send");
  }
}
