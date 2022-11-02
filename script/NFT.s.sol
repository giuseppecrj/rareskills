// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {NFT} from "../src/NFT.sol";

contract DeployNFT is Script {
  function run() public {
    vm.startBroadcast();
    NFT nft = new NFT();
    vm.stopBroadcast();
  }
}
