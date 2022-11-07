// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.17;

import "openzeppelin-contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {Errors} from "./library/Errors.sol";

contract NFTEnumerable is ERC721Enumerable {
  uint256 public tokenCounter;
  uint256 public constant MAX_SUPPLY = 20;

  constructor() ERC721("Enumerable", "ENUM") {}

  function mint(address to) public {
    ++tokenCounter;

    if (tokenCounter > MAX_SUPPLY) revert Errors.MaxSupplyReached();

    _safeMint(to, tokenCounter);
  }
}
