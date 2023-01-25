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
    /* solhint-enable no-inline-assembly */
}
