const fs = require("fs/promises");
const { F_OK } = require("fs");

const inquirer = require("inquirer");
const { BigNumber } = require("ethers");
const config = require("getconfig");

const CONTRACT_NAME = "Minty";

async function loadDeploymentInfo() {
  let { deploymentConfigFile } = config;
  if (!deploymentConfigFile) {
    console.log(
      'no deploymentConfigFile field found in minty config. attempting to read from default path "./minty-deployment.json"',
    );
    deploymentConfigFile = "minty-deployment.json";
  }

  const content = JSON.parse(
    await fs.readFile(deploymentConfigFile, { encoding: "utf8" }),
  );

  const abi = await fs.readFile(
    `out/${content.contract.name}.sol/${content.contract.name}.json`,
    {
      encoding: "utf8",
    },
  );

  content.contract.abi = JSON.parse(abi).abi;

  deployInfo = content;
  try {
    validateDeploymentInfo(deployInfo);
  } catch (e) {
    throw new Error(
      `error reading deploy info from ${deploymentConfigFile}: ${e.message}`,
    );
  }
  return deployInfo;
}

function validateDeploymentInfo(deployInfo) {
  const { contract } = deployInfo;
  if (!contract) {
    throw new Error('required field "contract" not found');
  }
  const required = (arg) => {
    if (!deployInfo.contract.hasOwnProperty(arg)) {
      throw new Error(`required field "contract.${arg}" not found`);
    }
  };

  required("name");
  required("address");
  required("abi");
}

module.exports = {
  loadDeploymentInfo,
};
