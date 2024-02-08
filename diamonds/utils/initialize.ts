import { Wallet } from "ethers";
import { ethers } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

import { getSelectors } from ".";

async function initialize(
  deployer: Wallet | SignerWithAddress,
  ...contracts: string[]
) {
  const instances: any[] = [];
  const selectors: { [key: string]: string[] } = {};
  // Deploy DIDRegistry Implementation
  const DIDRegistry = await ethers.getContractFactory("DIDRegistry");
  const didRegistryImplementation = await DIDRegistry.connect(
    deployer
  ).deploy();
  await didRegistryImplementation.deployed();

  const didRegistry = await ethers.getContractAt(
    "DIDRegistry",
    didRegistryImplementation.address
  );

  const contractSelectors = getSelectors(DIDRegistry.interface);

  await didRegistry
    .connect(deployer)
    .addModule(didRegistryImplementation.address, contractSelectors);

  instances.push(didRegistry);

  for (const contractName of contracts) {
    const ContractFactory = await ethers.getContractFactory(contractName);
    const contractImplementation = await ContractFactory.connect(
      deployer
    ).deploy();
    await contractImplementation.deployed();

    const contractSelectors = getSelectors(ContractFactory.interface);
    selectors[contractName] = getSelectors(ContractFactory.interface);
    contractImplementation;
    await didRegistry
      .connect(deployer)
      .addModule(contractImplementation.address, contractSelectors);

    instances.push(
      await ethers.getContractAt(contractName, didRegistry.address)
    );
  }

  return { instances, selectors };
}

export { initialize };
