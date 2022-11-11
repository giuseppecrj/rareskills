// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import {ProxyTester} from "foundry-upgrades/ProxyTester.sol";
import {SpaceFactory} from "../src/SpaceFactory.sol";
import {Space} from "../src/Space.sol";
import {Spacev2} from "../src/Spacev2.sol";

contract SpaceFactoryTest is Test {
  SpaceFactory internal spaceFactory;
  Space internal space;

  function setUp() public {
    space = new Space();
    spaceFactory = new SpaceFactory(address(space));
  }

  function testCreateSpace() public {
    address _space = spaceFactory.createSpace("Space 1");
    assertEq(Space(_space).name(), "Space 1", "Space name should be Space 1");
  }
}
