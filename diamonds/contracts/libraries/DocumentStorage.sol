//SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "../shared/Types.sol";

/// @title DocumentsStorage
/// @notice Storage of the Documents contract
library DocumentStorage {
    bytes32 internal constant DOCUMENTS_STORAGE_SLOT =
        keccak256("DID.documents.storage");

    struct Storage {
        mapping(address => mapping(int256 => Document)) documents;
    }

    /* solhint-disable no-inline-assembly */
    function getStorage() internal pure returns (Storage storage s) {
        bytes32 slot = DOCUMENTS_STORAGE_SLOT;
        assembly {
            s.slot := slot
        }
    }

    /// @notice Gets the mapping for a mapping
    /// @param idProxyAddress The address of the proxy associated with the document
    function getStoragePointer(
        address idProxyAddress
    ) internal view returns (mapping(int256 => Document) storage s) {
        Storage storage strg;
        bytes32 slot = DOCUMENTS_STORAGE_SLOT;
        assembly {
            strg.slot := slot
        }
        s = strg.documents[idProxyAddress];
    }

    /* solhint-enable no-inline-assembly */
}
