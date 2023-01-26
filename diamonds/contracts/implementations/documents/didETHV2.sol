//SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "../../Eip712/Eip712CheckerInternal.sol";
import "../../libraries/DocumentStorage.sol";
import "../../libraries/LibResolver.sol";
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
    function createDIDWithPointer(
        address owner,
        int256 documentId,
        string calldata info
    ) external {
        mapping(int256 => Document) storage ns = LibResolver
            .getIntendedResolverStorage();
        ns[documentId].owner = owner;
        ns[documentId].info = info;
        ns[documentId].version = 1;

        emit DIDCreated(owner, documentId);
    }

    /// @notice updates a DID document
    /// @param documentId the id of the document
    /// @param info the string of the document info
    function updateDidInfoWithPointer(
        int256 documentId,
        string calldata info
    ) external {
        mapping(int256 => Document) storage ns = LibResolver
            .getIntendedResolverStorage();
        address owner = ns[documentId].owner;
        require(msg.sender == owner, "Only document owner");

        ns[documentId].info = info;

        emit DIDUpdatedInfo(documentId);
    }

    /// @notice updates a DID document owner
    /// @param documentId the id of the document
    /// @param newOwner the adress of the document info
    function updateDidOwnerWithPointer(
        int256 documentId,
        address newOwner
    ) external {
        mapping(int256 => Document) storage ns = LibResolver
            .getIntendedResolverStorage();
        address owner = ns[documentId].owner;
        require(msg.sender == owner, "Only document owner");

        ns[documentId].owner = newOwner;

        emit DIDUpdatedOwner(documentId, newOwner);
    }

    /// @notice updates a DID version
    /// @param documentId the id of the document
    function upgradeDidVersionWithPointer(int256 documentId) external {
        mapping(int256 => Document) storage ns = LibResolver
            .getIntendedResolverStorage();
        address owner = ns[documentId].owner;
        require(msg.sender == owner, "Only document owner");
        require(
            ResolverVersion > ns[documentId].version,
            "Already latest version"
        );
        ns[documentId].version = ResolverVersion;

        emit DIDVersionUpgraded(documentId, ResolverVersion);
    }
}
