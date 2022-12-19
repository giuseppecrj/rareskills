// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import {TestUtils} from "test/TestUtils.sol";
import {OnChainPfp, BigDataStore} from "src/OnChainPfp.sol";

contract OnChainPfpTest is TestUtils {
  OnChainPfp pfp = new OnChainPfp();

  string constant BASE64_PNG =
    "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAIAAAAlC+aJAAAAAklEQVR4nGKkkSsAAAEXSURBVO3WIQ7CMBQG4Np5HME2CAwKicfgMEhOAHfgCmiugOUAnAHNRcbCkmZ53Wv7miWl7f/ymy1t+L+k21Cn6y3rqOQNAEjdAIDUDQBI3eDvAIoZAABw9zOj17vRuHcBENyb60fSvlWfwPXREgBKBUgDQPEAW9L+hlyaO+TSu15aAwBr8jtCAKQGnLeLYTiYdACoBzDt2D90fzy7AOA7Qt5m5KQdtCIBoBIAV0gKMPcvm6YPAJUDOAm3jNsIQDAgoiIAAIxK9qtZl8B+DjYAlQNMpEffbOQAoX0AkMV+m7kHgGoBy3lD0u96Bc/nqLt4JQDkCyBvw/yegUIA9odJKpEWAKBUAPf3M/pwA1A5YKp+AAAAgCdfgXWDFWuL1n4AAAAASUVORK5CYII=";

  function testMint() public {
    uint tokenId = pfp.mint(BASE64_PNG);
    assertEq(tokenId, pfp.lastTokenId());
    assertEq(
      pfp.tokenURI(tokenId),
      string(abi.encodePacked("data:image/png;base64,", BASE64_PNG))
    );
  }

  function testTransfer() public {
    uint tokenId = pfp.mint(BASE64_PNG);
    address to = _randomAddress();
    pfp.transferFrom(address(this), to, tokenId);
    assertEq(pfp.ownerOf(tokenId), to);
  }

  function testCanTransferWithApproval() public {
    uint256 tokenId = pfp.mint(BASE64_PNG);
    address to = _randomAddress();
    address spender = _randomAddress();
    pfp.setApprovalForAll(spender, true);
    vm.prank(spender);
    pfp.transferFrom(address(this), to, tokenId);
    assertEq(pfp.ownerOf(tokenId), to);
  }

  function testCanRevokeApproval() public {
    address spender = _randomAddress();
    pfp.setApprovalForAll(spender, true);
    assertTrue(pfp.isApprovedForAll(address(this), spender));
    pfp.setApprovalForAll(spender, false);
    assertFalse(pfp.isApprovedForAll(address(this), spender));
  }

  function testCannotTransferTwice() public {
    uint tokenId = pfp.mint(BASE64_PNG);
    address to = _randomAddress();
    pfp.transferFrom(address(this), to, tokenId);

    vm.expectRevert("wrong owner");
    pfp.transferFrom(address(this), to, tokenId);
  }

  function testCannotTransferUnmintedToken() public {
    address to = _randomAddress();
    uint256 tokenId = pfp.lastTokenId() + 1;
    vm.expectRevert("wrong owner");
    pfp.transferFrom(address(this), to, tokenId);
  }

  function testCannotTransferWithoutApproval() public {
    uint tokenId = pfp.mint(BASE64_PNG);
    address to = _randomAddress();
    address spender = _randomAddress();

    vm.prank(spender);
    vm.expectRevert("not approved");
    pfp.transferFrom(address(this), to, tokenId);
  }
}
