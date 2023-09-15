// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import { VmSafe } from "forge-std/Vm.sol";
import { Test } from "forge-std/Test.sol";

import { EthereumDIDRegistry } from "../contracts/EthereumDIDRegistry.sol";

import { VmDigest } from "./VmDigest.sol";

contract EthereumDIDRegistryDelegateTest is Test {
    event DIDAttributeChanged(
        address indexed identity,
        bytes32 name,
        bytes value,
        uint256 validTo,
        uint256 previousChange
    );

    EthereumDIDRegistry public registry;

    bytes internal constant PRIVATE_KEY = hex"a285ab66393c5fdda46d6fbad9e27fafd438254ab72ad5acb681a0e9f20f5d7b";
    address internal constant SIGNER = 0x2036C6CD85692F0Fb2C26E6c6B2ECed9e4478Dfd;

    bytes internal constant PRIVATE_KEY2 = hex"a285ab66393c5fdda46d6fbad9e27fafd438254ab72ad5acb681a0e9f20f5d7a";
    address internal constant SIGNER2 = 0xEA91e58E9Fa466786726F0a947e8583c7c5B3185;

    function setUp() public {
        registry = new EthereumDIDRegistry();
    }

    function testSetAttributeChangedTransactionBlock() public {
        vm.prank(SIGNER);
        registry.setAttribute(SIGNER, "key", "value", 1 weeks);
        assertEq(registry.changed(SIGNER), block.number);
    }

    function testSetAttributeExpectAttributeChangedEvent() public {
        vm.expectEmit();
        emit DIDAttributeChanged(SIGNER, "key", "value", 1 weeks + 1, 0);
        vm.prank(SIGNER);
        registry.setAttribute(SIGNER, "key", "value", 1 weeks);
    }

    function testSetAttributeExpectAttributeChangeOwner() public {
        vm.prank(SIGNER);
        registry.changeOwner(SIGNER, SIGNER2);
        vm.expectEmit();
        emit DIDAttributeChanged(SIGNER, "key", "value", 1 weeks + 1, block.number);
        vm.prank(SIGNER2);
        registry.setAttribute(SIGNER, "key", "value", 1 weeks);
    }

    function testSetAttributeExpectAttributeChangeOwnerAsBadActor() public {
        vm.prank(SIGNER);
        registry.changeOwner(SIGNER, SIGNER2);
        vm.prank(SIGNER);
        vm.expectRevert("bad_actor");
        registry.setAttribute(SIGNER, "key", "value", 1 weeks);
    }

    function testSetAttributeSpoofingOwnerAsBadActor() public {
        vm.prank(SIGNER2);
        vm.expectRevert("bad_actor");
        registry.setAttribute(SIGNER, "key", "value", 1 weeks);
    }

    function testSetAttributeSignedChangedTransactionBlock() public {
        (uint8 v, bytes32 r, bytes32 s) = signAttribute(SIGNER, address(registry), "key", "value", PRIVATE_KEY);
        registry.setAttributeSigned(SIGNER, v, r, s, "key", "value", 1 weeks);
        assertEq(registry.changed(SIGNER), block.number);
    }

    function testSetAttributeSignedChangeOwnerExpectDIDAttributeChanged() public {
        vm.prank(SIGNER);
        registry.changeOwner(SIGNER, SIGNER2);
        vm.expectEmit();
        emit DIDAttributeChanged(SIGNER, "key", "value", 1 weeks + 1, block.number);
        (uint8 v, bytes32 r, bytes32 s) = signAttribute(
            SIGNER,
            SIGNER2,
            address(registry),
            "key",
            "value",
            PRIVATE_KEY2
        );
        registry.setAttributeSigned(SIGNER, v, r, s, "key", "value", 1 weeks);
    }

    function testSetAttributeSignedSpoofingSignature() public {
        (uint8 v, bytes32 r, bytes32 s) = signAttribute(SIGNER, address(registry), "key", "value", PRIVATE_KEY2);
        vm.expectRevert("bad_signature");
        registry.setAttributeSigned(SIGNER, v, r, s, "key", "value", 1 weeks);
    }

    function testSetAttributeSignedWrongSignatureKey() public {
        (uint8 v, bytes32 r, bytes32 s) = signAttribute(SIGNER, address(registry), "key1", "value", PRIVATE_KEY);
        vm.expectRevert("bad_signature");
        registry.setAttributeSigned(SIGNER, v, r, s, "key", "value", 1 weeks);
    }

    function testSetAttributeSignedWrongNonce() public {
        bytes memory message = abi.encodePacked(bytes("setAttribute"), "key", "value", uint256(1 weeks));
        address idOwner = registry.identityOwner(SIGNER);
        uint256 ownerNonce = registry.nonce(idOwner) + 1; // not expected
        (uint8 v, bytes32 r, bytes32 s) = VmDigest.signData(
            vm,
            SIGNER,
            address(registry),
            PRIVATE_KEY,
            message,
            ownerNonce
        );
        vm.expectRevert("bad_signature");
        registry.setAttributeSigned(SIGNER, v, r, s, "key", "value", 1 weeks);
    }

    function testRevokeAttribute() public {
        uint256 startBlock = block.number;
        vm.prank(SIGNER);
        registry.setAttribute(SIGNER, "key", "value", 1 weeks);
        assertEq(registry.changed(SIGNER), block.number);
        vm.roll(block.number + 100);
        assertNotEq(startBlock, block.number);
        vm.prank(SIGNER);
        registry.revokeAttribute(SIGNER, "key", "value");
        assertEq(registry.changed(SIGNER), block.number);
    }

    function testRevokeAttributeExpectDIDAttributeChanged() public {
        vm.prank(SIGNER);
        registry.setAttribute(SIGNER, "key", "value", 1 weeks);
        vm.expectEmit();
        emit DIDAttributeChanged(SIGNER, "key", "value", 0, block.number);
        vm.prank(SIGNER);
        registry.revokeAttribute(SIGNER, "key", "value");
    }

    function testRevokeAttributeChangeOwnerExpectDIDAttributeChanged() public {
        vm.prank(SIGNER);
        registry.setAttribute(SIGNER, "key", "value", 1 weeks);
        vm.prank(SIGNER);
        registry.changeOwner(SIGNER, SIGNER2);
        vm.expectEmit();
        emit DIDAttributeChanged(SIGNER, "key", "value", 0, block.number);
        vm.prank(SIGNER2);
        registry.revokeAttribute(SIGNER, "key", "value");
    }

    function testRevokeAttributeAsBadActor() public {
        vm.prank(SIGNER);
        registry.setAttribute(SIGNER, "key", "value", 1 weeks);
        vm.expectRevert("bad_actor");
        vm.prank(SIGNER2);
        registry.revokeAttribute(SIGNER, "key", "value");
    }

    function testRevokeAttributeChangeOwnerAsBadActor() public {
        vm.prank(SIGNER);
        registry.setAttribute(SIGNER, "key", "value", 1 weeks);
        vm.prank(SIGNER);
        registry.changeOwner(SIGNER, SIGNER2);
        vm.expectRevert("bad_actor");
        vm.prank(SIGNER);
        registry.revokeAttribute(SIGNER, "key", "value");
    }

    function testRevokeAttributeSignedExpectDIDAttributeChanged() public {
        vm.prank(SIGNER);
        registry.setAttribute(SIGNER, "key", "value", 1 weeks);
        (uint8 v, bytes32 r, bytes32 s) = signRevoke(SIGNER, address(registry), "key", "value", PRIVATE_KEY);
        vm.expectEmit();
        emit DIDAttributeChanged(SIGNER, "key", "value", 0, block.number);
        registry.revokeAttributeSigned(SIGNER, v, r, s, "key", "value");
    }

    function testRevokeAttributeSignedChangedBlockNumber() public {
        uint256 startBlock = block.number;
        vm.prank(SIGNER);
        registry.setAttribute(SIGNER, "key", "value", 1 weeks);
        (uint8 v, bytes32 r, bytes32 s) = signRevoke(SIGNER, address(registry), "key", "value", PRIVATE_KEY);
        vm.roll(block.number + 100);
        assertNotEq(startBlock, block.number);
        registry.revokeAttributeSigned(SIGNER, v, r, s, "key", "value");
        assertEq(registry.changed(SIGNER), block.number);
    }

    function testRevokeAttributeSignedWithBadSignature() public {
        vm.prank(SIGNER);
        registry.setAttribute(SIGNER, "key", "value", 1 weeks);
        (uint8 v, bytes32 r, bytes32 s) = signRevoke(SIGNER, address(registry), "key", "value", PRIVATE_KEY2);
        vm.expectRevert("bad_signature");
        registry.revokeAttributeSigned(SIGNER, v, r, s, "key", "value");
    }

    function testRevokeAttributeSignedWithWrongSignature() public {
        vm.prank(SIGNER);
        registry.setAttribute(SIGNER, "key", "value", 1 weeks);
        (uint8 v, bytes32 r, bytes32 s) = signRevoke(SIGNER, address(registry), "key2", "value", PRIVATE_KEY);
        vm.expectRevert("bad_signature");
        registry.revokeAttributeSigned(SIGNER, v, r, s, "key", "value");
    }

    function testRevokeAttributeSignedChangeOriginalOwnerBadSignature() public {
        vm.prank(SIGNER);
        registry.setAttribute(SIGNER, "key", "value", 1 weeks);
        vm.prank(SIGNER);
        registry.changeOwner(SIGNER, SIGNER2);
        (uint8 v, bytes32 r, bytes32 s) = signRevoke(SIGNER, address(registry), "key2", "value", PRIVATE_KEY);
        vm.expectRevert("bad_signature");
        registry.revokeAttributeSigned(SIGNER, v, r, s, "key", "value");
    }

    function testRevokeAttributeSignedChangedOwnerExpectDIDAttributeChanged() public {
        vm.prank(SIGNER);
        registry.setAttribute(SIGNER, "key", "value", 1 weeks);
        vm.prank(SIGNER);
        registry.changeOwner(SIGNER, SIGNER2);
        (uint8 v, bytes32 r, bytes32 s) = signRevoke(SIGNER, SIGNER2, address(registry), "key", "value", PRIVATE_KEY2);
        vm.expectEmit();
        emit DIDAttributeChanged(SIGNER, "key", "value", 0, block.number);
        registry.revokeAttributeSigned(SIGNER, v, r, s, "key", "value");
    }

    /**
     * @dev Sign data with a private key
     * @param _identity Identity address
     * @param _delegate Delegate address
     * @param _registry DID Registry address
     * @param _privateKey Private key
     * @param _message Message to sign
     * @return v Signature v
     * @return r Signature r
     * @return s Signature s
     */
    function signData(
        address _identity,
        address _delegate,
        address _registry,
        bytes memory _privateKey,
        bytes memory _message
    )
        internal
        view
        returns (
            uint8 v,
            bytes32 r,
            bytes32 s
        )
    {
        address idOwner = registry.identityOwner(_delegate);
        uint256 ownerNonce = registry.nonce(idOwner);
        return VmDigest.signData(vm, _identity, _registry, _privateKey, _message, ownerNonce);
    }

    /**
     * @dev Sign attribute with a private key
     * @param _identity Identity address
     * @param _registry DID Registry address
     * @param _key Attribute key
     * @param _value Attribute value
     * @param _privateKey Private key
     * @return v Signature v
     * @return r Signature r
     * @return s Signature s
     */
    function signAttribute(
        address _identity,
        address _registry,
        bytes32 _key,
        bytes memory _value,
        bytes memory _privateKey
    )
        internal
        view
        returns (
            uint8 v,
            bytes32 r,
            bytes32 s
        )
    {
        bytes memory message = abi.encodePacked(bytes("setAttribute"), _key, _value, uint256(1 weeks));
        return signData(_identity, _identity, _registry, _privateKey, message);
    }

    /**
     * @dev Sign attribute with a private key
     * @param _identity Identity address
     * @param _registry DID Registry address
     * @param _key Attribute key
     * @param _value Attribute value
     * @param _privateKey Private key
     * @return v Signature v
     * @return r Signature r
     * @return s Signature s
     */
    function signAttribute(
        address _identity,
        address _delegate,
        address _registry,
        bytes32 _key,
        bytes memory _value,
        bytes memory _privateKey
    )
        internal
        view
        returns (
            uint8 v,
            bytes32 r,
            bytes32 s
        )
    {
        bytes memory message = abi.encodePacked(bytes("setAttribute"), _key, _value, uint256(1 weeks));
        return signData(_identity, _delegate, _registry, _privateKey, message);
    }

    /**
     * @dev Sign revoke with a private key
     * @param _identity Identity address
     * @param _registry DID Registry address
     * @param _key Attribute key
     * @param _value Attribute value
     * @param _privateKey Private key
     * @return v Signature v
     * @return r Signature r
     * @return s Signature s
     */
    function signRevoke(
        address _identity,
        address _registry,
        bytes32 _key,
        bytes memory _value,
        bytes memory _privateKey
    )
        internal
        view
        returns (
            uint8 v,
            bytes32 r,
            bytes32 s
        )
    {
        bytes memory message = abi.encodePacked(bytes("revokeAttribute"), _key, _value);
        return signData(_identity, _identity, _registry, _privateKey, message);
    }

    /**
     * @dev Sign revoke with a private key
     * @param _identity Identity address
     * @param _registry DID Registry address
     * @param _key Attribute key
     * @param _value Attribute value
     * @param _privateKey Private key
     * @return v Signature v
     * @return r Signature r
     * @return s Signature s
     */
    function signRevoke(
        address _identity,
        address _delegate,
        address _registry,
        bytes32 _key,
        bytes memory _value,
        bytes memory _privateKey
    )
        internal
        view
        returns (
            uint8 v,
            bytes32 r,
            bytes32 s
        )
    {
        bytes memory message = abi.encodePacked(bytes("revokeAttribute"), _key, _value);
        return signData(_identity, _delegate, _registry, _privateKey, message);
    }
}
