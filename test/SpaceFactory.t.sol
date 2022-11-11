// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import {SpaceFactory} from "../src/SpaceFactory.sol";
import {Space} from "../src/Space.sol";
import {Spacev2} from "../src/Spacev2.sol";

// import {ERC1967Proxy} from "openzeppelin-contracts/proxy/ERC1967/ERC1967Proxy.sol";

// contract UUPSProxy is ERC1967Proxy {
//   constructor(address _implementation, bytes memory _data)
//     ERC1967Proxy(_implementation, _data)
//   {}
// }

contract SpaceFactoryTest is Test {
  SpaceFactory internal spaceFactory;
  Space internal space;
  Spacev2 internal spacev2;

  function setUp() public {
    space = new Space();
    spaceFactory = new SpaceFactory(address(space));
  }

  function testCreateSpace() public {
    address _space = spaceFactory.createSpace("Space 1");
    assertEq(Space(_space).name(), "Space 1", "Space name should be Space 1");

    spacev2 = new Spacev2();
    spaceFactory.upgradeSpace(_space, address(spacev2));

    Spacev2(_space).setName("Space Upgraded");
    assertEq(
      Spacev2(_space).name(),
      "Space Upgraded",
      "Space name should be Space Upgraded"
    );
  }
}
