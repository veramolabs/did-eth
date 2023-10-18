// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

/**
 * @title EIP1056Registry
 * Specifies a did registry that implements EIP-1056
 * https://eips.ethereum.org/EIPS/eip-1056
 */
interface EIP1056Registry {
    event DIDOwnerChanged(address indexed identity, address owner, uint256 previousChange);

    /**
     * Delegation change event
     */
    event DIDDelegateChanged(
        address indexed identity,
        bytes32 delegateType,
        address delegate,
        uint256 validTo,
        uint256 previousChange
    );

    /**
     * Attribute change event
     */
    event DIDAttributeChanged(
        address indexed identity,
        bytes32 name,
        bytes value,
        uint256 validTo,
        uint256 previousChange
    );

    /**
     * Return the current owner of an identity.
     * @param identity The identity to check.
     * @return The address of the current owner.
     */
    function identityOwner(address identity) external view returns (address);

    /**
     * Return the current delegate of an identity for a specific delegate type.
     * @param identity The identity to check.
     * @param delegateType The type of the delegate.
     * @param delegate The address of the delegate.
     * @return bool The address of the current delegate.
     */
    function validDelegate(
        address identity,
        bytes32 delegateType,
        address delegate
    ) external view returns (bool);

    /**
     * change the current identity owner
     * @param identity address of the identity
     * @param newOwner address of the new owner
     */
    function changeOwner(address identity, address newOwner) external;

    /**
     * change the current identity owner
     * @param identity address of the identity
     * @param sigV signature V
     * @param sigR signature R
     * @param sigS signature S
     * @param newOwner address of the new owner
     */
    function changeOwnerSigned(
        address identity,
        uint8 sigV,
        bytes32 sigR,
        bytes32 sigS,
        address newOwner
    ) external;

    /**
     * add delegate to the identity
     * @param identity address of the identity
     * @param delegateType type of the delegate
     * @param delegate address of the delegate
     * @param validity validity of the delegate
     */
    function addDelegate(
        address identity,
        bytes32 delegateType,
        address delegate,
        uint256 validity
    ) external;

    /**
     * add delegate to the identity
     * @param identity address of the identity
     * @param sigV signature V
     * @param sigR signature R
     * @param sigS signature S
     * @param delegateType type of the delegate
     * @param delegate address of the delegate
     * @param validity expiration of the delegate in epoch seconds
     */
    function addDelegateSigned(
        address identity,
        uint8 sigV,
        bytes32 sigR,
        bytes32 sigS,
        bytes32 delegateType,
        address delegate,
        uint256 validity
    ) external;

    /**
     * revoke delegate from the identity
     * @param identity address of the identity
     * @param delegateType type of the delegate
     * @param delegate address of the delegate
     */
    function revokeDelegate(
        address identity,
        bytes32 delegateType,
        address delegate
    ) external;

    /**
     * revoke delegate from the identity
     * @param identity address of the identity
     * @param sigV signature V
     * @param sigR signature R
     * @param sigS signature S
     * @param delegateType type of the delegate
     * @param delegate address of the delegate
     */
    function revokeDelegateSigned(
        address identity,
        uint8 sigV,
        bytes32 sigR,
        bytes32 sigS,
        bytes32 delegateType,
        address delegate
    ) external;

    /**
     * set attribute of the identity
     * @param identity address of the identity
     * @param name name of the attribute
     * @param value value of the attribute
     * @param validity expiration of the attribute in epoch seconds
     */
    function setAttribute(
        address identity,
        bytes32 name,
        bytes memory value,
        uint256 validity
    ) external;

    /**
     * set attribute of the identity
     * @param identity address of the identity
     * @param sigV signature V
     * @param sigR signature R
     * @param sigS signature S
     * @param name name of the attribute
     * @param value value of the attribute
     * @param validity expiration of the attribute in epoch seconds
     */
    function setAttributeSigned(
        address identity,
        uint8 sigV,
        bytes32 sigR,
        bytes32 sigS,
        bytes32 name,
        bytes memory value,
        uint256 validity
    ) external;

    /**
     * revoke attribute from the identity
     * @param identity address of the identity
     * @param name name of the attribute
     * @param value value of the attribute
     */
    function revokeAttribute(
        address identity,
        bytes32 name,
        bytes memory value
    ) external;

    /**
     * revoke attribute from the identity
     * @param identity address of the identity
     * @param sigV signature V
     * @param sigR signature R
     * @param sigS signature S
     * @param name name of the attribute
     * @param value value of the attribute
     */
    function revokeAttributeSigned(
        address identity,
        uint8 sigV,
        bytes32 sigR,
        bytes32 sigS,
        bytes32 name,
        bytes memory value
    ) external;
}
