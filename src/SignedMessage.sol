// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

//interfaces

//libraries

//contracts

struct EIP712Signature {
  uint8 v;
  bytes32 r;
  bytes32 s;
  uint256 deadline;
}

contract SignedMessage {
  string internal contractName;
  string public message;
  address immutable owner;

  // EIP712 domain separator
  bytes32 internal constant EIP712_REVISION_HASH = keccak256("1");
  bytes32 internal constant EIP712_DOMAIN_TYPEHASH =
    keccak256(
      "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
    );

  bytes32 internal constant MESSAGE_TYPE_HASH =
    keccak256("SignedMessage(string message)");

  // errors
  error SignatureExpired();
  error SignatureInvalid();

  constructor(string memory _name) {
    contractName = _name;
    owner = msg.sender;
  }

  function setMessage(string memory _message, EIP712Signature memory sig)
    external
  {
    // validate owner signed the message
    _validateRecoveredAddress(
      _calculateDigest(keccak256(abi.encode(MESSAGE_TYPE_HASH, _message))),
      owner,
      sig
    );

    // Set the message
    message = _message;
  }

  // Utility functions
  function _validateRecoveredAddress(
    bytes32 digest,
    address expectedAddress,
    EIP712Signature memory sig
  ) internal view {
    if (sig.deadline < block.timestamp) revert SignatureExpired();
    address recoveredAddress = ecrecover(digest, sig.v, sig.r, sig.s);
    if (recoveredAddress == address(0) || recoveredAddress != expectedAddress) {
      revert SignatureInvalid();
    }
  }

  function _calculateDomainSeparator() internal view returns (bytes32) {
    return
      keccak256(
        abi.encode(
          EIP712_DOMAIN_TYPEHASH,
          keccak256(bytes(contractName)),
          EIP712_REVISION_HASH,
          block.chainid,
          address(this)
        )
      );
  }

  function _calculateDigest(bytes32 hashedMessage)
    internal
    view
    returns (bytes32)
  {
    bytes32 digest;
    unchecked {
      digest = keccak256(
        abi.encodePacked("\x19\x01", _calculateDomainSeparator(), hashedMessage)
      );
    }
    return digest;
  }

  // helper function to get the hash of a message
  // this would be created by the client
  function _getSetMessageHash(string memory _message)
    internal
    view
    returns (bytes32)
  {
    bytes32 structHash = keccak256(abi.encode(MESSAGE_TYPE_HASH, _message));
    return _calculateDigest(structHash);
  }
}
