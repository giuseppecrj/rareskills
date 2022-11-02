// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.17;

import "openzeppelin-contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/access/Ownable.sol";
import "openzeppelin-contracts/utils/Strings.sol";

contract NFT is ERC721("Rareskill", "RARE"), Ownable {
  using Strings for uint256;

  uint256 public tokenSupply;
  uint256 public constant MAX_SUPPLY = 10;

  function mint(address to) external payable {
    require(tokenSupply < MAX_SUPPLY, "Max supply reached");
    require(msg.value >= 0.1 ether, "Not enough ETH");

    _safeMint(to, tokenSupply);
    tokenSupply++;
  }

  function burn(uint256 tokenId) external {
    require(
      _isApprovedOrOwner(_msgSender(), tokenId),
      "Caller is not owner nor approved"
    );
    _burn(tokenId);
  }

  function tokenURI(uint256 tokenId)
    public
    view
    override
    returns (string memory)
  {
    _requireMinted(tokenId);
    return
      string(
        abi.encodePacked(
          "ipfs://bafybeiejf7vk35dcczls4eeg7m42hxpvhp2qmiktsowxkpvr5tm74b3yxq/",
          tokenId.toString(),
          ".json"
        )
      );
  }

  function withdraw() external onlyOwner {
    // solhint-disable-next-line avoid-low-level-calls
    (bool sent, ) = owner().call{value: address(this).balance}("");
    require(sent, "Failed to send Ether");
  }
}
