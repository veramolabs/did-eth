// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "./Eip712CheckerStorage.sol";

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/// @title Eip712CheckerInternal
/// @notice Contract with internal functions to assist in verifying signatures
/// @dev Based on the EIP-712 https://eips.ethereum.org/EIPS/eip-712
library Eip712CheckerInternal {
    bytes32 private constant EIP712_DOMAIN_TYPEHASH =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );

    /// @dev Returns the EIP-712 domain separator
    function _eip712Domain() internal view returns (bytes32) {
        Eip712CheckerStorage.Storage storage s = Eip712CheckerStorage
            .getStorage();

        return
            keccak256(
                abi.encode(
                    EIP712_DOMAIN_TYPEHASH,
                    s.name,
                    s.version,
                    block.chainid,
                    address(this)
                )
            );
    }

    /// @dev Recovers message signer and verifies if metches signatory
    /// @param signatory The signer to be verified
    /// @param message Hashed data payload
    /// @param signature Signed data payload
    function _verifySignature(
        address signatory,
        bytes32 message,
        bytes calldata signature
    ) internal view returns (bool success) {
        require(signatory != address(0), "ECDSA: zero signatory address");

        bytes32 msgHash = keccak256(
            abi.encodePacked("\x19\x01", _eip712Domain(), message)
        );

        return signatory == ECDSA.recover(msgHash, signature);
    }

    /// @dev Recovers message signer and verifies if metches signatory
    /// @param signatory The signer to be verified
    /// @param message Hashed data payload
    /// @param v Signature "v" value
    /// @param r Signature "r" value
    /// @param s Signature "s" value
    function _verifySignature(
        address signatory,
        bytes32 message,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal view returns (bool success) {
        require(signatory != address(0), "ECDSA: zero signatory address");

        bytes32 msgHash = keccak256(
            abi.encodePacked("\x19\x01", _eip712Domain(), message)
        );

        return signatory == ECDSA.recover(msgHash, v, r, s);
    }
}
