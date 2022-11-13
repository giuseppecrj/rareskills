// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.17;

contract Greeter {
  string public greeting;

  constructor(string memory _greeting) {
    greeting = _greeting;
  }

  function setGreeting(string memory _greeting) public {
    greeting = _greeting;
  }

  function greet() public view returns (string memory) {
    return greeting;
  }
}
