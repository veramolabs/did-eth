//SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

/// @title Eip712CheckerStorage
/// @notice Storage of the Eip712Checker contract
library Eip712CheckerStorage {
    bytes32 internal constant EIP712_CHECKER_STORAGE_SLOT =
        keccak256("DIDRegistry.eip712Checker.storage");

    struct Storage {
        bytes32 name;
        bytes32 version;
    }

    /* solhint-disable no-inline-assembly */
    function getStorage() internal pure returns (Storage storage s) {
        bytes32 slot = EIP712_CHECKER_STORAGE_SLOT;
        assembly {
            s.slot := slot
        }
    }
    /* solhint-enable no-inline-assembly */
}
