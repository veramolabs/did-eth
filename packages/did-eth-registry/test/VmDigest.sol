// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import { VmSafe } from "forge-std/Vm.sol";

/**
 * @title VmDigest
 * @dev Helper contract to sign data with VmSafe interface.  Not for production use!
 */
library VmDigest {
    /**
     * @dev Sign data with VmSafe interface.
     * @param _vm VmSafe interface
     * @param _identity Identity address
     * @param _registry DID Registry address
     * @param _privateKey Private key
     * @param _digestMessage Digest message
     * @param _ownerNonce Owner nonce
     * @return v Signature v
     * @return r Signature r
     * @return s Signature s
     */
    function signData(
        VmSafe _vm,
        address _identity,
        address _registry,
        bytes memory _privateKey,
        bytes memory _digestMessage,
        uint256 _ownerNonce
    )
        internal
        pure
        returns (
            uint8 v,
            bytes32 r,
            bytes32 s
        )
    {
        bytes32 digest = keccak256(
            abi.encodePacked(bytes1(0x19), bytes1(0), _registry, _ownerNonce, _identity, _digestMessage)
        );
        (v, r, s) = _vm.sign(toUint256(_privateKey), digest);
        return (v, r, s);
    }

    /**
     * @dev Convert bytes to uint256.  This is intended for test purposes only.
     * @param _bytes Bytes to convert
     * @return uint256
     */
    function toUint256(bytes memory _bytes) internal pure returns (uint256) {
        require(_bytes.length <= 32, "toUint256_outOfBounds");
        uint256 result;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            result := mload(add(_bytes, 0x20))
        }
        return result;
    }
}
