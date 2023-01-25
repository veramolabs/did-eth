// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "./Eip712CheckerStorage.sol";

import {DEFAULT_ADMIN_ROLE} from "../shared/Roles.sol";

import "@solidstate/contracts/access/access_control/AccessControlInternal.sol";

/// @title Eip712Checker
/// @notice Contract used for verifying signatures
/// @dev Based on the EIP-712 https://eips.ethereum.org/EIPS/eip-712
contract Eip712Checker is AccessControlInternal {
    /// @notice Sets name and version
    /// @param name Domain name
    /// @param version Domain version
    function initialize(
        string calldata name,
        string calldata version
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        Eip712CheckerStorage.Storage storage s = Eip712CheckerStorage
            .getStorage();

        s.name = keccak256(abi.encodePacked(name));
        s.version = keccak256(abi.encodePacked(version));
    }
}
