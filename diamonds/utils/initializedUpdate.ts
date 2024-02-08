import { ethers } from "hardhat";
import { DIDRegistry, DidETH, Documents } from "../typechain-types";
import { Signer } from "ethers";
import { getSelectors } from "./helpers";
export const initializeUpdate = async (admin: Signer) => {
  let localDidRegistryInstance: DIDRegistry;
  let localDidEthInstance: DidETH;
  let localDidEthFacet: DidETH;
  let didEthContractSelectors: string[];
  let localDocumentsInstance: Documents;
  let localDocumentsFacet: Documents;

  const DIDRegistry = await ethers.getContractFactory("DIDRegistry");
  const didRegistryImplementation = await DIDRegistry.connect(admin).deploy();
  await didRegistryImplementation.deployed();

  const didRegistry = await ethers.getContractAt(
    "DIDRegistry",
    didRegistryImplementation.address
  );

  const contractSelectors = getSelectors(DIDRegistry.interface);

  await didRegistry
    .connect(admin)
    .addModule(didRegistryImplementation.address, contractSelectors);

  localDidRegistryInstance = didRegistry;

  const DocumentsContractFactory = await ethers.getContractFactory("Documents");
  const documentsContractImplementation =
    await DocumentsContractFactory.connect(admin).deploy();
  await documentsContractImplementation.deployed();

  const documentContractSelectors = getSelectors(
    DocumentsContractFactory.interface
  );
  await didRegistry
    .connect(admin)
    .addModule(
      documentsContractImplementation.address,
      documentContractSelectors
    );
  localDocumentsInstance = documentsContractImplementation;
  localDocumentsFacet = await ethers.getContractAt(
    "Documents",
    didRegistry.address
  );

  const didETHContractFactory = await ethers.getContractFactory("didETH");
  const didEthContractImplementation = await didETHContractFactory
    .connect(admin)
    .deploy();
  await didEthContractImplementation.deployed();

  didEthContractSelectors = getSelectors(didETHContractFactory.interface);
  await didRegistry
    .connect(admin)
    .addModule(didEthContractImplementation.address, didEthContractSelectors);
  //@ts-ignore
  localDidEthInstance = didEthContractImplementation;
  //@ts-ignore
  localDidEthFacet = await ethers.getContractAt("didETH", didRegistry.address);
  return {
    localDidRegistryInstance,
    localDidEthFacet,
    localDidEthInstance,
    didEthContractSelectors,
    localDocumentsFacet,
    localDocumentsInstance,
  };
};
