// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import {ERC721} from "src/ERC721.sol";

contract MintVouchers is ERC721 {
  address payable public immutable owner;
  mapping(bytes32 => bool) public isCancelled;

  bytes32 public immutable DOMAIN_HASH;
  bytes32 public constant VOUCHER_TYPE_HASH =
    keccak256("MintVoucher(uint256 tokenId,uint256 price)");

  constructor() {
    owner = payable(msg.sender);
    DOMAIN_HASH = keccak256(
      abi.encode(
        keccak256(
          "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        ),
        keccak256("MintVouchersERC721"),
        keccak256("1.0.0"),
        block.chainid,
        address(this)
      )
    );
  }

  function mint(
    uint256 tokenId,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external payable {
    // compute the eip712 hash of the voucher
    bytes32 voucherHash = _getVoucherHash(tokenId, msg.value);

    // Make sure the voucher hasn't been cancelled
    require(!isCancelled[voucherHash], "mint voucher has been cancelled");

    // Ensure that the owner signed the voucher
    require(ecrecover(voucherHash, v, r, s) == owner, "invalid signature");

    // No need to check price because if msg.value is not the price in the message
    // the owner signed, the hash would be different and the signature check would fail
    _safeMint(tokenId, msg.sender); // Mint an NFT. Fails if already minted
    owner.transfer(msg.value); // Pay the owner
  }

  function cancel(uint256 tokenId, uint256 price) external {
    require(msg.sender == owner, "only owner");
    isCancelled[_getVoucherHash(tokenId, price)] = true;
  }

  function _getVoucherHash(
    uint256 tokenId,
    uint256 price
  ) internal view returns (bytes32) {
    bytes32 structHash = keccak256(
      abi.encode(VOUCHER_TYPE_HASH, tokenId, price)
    );

    return keccak256(abi.encodePacked("\x19\x01", DOMAIN_HASH, structHash));
  }
}
