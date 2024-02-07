// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { IAccessControl } from "@openzeppelin/contracts/access/IAccessControl.sol";
import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { Initializable } from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import { IERC165 } from "@openzeppelin/contracts/interfaces/IERC165.sol";
import { ERC165 } from "@openzeppelin/contracts/utils/introspection/ERC165.sol";

import { EIP1056Registry } from "./EIP1056Registry.sol";

/**
 * @title DIDRegistry
 * @dev The DIDRegistry contract is a registry of decentralized identifiers (DIDs) and their attributes.
 */
contract DIDRegistry is EIP1056Registry, Initializable, UUPSUpgradeable, AccessControl {
    bytes32 public constant REGISTRY_ADMIN_ROLE = keccak256("REGISTRY_ADMIN_ROLE");

    mapping(address => address) public owners;
    mapping(address => mapping(bytes32 => mapping(address => uint256))) public delegates;
    mapping(address => uint256) public changed;
    mapping(address => uint256) public nonce;

    modifier onlyOwner(address identity, address actor) {
        require(actor == identityOwner(identity), "bad_actor");
        _;
    }

    /// @dev constructor is forbidden for upgradeable contracts
    constructor() {
        _disableInitializers();
    }

    /// @dev initializer is required for proxy contracts
    function initialize(address _roleAdmin) public initializer {
        _grantRole(DEFAULT_ADMIN_ROLE, _roleAdmin);
    }

    /**
     * Return the current owner of an identity.
     * @param identity The identity to check.
     * @return The address of the current owner.
     */
    function identityOwner(address identity) public view returns (address) {
        address owner = owners[identity];
        if (owner != address(0x00)) {
            return owner;
        }
        return identity;
    }

    /**
     * Determines if a specific address is currently listed as a delegate for a given identity and type of delegation.
     * @param identity - The identity to check.
     * @param delegateType - The type of the delegation being checked.
     * @param delegate - The address of the delegate.
     * @return bool - true if the delegation is currently valid, false otherwise.
     */
    function validDelegate(
        address identity,
        bytes32 delegateType,
        address delegate
    ) public view returns (bool) {
        uint256 validity = delegates[identity][keccak256(abi.encode(delegateType))][delegate];
        return (validity > block.timestamp);
    }

    /**
     * change the current identity owner
     * @param identity address of the identity
     * @param newOwner address of the new owner
     */
    function changeOwner(address identity, address newOwner) public {
        _changeOwner(identity, msg.sender, newOwner);
    }

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
    ) public {
        bytes32 digest = keccak256(
            abi.encodePacked(
                bytes1(0x19),
                bytes1(0),
                this,
                nonce[identityOwner(identity)],
                identity,
                "changeOwner",
                newOwner
            )
        );
        _changeOwner(identity, _checkSignature(identity, sigV, sigR, sigS, digest), newOwner);
    }

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
    ) public {
        _addDelegate(identity, msg.sender, delegateType, delegate, validity);
    }

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
    ) public {
        bytes32 digest = keccak256(
            abi.encodePacked(
                bytes1(0x19),
                bytes1(0),
                this,
                nonce[identityOwner(identity)],
                identity,
                "addDelegate",
                delegateType,
                delegate,
                validity
            )
        );
        _addDelegate(identity, _checkSignature(identity, sigV, sigR, sigS, digest), delegateType, delegate, validity);
    }

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
    ) public {
        _revokeDelegate(identity, msg.sender, delegateType, delegate);
    }

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
    ) public {
        bytes32 digest = keccak256(
            abi.encodePacked(
                bytes1(0x19),
                bytes1(0),
                this,
                nonce[identityOwner(identity)],
                identity,
                "revokeDelegate",
                delegateType,
                delegate
            )
        );
        _revokeDelegate(identity, _checkSignature(identity, sigV, sigR, sigS, digest), delegateType, delegate);
    }

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
    ) public {
        _setAttribute(identity, msg.sender, name, value, validity);
    }

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
    ) public {
        bytes32 digest = keccak256(
            abi.encodePacked(
                bytes1(0x19),
                bytes1(0),
                this,
                nonce[identityOwner(identity)],
                identity,
                "setAttribute",
                name,
                value,
                validity
            )
        );
        _setAttribute(identity, _checkSignature(identity, sigV, sigR, sigS, digest), name, value, validity);
    }

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
    ) public {
        _revokeAttribute(identity, msg.sender, name, value);
    }

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
    ) public {
        bytes32 digest = keccak256(
            abi.encodePacked(
                bytes1(0x19),
                bytes1(0),
                this,
                nonce[identityOwner(identity)],
                identity,
                "revokeAttribute",
                name,
                value
            )
        );
        _revokeAttribute(identity, _checkSignature(identity, sigV, sigR, sigS, digest), name, value);
    }

    /**
     * @notice authorize code upgrade or revert
     * @dev required by UUPSUpgradeable
     */
    // solhint-disable-next-line no-empty-blocks
    function _authorizeUpgrade(address) internal override onlyRole(REGISTRY_ADMIN_ROLE) {}

    /**
     * @dev required by ERC165
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControl) returns (bool) {
        return
            interfaceId == type(EIP1056Registry).interfaceId ||
            interfaceId == type(IAccessControl).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev check signature of the owner
     * @param identity address of the identity
     * @param sigV signature V
     * @param sigR signature R
     * @param sigS signature S
     * @param digest digest of the message
     */
    function _checkSignature(
        address identity,
        uint8 sigV,
        bytes32 sigR,
        bytes32 sigS,
        bytes32 digest
    ) internal returns (address) {
        address signer = ecrecover(digest, sigV, sigR, sigS);
        require(signer == identityOwner(identity), "bad_signature");
        nonce[signer]++;
        return signer;
    }

    /**
     * @dev change owner of the identity
     * @param identity address of the identity
     * @param actor address of the actor
     * @param newOwner address of the new owner
     */
    function _changeOwner(
        address identity,
        address actor,
        address newOwner
    ) internal onlyOwner(identity, actor) {
        owners[identity] = newOwner;
        emit DIDOwnerChanged(identity, newOwner, changed[identity]);
        changed[identity] = block.number;
    }

    /**
     * @dev add delegate to the identity
     * @param identity address of the identity
     * @param actor address of the actor
     * @param delegateType type of the delegate
     * @param delegate address of the delegate
     * @param validity expiration of the delegate in epoch seconds
     */
    function _addDelegate(
        address identity,
        address actor,
        bytes32 delegateType,
        address delegate,
        uint256 validity
    ) internal onlyOwner(identity, actor) {
        delegates[identity][keccak256(abi.encode(delegateType))][delegate] = block.timestamp + validity;
        emit DIDDelegateChanged(identity, delegateType, delegate, block.timestamp + validity, changed[identity]);
        changed[identity] = block.number;
    }

    /**
     * @dev revoke delegate from the identity
     * @param identity address of the identity
     * @param actor address of the actor
     * @param delegateType type of the delegate
     * @param delegate address of the delegate
     */
    function _revokeDelegate(
        address identity,
        address actor,
        bytes32 delegateType,
        address delegate
    ) internal onlyOwner(identity, actor) {
        delegates[identity][keccak256(abi.encode(delegateType))][delegate] = block.timestamp;
        emit DIDDelegateChanged(identity, delegateType, delegate, block.timestamp, changed[identity]);
        changed[identity] = block.number;
    }

    /**
     * @dev set attribute of the identity
     * @param identity address of the identity
     * @param actor address of the actor
     * @param name name of the attribute
     * @param value value of the attribute
     * @param validity expiration of the attribute in epoch seconds
     */
    function _setAttribute(
        address identity,
        address actor,
        bytes32 name,
        bytes memory value,
        uint256 validity
    ) internal onlyOwner(identity, actor) {
        emit DIDAttributeChanged(identity, name, value, block.timestamp + validity, changed[identity]);
        changed[identity] = block.number;
    }

    /**
     * @dev revoke attribute from the identity
     * @param identity address of the identity
     * @param actor address of the actor
     * @param name name of the attribute
     * @param value value of the attribute
     */
    function _revokeAttribute(
        address identity,
        address actor,
        bytes32 name,
        bytes memory value
    ) internal onlyOwner(identity, actor) {
        emit DIDAttributeChanged(identity, name, value, 0, changed[identity]);
        changed[identity] = block.number;
    }
}
