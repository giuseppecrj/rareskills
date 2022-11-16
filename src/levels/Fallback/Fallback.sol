// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import {SafeMath} from "openzeppelin-contracts/contracts/utils/math/SafeMath.sol";

contract Fallback {
  using SafeMath for uint256;
  mapping(address => uint256) public contributions;
  address payable public owner;

  modifier onlyOwner() {
    require(msg.sender == owner, "caller is not the owner");
    _;
  }

  constructor() payable {
    owner = payable(msg.sender);
    contributions[msg.sender] = 1000 * (1 ether);
  }

  function contribute() public payable {
    require(msg.value < 0.001 ether, "msg.value must be < 0.001 ether");

    contributions[msg.sender] += msg.value;
    if (contributions[msg.sender] > contributions[owner]) {
      owner = payable(msg.sender);
    }
  }

  function getContribution() public view returns (uint256) {
    return contributions[msg.sender];
  }

  function withdraw() public onlyOwner {
    uint256 balance = address(this).balance;
    require(balance > 0, "contract balance must be > 0");
    owner.transfer(balance);
  }

  fallback() external payable {
    require(
      msg.value > 0 && contributions[msg.sender] > 0,
      "tx must have value and msg.send must have made a contribution"
    );
    owner = payable(msg.sender);
  }
}
