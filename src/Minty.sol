// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

//interfaces

//libraries
import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";

//contracts
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract Minty is ERC721URIStorage {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  //types (variables, structs, enums)
  //state (mappings, arrays)
  //modifier
  //fallback

  constructor() ERC721("Minty", "MINTY") {}

  //functions
  function mint(address to, string memory metadataURI)
    external
    returns (uint256)
  {
    _tokenIds.increment();

    uint256 id = _tokenIds.current();
    _safeMint(to, id);
    _setTokenURI(id, metadataURI);

    return id;
  }

  function _baseURI() internal pure override returns (string memory) {
    return "ipfs://";
  }
}
