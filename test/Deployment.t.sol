// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {CoreVoting} from "council/CoreVoting.sol";
import {Timelock} from "council/features/Timelock.sol";
import {VestingVault} from "council/vaults/VestingVault.sol";
import {GSCVault} from "council/vaults/GSCVault.sol";
import {SimpleProxy} from "council/simpleProxy.sol";

import {MockERC20} from "./mocks/MockERC20.sol";

contract DeploymentTest is Test {
  function testDeployment() public {
    address deployer = address(this);

    // setup coreVoting with no vaults. change these + the timelock later
    CoreVoting coreVoting = new CoreVoting(
      deployer, // timelock
      10, // basequorum
      3, // min proposal power
      address(0), // gsc
      new address[](0) // voting vaults
    );

    // deploy a new copy of coreVoting for the gsc to use.
    // set quorum to be all available signers, and the minimum voting power
    // to be 1 so any gsc member can propose
    CoreVoting gscCoreVoting = new CoreVoting(
      deployer,
      1,
      1,
      address(0),
      new address[](0)
    );

    // setup timelock
    Timelock timelock = new Timelock(1000, deployer, deployer);

    // setup vaults
    // ----------------
    // deploy a mock erc20 token
    MockERC20 token = new MockERC20("ZION", "Test", deployer);

    // deploy a vesting vault
    VestingVault vestingVaultBase = new VestingVault(token, 199350);

    // deploy a simple proxy
    SimpleProxy vestingVaultProxy = new SimpleProxy(
      address(timelock),
      address(vestingVaultBase)
    );

    VestingVault vestingVault = VestingVault(address(vestingVaultProxy));

    // initialize vesting vault
    vestingVault.initialize(deployer, address(timelock));

    // deploy gsc vault
    GSCVault gscVault = new GSCVault(gscCoreVoting, 3, address(timelock));

    // change vault status of corevoting
    coreVoting.changeVaultStatus(address(vestingVault), true);

    // change vault status of gcs
    gscCoreVoting.changeVaultStatus(address(gscVault), true);
  }
}
