// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.17;

import {console} from "forge-std/console.sol";
import {IERC721Enumerable} from "openzeppelin-contracts/token/ERC721/extensions/IERC721Enumerable.sol";

contract Collection {
  IERC721Enumerable public nft;

  constructor(IERC721Enumerable _nft) {
    nft = _nft;
  }

  function getPrimeTokenIdCount(address owner) public view returns (uint256) {
    uint256 count;

    uint256 balance = nft.balanceOf(owner);

    for (uint256 i = 0; i < balance; i++) {
      uint256 _tokenId = nft.tokenOfOwnerByIndex(owner, i);
      if (isPrime(_tokenId)) count++;
    }

    return count;
  }

  function isPrime(uint256 n) private pure returns (bool) {
    if (n == 0 || n == 1) return false;

    for (uint256 i = 2; i < n; i++) {
      if (n % i == 0) {
        return false;
      }
    }

    return true;
  }
}
