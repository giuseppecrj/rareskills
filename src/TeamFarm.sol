// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "./interfaces.sol";

contract TeamFarm {
  IERC20 constant ETH_TOKEN = IERC20(address(0));
  IWETH public immutable WETH;

  mapping(address => bool) public isMember;
  bool reentrancyGuard;

  modifier nonReentrant() {
    require(!reentrancyGuard, "reentrancy");
    reentrancyGuard = true;
    _;
    reentrancyGuard = false;
  }

  modifier onlyMember() {
    require(isMember[msg.sender], "not member");
    _;
  }

  constructor(IWETH weth, address[] memory members) {
    WETH = weth;
    for (uint256 i = 0; i < members.length; i++) {
      isMember[members[i]] = true;
    }
  }

  function setMember(address member, bool toggle) external payable onlyMember {
    isMember[member] = toggle;
  }

  function wrap(uint256 ethAmount) external payable onlyMember nonReentrant {
    WETH.deposit{value: ethAmount}();
  }

  function unwrap(uint256 wethAmount) external payable onlyMember nonReentrant {
    WETH.withdraw(wethAmount);
  }

  function deposit(
    IERC20 token,
    uint256 tokenAmount
  ) external payable nonReentrant {
    if (token != ETH_TOKEN) {
      token.transferFrom(msg.sender, address(this), tokenAmount);
    }
  }

  function withdraw(
    IERC20 token,
    uint256 tokenAmount,
    address payable receiver
  ) external payable onlyMember nonReentrant {
    if (token != ETH_TOKEN) {
      token.transfer(receiver, tokenAmount);
    } else {
      (bool s, ) = receiver.call{value: tokenAmount}("");
      require(s, "ETH transfer failed");
    }
  }

  function stake(
    IERC4626 vault,
    uint256 assets
  ) external payable onlyMember nonReentrant returns (uint256 shares) {
    vault.asset().approve(address(vault), assets);
    shares = vault.deposit(assets, address(this));
  }

  function unstake(
    IERC4626 vault,
    uint256 shares
  ) external payable onlyMember nonReentrant returns (uint256 assets) {
    assets = vault.redeem(shares, address(this), address(this));
  }

  function multicall(bytes[] calldata calls) external payable {
    for (uint256 i = 0; i < calls.length; i++) {
      // By using delegatecall and ourselves as the target (bytecode)
      // each sub-call will inherit the same `msg.sender` and `msg.value` as this one,
      // as if they had called it directly
      (bool s, bytes memory r) = address(this).delegatecall(calls[i]);
      if (!s) {
        // Bubble up revert on failure
        assembly {
          revert(add(r, 0x20), mload(r))
        }
      }
    }
  }

  // Allow contract to receive ETH directly
  receive() external payable {}
}
