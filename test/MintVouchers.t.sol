// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import {TestUtils} from "test/TestUtils.sol";
import {MintVouchers} from "src/MintVouchers.sol";

contract TestableMintVouchersERC721 is MintVouchers {
  function getVoucherHash(
    uint256 tokenId,
    uint256 price
  ) external view returns (bytes32) {
    return _getVoucherHash(tokenId, price);
  }
}

contract MintVouchersTest is TestUtils {
  event Transfer(
    address indexed from,
    address indexed to,
    uint256 indexed tokenId
  );

  uint256 internal ownerPrivateKey;
  address payable internal owner;
  address payable internal minter;
  TestableMintVouchersERC721 internal nftContract;

  function setUp() external {
    ownerPrivateKey = _randomUint256();
    minter = _randomAddress();
    owner = payable(vm.addr(ownerPrivateKey));

    vm.prank(owner);
    nftContract = new TestableMintVouchersERC721();
    vm.deal(minter, 1e18);
  }

  function testCannotMintWithWrongPrice() external {
    uint256 tokenId = _randomUint256();
    uint256 price = _randomUint256() % 100;

    (uint8 v, bytes32 r, bytes32 s) = _signVoucher(tokenId, price);
    vm.expectRevert("invalid signature");
    vm.prank(minter);
    nftContract.mint{value: price + 1}(tokenId, v, r, s);
  }

  function testCannotMintWithWrongTokenId() external {
    uint256 tokenId = _randomUint256();
    uint256 price = _randomUint256() % 100;

    (uint8 v, bytes32 r, bytes32 s) = _signVoucher(tokenId, price);
    vm.expectRevert("invalid signature");
    vm.prank(minter);
    nftContract.mint{value: price}(tokenId + 1, v, r, s);
  }

  function testCanMint() external {
    uint256 tokenId = _randomUint256();
    uint256 price = _randomUint256() % 100;

    (uint8 v, bytes32 r, bytes32 s) = _signVoucher(tokenId, price);
    vm.expectEmit(true, true, true, false);
    emit Transfer(address(0), minter, tokenId);
    vm.prank(minter);
    nftContract.mint{value: price}(tokenId, v, r, s);
    assertEq(owner.balance, price);
  }

  function testCannotMintTwice() external {
    uint256 tokenId = _randomUint256();
    uint256 price = _randomUint256() % 100;

    (uint8 v, bytes32 r, bytes32 s) = _signVoucher(tokenId, price);
    vm.prank(minter);
    nftContract.mint{value: price}(tokenId, v, r, s);
    assertEq(owner.balance, price);

    vm.expectRevert("already minted");
    vm.prank(minter);
    nftContract.mint{value: price}(tokenId, v, r, s);
  }

  function testCanCancel() external {
    uint256 tokenId = _randomUint256();
    uint256 price = _randomUint256() % 100;

    (uint8 v, bytes32 r, bytes32 s) = _signVoucher(tokenId, price);
    vm.prank(owner);
    nftContract.cancel(tokenId, price);

    vm.expectRevert("mint voucher has been cancelled");
    vm.prank(minter);
    nftContract.mint{value: price}(tokenId, v, r, s);
  }

  function _signVoucher(
    uint256 tokenId,
    uint256 price
  ) internal returns (uint8 v, bytes32 r, bytes32 s) {
    return vm.sign(ownerPrivateKey, nftContract.getVoucherHash(tokenId, price));
  }
}
