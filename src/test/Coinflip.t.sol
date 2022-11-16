// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {Ethernaut} from "src/core/Ethernaut.sol";
import {CoinFlipFactory} from "src/levels/CoinFlip/CoinFlipFactory.sol";
import {CoinFlip} from "src/levels/CoinFlip/CoinFlip.sol";
import {CoinFlipHack} from "src/levels/CoinFlip/CoinFlipHack.sol";

contract CoinFlipTest is Test {
  Ethernaut internal ethernaut;
  address internal eoaAddress = address(100);

  function setUp() public {
    // Setup instance of the Ethernaut contract
    ethernaut = new Ethernaut();
    // Deal EOA address some ether
    vm.deal(eoaAddress, 5 ether);
  }

  function testCoinFlipHack() public {
    /////////////////
    // LEVEL SETUP //
    /////////////////
    CoinFlipFactory coinFlipFactory = new CoinFlipFactory();
    ethernaut.registerLevel(coinFlipFactory);
    vm.startPrank(eoaAddress);
    address levelAddress = ethernaut.createLevelInstance(coinFlipFactory);
    CoinFlip ethernautCoinFlip = CoinFlip(payable(levelAddress));

    //////////////////
    // LEVEL ATTACK //
    //////////////////
    CoinFlipHack coinFlipHack = new CoinFlipHack(levelAddress);
    uint256 BLOCK_START = 100;
    vm.roll(BLOCK_START);

    for (uint256 i = 0; i < 10; i++) {
      vm.roll(i + 1);
      coinFlipHack.attack();
    }

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
