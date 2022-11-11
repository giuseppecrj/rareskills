// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import {SpaceFactory} from "../src/SpaceFactory.sol";
import {Space} from "../src/Space.sol";
import {Spacev2} from "../src/Spacev2.sol";

contract SpaceFactoryTest is Test {
  SpaceFactory internal spaceFactory;
  Space internal space;
  Spacev2 internal spacev2;

  function setUp() public {
    // Deploy SpaceFactory and Space implementations
    space = new Space();
    spaceFactory = new SpaceFactory(address(space));
  }

  function testCreateSpace() public {
    // Create a new Space using SpaceFactory
    address _space = spaceFactory.createSpace("Space 1");
    assertEq(Space(_space).name(), "Space 1");

    // Deploy a new version of Space
    spacev2 = new Spacev2();

    // Upgrade Space to Spacev2
    spaceFactory.upgradeSpace(_space, address(spacev2));

    // Check that Space has been upgraded to Spacev2
    Spacev2(_space).setDescription("My cool space");

    // Check that Spacev2 has the same name
    assertEq(Spacev2(_space).name(), "Space 1");

    // Check that Spacev2 has the new description
    assertEq(Spacev2(_space).description(), "My cool space");
  }
}
