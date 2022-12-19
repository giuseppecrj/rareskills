// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import {console} from "forge-std/console.sol";

contract WalletProxy {
  address public immutable owner;
  uint256 constant EIP9167_LOGIC_SLOT =
    0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

  event Upgraded(address indexed logic);

  constructor(address logic) {
    // Creator is the owner/admin
    owner = msg.sender;
    _setLogic(logic);
  }

  function upgrade(address logic) public {
    require(msg.sender == owner, "only owner");
    _setLogic(logic);
  }

  fallback(
    bytes calldata callData
  ) external payable returns (bytes memory resultData) {
    address logic;
    assembly {
      logic := sload(EIP9167_LOGIC_SLOT)
    }
    bool success;
    (success, resultData) = logic.delegatecall(callData);
    if (!success) {
      // bubble up the revert if the call failed.
      assembly {
        revert(add(resultData, 0x20), mload(resultData))
      }
    }
    // Otherwise, the raw resultData will be returned.
  }

  // Allow wallet to receive ETH
  receive() external payable {}

  function _setLogic(address logic) private {
    emit Upgraded(logic);
    assembly {
      sstore(EIP9167_LOGIC_SLOT, logic)
    }
  }
}

contract WalletLogicV1 {
  modifier onlyOwner() {
    // owner() is a function defined on the Proxy contract, which we can
    // reach through address(this), since we'll be inside a delegatecall context
    require(
      msg.sender == WalletProxy(payable(address(this))).owner(),
      "only owner"
    );
    _;
  }

  function version() external pure virtual returns (string memory) {
    return "V1";
  }

  function transferETH(address payable to, uint256 amount) external onlyOwner {
    to.transfer(amount);
  }
}

contract WalletLogicV2 is WalletLogicV1 {
  function version() external pure virtual override returns (string memory) {
    return "V2";
  }

  function transferERC20(
    IERC20 token,
    address to,
    uint256 amount
  ) external onlyOwner {
    token.transfer(to, amount);
  }
}

interface IERC20 {
  function transfer(address to, uint256 amount) external returns (bool);
}
