// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import {TestUtils} from "test/TestUtils.sol";
import {SignedMessage, EIP712Signature} from "src/SignedMessage.sol";

contract TestableSignedMessage is SignedMessage {
  constructor(string memory _name) SignedMessage(_name) {}

  function getSetMessageHash(string memory _message)
    public
    view
    returns (bytes32)
  {
    return _getSetMessageHash(_message);
  }
}

contract SignedMessageTest is TestUtils {
  TestableSignedMessage signMessageContract;

  uint256 ownerPrivateKey;
  address payable owner;

  function setUp() public {
    ownerPrivateKey = _randomUint256();
    owner = payable(vm.addr(ownerPrivateKey));

    vm.prank(owner);
    signMessageContract = new TestableSignedMessage("TestableSignedMessage");
  }

  function testSetMessage() external {
    string memory message = "Hello World";
    EIP712Signature memory sig = _signMessage(message);

    vm.prank(_randomAddress());
    signMessageContract.setMessage(message, sig);

    assertEq(signMessageContract.message(), message);
  }

  function _signMessage(string memory _message)
    private
    returns (EIP712Signature memory sig)
  {
    (uint8 v, bytes32 r, bytes32 s) = vm.sign(
      ownerPrivateKey,
      signMessageContract.getSetMessageHash(_message)
    );
    return EIP712Signature(v, r, s, block.timestamp);
  }
}
