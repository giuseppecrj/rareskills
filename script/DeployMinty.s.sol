// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import {ScriptUtils} from "script/utils/ScriptUtils.sol";
import {Minty} from "src/Minty.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {console} from "forge-std/console.sol";

contract DeployMinty is ScriptUtils {
  Minty public minty;

  function run() public {
    vm.startBroadcast();
    minty = new Minty();
    vm.stopBroadcast();
    _writeJson();
  }

  function _writeJson() internal {
    string memory outputPath = "./minty-deployment.json";

    vm.writeJson(_getChainName(), outputPath, ".network");
    vm.writeJson("Minty", outputPath, ".contract.name");
    vm.writeJson(vm.toString(address(minty)), outputPath, ".contract.address");
    vm.writeJson(vm.toString(msg.sender), outputPath, ".contract.deployer");
  }
}
