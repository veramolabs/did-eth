import chai from "chai";
import { ethers, waffle } from "hardhat";

import {
  DIDRegistry,
  DidETH,
  DidETHV2,
  Documents,
  Eip712Checker,
} from "../typechain-types";
import {
  initialize,
  createSnapshot,
  revertToSnapshot,
  getSelectors,
} from "../utils";
import { initializeUpdate } from "../utils/initializedUpdate";

const { expect } = chai;
const { solidity } = waffle;
const provider = waffle.provider;

chai.use(solidity);

describe("DIDEth", function () {
  const [admin, nonAdmin, manufacturer1, user1, user2] = provider.getWallets();

  describe("createDID", () => {
    let localDidRegistryInstance: DIDRegistry;
    let localDidEthInstance: DidETH;
    let localDidEth2Instance: DidETHV2;
    let localDocumentsInstance: Documents;
    let localSelectors: { [key: string]: string[] };
    before(async () => {
      const { instances, selectors } = await initialize(
        admin,
        "Documents",
        "didETH"
      );
      [localDidRegistryInstance, localDocumentsInstance, localDidEthInstance] =
        instances;
      localSelectors = selectors;
    });

    context("Create", () => {
      it("Should succeed", async () => {
        const docId = ethers.BigNumber.from(500);

        await expect(
          localDidEthInstance
            .connect(nonAdmin)
            .createDID(nonAdmin.address, docId, "test")
        )
          .to.emit(localDidEthInstance, "DIDCreated")
          .withArgs(nonAdmin.address, docId);
      });
    });

    context("Update DID - Fail", () => {
      it("Should fail because not document owner", async () => {
        const docId = ethers.BigNumber.from(500);

        await expect(
          localDidEthInstance.connect(user1).updateDidInfo(docId, "test2")
        ).to.be.revertedWith("Only document owner");
      });
    });

    context("Update DID - Succeed", () => {
      it("Should fail because not document owner", async () => {
        const docId = ethers.BigNumber.from(500);

        await expect(
          localDidEthInstance.connect(nonAdmin).updateDidInfo(docId, "test2")
        )
          .to.emit(localDidEthInstance, "DIDUpdatedInfo")
          .withArgs(docId);
      });
    });

    context("Check DID document owner - Succeed", () => {
      it("The document owner should be corrent", async () => {
        const docId = ethers.BigNumber.from(500);
        const didETHProxyId = await localDidEthInstance
          .connect(nonAdmin)
          .getStorageAddress();

        const docOwner = await localDocumentsInstance.getDocumentOwner(
          didETHProxyId,
          docId
        );
        expect(docOwner).to.be.equal(nonAdmin.address);
      });
    });

    context("Check DID document version - Succeed", () => {
      it("The document version should be corrent", async () => {
        const docId = ethers.BigNumber.from(500);
        const didETHProxyId = await localDidEthInstance
          .connect(nonAdmin)
          .getStorageAddress();

        const docVersion = await localDocumentsInstance.getDocumentVersion(
          didETHProxyId,
          docId
        );
        expect(docVersion).to.be.equal(1);
      });
    });
  });
});

describe("Remove resolver stuff", function () {
  const [admin, nonAdmin, manufacturer1, user1, user2] = provider.getWallets();

  describe("remove resolver", () => {
    let localDidRegistryInstance: DIDRegistry;
    let localDidEthInstance: DidETH;
    let localDidEthFacet: DidETH;
    let didEthContractSelectors: string[];
    let localDocumentsInstance: Documents;
    let localDocumentsFacet: Documents;
    before(async () => {
      const deployedStuff = await initializeUpdate(admin);

      localDidRegistryInstance = deployedStuff.localDidRegistryInstance;
      localDidEthFacet = deployedStuff.localDidEthFacet;
      didEthContractSelectors = deployedStuff.didEthContractSelectors;
      localDocumentsFacet = deployedStuff.localDocumentsFacet;
      localDidEthInstance = deployedStuff.localDidEthInstance;
      localDocumentsInstance = deployedStuff.localDocumentsInstance;
    });

    context("Remove DID Resolver", () => {
      it("We should be able to remove the DID resolver", async () => {
        await expect(
          await localDidRegistryInstance
            .connect(admin)
            .removeModule(localDidEthInstance.address, didEthContractSelectors)
        ).to.emit(localDidRegistryInstance, "ModuleRemoved");
      });
    });
  });
});

describe("Update resolver stuff", function () {
  const [admin, nonAdmin, manufacturer1, user1, user2] = provider.getWallets();

  let localDidRegistryInstance: DIDRegistry;
  let localDidEthInstance: DidETH;
  let localDidEthFacet: DidETH;
  let localDidEthV2Facet: DidETHV2;
  let localDidEthV2Instance: DidETHV2;
  let didEthContractSelectors: string[];
  let didEthV2ContractSelectors: string[];
  let localDocumentsInstance: Documents;
  let localDocumentsFacet: Documents;
  before(async () => {
    const deployedStuff = await initializeUpdate(admin);
    localDidRegistryInstance = deployedStuff.localDidRegistryInstance;
    localDidEthFacet = deployedStuff.localDidEthFacet;
    didEthContractSelectors = deployedStuff.didEthContractSelectors;
    localDocumentsFacet = deployedStuff.localDocumentsFacet;
    localDidEthInstance = deployedStuff.localDidEthInstance;
    localDocumentsInstance = deployedStuff.localDocumentsInstance;
  });

  context("Upgrade the resolver", () => {
    it("Create DID should succeed", async () => {
      const docId = ethers.BigNumber.from(500);

      await expect(
        localDidEthFacet
          .connect(nonAdmin)
          .createDID(nonAdmin.address, docId, "test")
      )
        .to.emit(localDidEthFacet, "DIDCreated")
        .withArgs(nonAdmin.address, docId);
    });

    it("The document version should be corrent", async () => {
      const docId = ethers.BigNumber.from(500);
      const didETHProxyId = await localDidEthFacet
        .connect(nonAdmin)
        .getStorageAddress();

      const docVersion = await localDocumentsFacet.getDocumentVersion(
        didETHProxyId,
        docId
      );
      expect(docVersion).to.be.equal(1);
    });

    it("Create the the new DID Resolver", async () => {
      const didETHV2ContractFactory = await ethers.getContractFactory(
        "didETHV2"
      );
      const didEthV2ContractImplementation = await didETHV2ContractFactory
        .connect(admin)
        .deploy();
      await didEthV2ContractImplementation.deployed();

      didEthV2ContractSelectors = getSelectors(
        didETHV2ContractFactory.interface
      );
      //@ts-ignore
      localDidEthV2Instance = didEthV2ContractImplementation;
      expect(localDidEthV2Instance.address).to.exist;
    });

    it("Upgrade the new DID Resolver", async () => {
      await expect(
        await localDidRegistryInstance
          .connect(admin)
          .updateModule(
            localDidEthInstance.address,
            localDidEthV2Instance.address,
            didEthContractSelectors,
            didEthV2ContractSelectors
          )
      ).to.emit(localDidRegistryInstance, "ModuleUpdated");

      //@ts-ignore
      localDidEthV2Facet = await ethers.getContractAt(
        "didETHV2",
        localDidRegistryInstance.address
      );
    });

    it("Upgrade our DID", async () => {
      const docId = ethers.BigNumber.from(500);
      await expect(
        await localDidEthV2Facet.connect(nonAdmin).upgradeDidVersion(docId)
      ).to.emit(localDidEthV2Facet, "DIDVersionUpgraded");
    });

    it("The document version should be corrent", async () => {
      const docId = ethers.BigNumber.from(500);
      const didETHProxyId = await localDidEthV2Facet
        .connect(nonAdmin)
        .getStorageAddress();

      const docVersion = await localDocumentsFacet.getDocumentVersion(
        didETHProxyId,
        docId
      );
      expect(docVersion).to.be.equal(2);
    });
  });
});
