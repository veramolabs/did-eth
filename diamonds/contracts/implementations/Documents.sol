//SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "../libraries/DocumentStorage.sol";

/// @title Documents
/// @notice Contract to store data related to the documents
contract Documents {
    /// @notice Gets the info of a document
    /// @param idProxyAddress The address of the proxy associated with the document
    /// @param documentId The documentId
    function getDocumentInfo(
        address idProxyAddress,
        int256 documentId
    ) external view returns (string memory info) {
        info = DocumentStorage
        .getStorage()
        .documents[idProxyAddress][documentId].info;
    }

    /// @notice Gets the owner of a document
    /// @param idProxyAddress The address of the proxy associated with the document
    /// @param documentId The documentId
    function getDocumentOwner(
        address idProxyAddress,
        int256 documentId
    ) external view returns (address owner) {
        owner = DocumentStorage
        .getStorage()
        .documents[idProxyAddress][documentId].owner;
    }

    /// @notice Gets the version of a document
    /// @param idProxyAddress The address of the proxy associated with the document
    /// @param documentId The documentId
    function getDocumentVersion(
        address idProxyAddress,
        int256 documentId
    ) external view returns (int256 version) {
        version = DocumentStorage
        .getStorage()
        .documents[idProxyAddress][documentId].version;
    }
}
