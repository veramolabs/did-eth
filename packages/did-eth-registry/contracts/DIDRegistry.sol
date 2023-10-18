/* SPDX-License-Identifier: MIT */

pragma solidity ^0.8.15;

/**
 * @title DIDRegistry
 * @dev The DIDRegistry contract is a registry of decentralized identifiers (DIDs) and their attributes.
 */
contract DIDRegistry {
    mapping(address => address) public owners;
    mapping(address => mapping(bytes32 => mapping(address => uint256))) public delegates;
    mapping(address => uint256) public changed;
    mapping(address => uint256) public nonce;

    modifier onlyOwner(address identity, address actor) {
        require(actor == identityOwner(identity), "bad_actor");
        _;
    }

    event DIDOwnerChanged(address indexed identity, address owner, uint256 previousChange);

    event DIDDelegateChanged(
        address indexed identity,
        bytes32 delegateType,
        address delegate,
        uint256 validTo,
        uint256 previousChange
    );

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
    function identityOwner(address identity) public view returns (address) {
        address owner = owners[identity];
        if (owner != address(0x00)) {
            return owner;
        }
        return identity;
    }

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
        changeOwner(identity, msg.sender, newOwner);
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
        changeOwner(identity, checkSignature(identity, sigV, sigR, sigS, digest), newOwner);
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
        addDelegate(identity, msg.sender, delegateType, delegate, validity);
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
        addDelegate(identity, checkSignature(identity, sigV, sigR, sigS, digest), delegateType, delegate, validity);
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
        revokeDelegate(identity, msg.sender, delegateType, delegate);
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
        revokeDelegate(identity, checkSignature(identity, sigV, sigR, sigS, digest), delegateType, delegate);
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
        setAttribute(identity, msg.sender, name, value, validity);
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
        setAttribute(identity, checkSignature(identity, sigV, sigR, sigS, digest), name, value, validity);
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
        revokeAttribute(identity, msg.sender, name, value);
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
        revokeAttribute(identity, checkSignature(identity, sigV, sigR, sigS, digest), name, value);
    }

    /**
     * @dev check signature of the owner
     * @param identity address of the identity
     * @param sigV signature V
     * @param sigR signature R
     * @param sigS signature S
     * @param digest digest of the message
     */
    function checkSignature(
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
    function changeOwner(
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
    function addDelegate(
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
    function revokeDelegate(
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
    function setAttribute(
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
    function revokeAttribute(
        address identity,
        address actor,
        bytes32 name,
        bytes memory value
    ) internal onlyOwner(identity, actor) {
        emit DIDAttributeChanged(identity, name, value, 0, changed[identity]);
        changed[identity] = block.number;
    }
}
