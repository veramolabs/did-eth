//SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

/// @title didETH Document Storage
/// @notice Storage of the did-eth documents
library didETHStorage {
    bytes32 private constant DID_ETH_STORAGE_SLOT =
        keccak256("DocumentStorage.did-eth.storage");

    struct Storage {
        address idProxyAddress;
    }

    /* solhint-disable no-inline-assembly */
    function getStorage() internal pure returns (Storage storage s) {
        bytes32 slot = DID_ETH_STORAGE_SLOT;
        assembly {
            s.slot := slot
        }
    }
    /* solhint-enable no-inline-assembly */
}
