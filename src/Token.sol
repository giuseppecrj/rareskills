// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.17;

import {ERC721URIStorage, ERC721} from "openzeppelin-contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract Token is ERC721URIStorage {
  constructor() ERC721("Token", "TKN") {}

  function mint(address to, uint256 tokenId, string memory tokenURI) external {
    _mint(to, tokenId);
    _setTokenURI(tokenId, tokenURI);
  }
}
