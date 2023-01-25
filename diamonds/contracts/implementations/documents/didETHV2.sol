//SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "../../Eip712/Eip712CheckerInternal.sol";
import "../../libraries/DocumentStorage.sol";
import "../../libraries/documents/didETHStorage.sol";

import {Document} from "../../shared/Types.sol";

import "@solidstate/contracts/access/access_control/AccessControlInternal.sol";

/// @title DID
/// @notice Contract that represents the DID Document
contract didETHV2 {
    bytes32 private constant Create_TYPEHASH =
        keccak256("CreateDID2(address owner, int256 documentId, string info)");
    int256 private constant ResolverVersion = 2;
    event DIDCreated(address owner, int256 documentId);
    event DIDUpdatedInfo(int256 documentId);
    event DIDUpdatedOwner(int256 documentId, address newOwner);
    event DIDVersionUpgraded(int256 documentId, int256 version);

    /* solhint-disable no-inline-assembly */
    function getStorageAddress() external view returns (address proxyAddress) {
        didETHStorage.Storage storage s = didETHStorage.getStorage();
        proxyAddress = s.idProxyAddress;
    }

    /// @notice Creates a new DID document
    /// @param owner The address of the owner
    /// @param documentId the id of the document
    /// @param info the string of the document info
    function createDID(
        address owner,
        int256 documentId,
        string calldata info
    ) external {
        DocumentStorage.Storage storage ns = DocumentStorage.getStorage();
        didETHStorage.Storage storage s = didETHStorage.getStorage();
        address idProxyAddress = s.idProxyAddress;

        ns.documents[idProxyAddress][documentId].owner = owner;
        ns.documents[idProxyAddress][documentId].info = info;
        ns.documents[idProxyAddress][documentId].version = ResolverVersion;

        emit DIDCreated(owner, documentId);
    }

    /// @notice updates a DID document
    /// @param documentId the id of the document
    /// @param info the string of the document info
    function updateDidInfo(int256 documentId, string calldata info) external {
        DocumentStorage.Storage storage ns = DocumentStorage.getStorage();
        didETHStorage.Storage storage s = didETHStorage.getStorage();
        address idProxyAddress = s.idProxyAddress;
        address owner = ns.documents[idProxyAddress][documentId].owner;
        require(msg.sender == owner, "Only document owner");

        ns.documents[idProxyAddress][documentId].info = info;

        emit DIDUpdatedInfo(documentId);
    }

    /// @notice updates a DID document owner
    /// @param documentId the id of the document
    /// @param newOwner the adress of the document info
    function updateDidOwner(int256 documentId, address newOwner) external {
        DocumentStorage.Storage storage ns = DocumentStorage.getStorage();
        didETHStorage.Storage storage s = didETHStorage.getStorage();
        address idProxyAddress = s.idProxyAddress;

        address owner = ns.documents[idProxyAddress][documentId].owner;

        require(msg.sender == owner, "Only document owner");

        ns.documents[idProxyAddress][documentId].owner = newOwner;

        emit DIDUpdatedOwner(documentId, newOwner);
    }

    /// @notice updates a DID document
    /// @param documentId the id of the document
    function upgradeDidVersion(int256 documentId) external {
        DocumentStorage.Storage storage ns = DocumentStorage.getStorage();
        didETHStorage.Storage storage s = didETHStorage.getStorage();
        address idProxyAddress = s.idProxyAddress;
        address owner = ns.documents[idProxyAddress][documentId].owner;
        require(msg.sender == owner, "Only document owner");
        require(
            ResolverVersion > ns.documents[idProxyAddress][documentId].version,
            "Already latest version"
        );

        ns.documents[idProxyAddress][documentId].version = ResolverVersion;

        emit DIDVersionUpgraded(documentId, ResolverVersion);
    }
}
