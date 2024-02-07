// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { VmSafe } from "forge-std/Vm.sol";
import { Test } from "forge-std/Test.sol";

import { DIDRegistry } from "../contracts/DIDRegistry.sol";

import { VmDigest } from "./VmDigest.sol";

contract DIDRegistryDelegateTest is Test {
    event DIDDelegateChanged(
        address indexed identity,
        bytes32 delegateType,
        address delegate,
        uint256 validTo,
        uint256 previousChange
    );

    DIDRegistry public registry;

    bytes internal constant PRIVATE_KEY = hex"a285ab66393c5fdda46d6fbad9e27fafd438254ab72ad5acb681a0e9f20f5d7b";
    address internal constant SIGNER = 0x2036C6CD85692F0Fb2C26E6c6B2ECed9e4478Dfd;

    bytes internal constant PRIVATE_KEY2 = hex"a285ab66393c5fdda46d6fbad9e27fafd438254ab72ad5acb681a0e9f20f5d7a";
    address internal constant SIGNER2 = 0xEA91e58E9Fa466786726F0a947e8583c7c5B3185;

    address internal constant SIGNER3 = address(0x1111);

    function setUp() public {
        registry = new DIDRegistry();
    }

    function testAddDelegate() public {
        vm.prank(SIGNER);
        registry.addDelegate(SIGNER, "attestor", SIGNER2, 1 days);
        bool isDelegate = registry.validDelegate(SIGNER, "attestor", SIGNER2);
        assertTrue(isDelegate);
    }

    function testAddDelegateExpires() public {
        vm.prank(SIGNER);
        registry.addDelegate(SIGNER, "attestor", SIGNER2, 1 days);
        assertTrue(registry.validDelegate(SIGNER, "attestor", SIGNER2));
        vm.warp(1 days + 1);
        assertFalse(registry.validDelegate(SIGNER, "attestor", SIGNER2));
    }

    function testAddDelegateNotADelegateForIdentity() public {
        bool isDelegate = registry.validDelegate(SIGNER, "attestor", SIGNER2);
        assertFalse(isDelegate, "should not be a delegate");
        vm.prank(SIGNER);
        registry.addDelegate(SIGNER, "attestor", SIGNER2, 1 days);
        isDelegate = registry.validDelegate(SIGNER, "attestor", SIGNER3);
        assertFalse(isDelegate, "should not be a delegate");
    }

    function testAddDelegateExpectTransactionBlock() public {
        vm.prank(SIGNER);
        registry.addDelegate(SIGNER, "attestor", SIGNER2, 1 days);
        uint256 transactionBlock = registry.changed(SIGNER);
        assertEq(block.number, transactionBlock, "should record block number");
    }

    function testAddDelegateEventEmit() public {
        vm.expectEmit();
        emit DIDDelegateChanged(SIGNER, "attestor", SIGNER2, 1 days + 1, 0);
        vm.prank(SIGNER);
        registry.addDelegate(SIGNER, "attestor", SIGNER2, 1 days);
    }

    function testAddDelegateDoesNotChangeOwner() public {
        assertEq(registry.owners(SIGNER), address(0x0));
        vm.prank(SIGNER);
        registry.addDelegate(SIGNER, "attestor", SIGNER2, 1 days);
        assertEq(registry.owners(SIGNER), address(0x0));
    }

    function testAddDelegateAsBadActor() public {
        vm.prank(SIGNER);
        vm.expectRevert("bad_actor");
        registry.addDelegate(SIGNER2, "attestor", SIGNER3, 1 days);
    }

    function testAddDelegateOwnerChangedBadActor() public {
        vm.prank(SIGNER);
        registry.changeOwner(SIGNER, SIGNER3);
        assertEq(registry.owners(SIGNER), SIGNER3);
        vm.expectRevert("bad_actor");
        vm.prank(SIGNER);
        registry.addDelegate(SIGNER, "attestor", SIGNER2, 1 days);
    }

    function testAddDelegateSigned() public {
        (uint8 v, bytes32 r, bytes32 s) = signDelegate(SIGNER, SIGNER2, address(registry), PRIVATE_KEY);
        registry.addDelegateSigned(SIGNER, v, r, s, "attestor", SIGNER2, 1 days);
        assertTrue(registry.validDelegate(SIGNER, "attestor", SIGNER2));
    }

    function testAddDelegateSignedChangeOwnerBadSignature() public {
        vm.prank(SIGNER);
        registry.changeOwner(SIGNER, SIGNER3);
        assertEq(registry.owners(SIGNER), SIGNER3);
        (uint8 v, bytes32 r, bytes32 s) = signDelegate(SIGNER, SIGNER2, address(registry), PRIVATE_KEY);
        vm.expectRevert("bad_signature");
        registry.addDelegateSigned(SIGNER, v, r, s, "attestor", SIGNER2, 1 days);
    }

    function testAddDelegateSignedExpires() public {
        (uint8 v, bytes32 r, bytes32 s) = signDelegate(SIGNER, SIGNER2, address(registry), PRIVATE_KEY);
        registry.addDelegateSigned(SIGNER, v, r, s, "attestor", SIGNER2, 1 days);
        assertTrue(registry.validDelegate(SIGNER, "attestor", SIGNER2));
        vm.warp(1 days + 1);
        assertFalse(registry.validDelegate(SIGNER, "attestor", SIGNER2));
    }

    function testAddDelegateSignedBadSignatureKey() public {
        (uint8 v, bytes32 r, bytes32 s) = signDelegate(SIGNER, SIGNER2, address(registry), PRIVATE_KEY);
        vm.expectRevert("bad_signature");
        registry.addDelegateSigned(SIGNER2, v, r, s, "attestor", SIGNER2, 1 days);
    }

    function testAddDelegateSignedWrongSignature() public {
        (uint8 v, bytes32 r, bytes32 s) = signDelegate(SIGNER, SIGNER2, address(registry), PRIVATE_KEY2);
        vm.expectRevert("bad_signature");
        registry.addDelegateSigned(SIGNER, v, r, s, "attestor", SIGNER2, 1 days);
    }

    function testAddDelegateSignedWrongSignatureData() public {
        (uint8 v, bytes32 r, bytes32 s) = signDelegate(SIGNER, SIGNER, address(registry), PRIVATE_KEY);
        vm.expectRevert("bad_signature");
        registry.addDelegateSigned(SIGNER, v, r, s, "attestor", SIGNER2, 1 days);
    }

    function testAddDelegateSignedChangedBlockNumber() public {
        (uint8 v, bytes32 r, bytes32 s) = signDelegate(SIGNER, SIGNER2, address(registry), PRIVATE_KEY);
        registry.addDelegateSigned(SIGNER, v, r, s, "attestor", SIGNER2, 1 days);
        uint256 transactionBlock = registry.changed(SIGNER);
        assertEq(block.number, transactionBlock, "should record block number");
    }

    function testAddDelegateSignedExpectDelegateChangedEvent() public {
        (uint8 v, bytes32 r, bytes32 s) = signDelegate(SIGNER, SIGNER2, address(registry), PRIVATE_KEY);
        vm.expectEmit();
        emit DIDDelegateChanged(SIGNER, "attestor", SIGNER2, 1 days + 1, 0);
        registry.addDelegateSigned(SIGNER, v, r, s, "attestor", SIGNER2, 1 days);
    }

    function testAddDelegateSignedExpectNonce() public {
        (uint8 v, bytes32 r, bytes32 s) = signDelegate(SIGNER, SIGNER2, address(registry), PRIVATE_KEY);
        registry.addDelegateSigned(SIGNER, v, r, s, "attestor", SIGNER2, 1 days);
        uint256 nonce = registry.nonce(SIGNER);
        assertEq(nonce, 1, "should increment nonce");
    }

    function testAddDelegateSignedNonceIncorrect() public {
        bytes memory message = abi.encodePacked(bytes("addDelegate"), bytes32("attestor"), SIGNER2, uint256(1 days));
        address idOwner = registry.identityOwner(SIGNER2);
        uint256 ownerNonce = registry.nonce(idOwner) + 0x1; // not expected
        (uint8 v, bytes32 r, bytes32 s) = VmDigest.signData(
            vm,
            SIGNER,
            address(registry),
            PRIVATE_KEY,
            message,
            ownerNonce
        );
        vm.expectRevert("bad_signature");
        registry.addDelegateSigned(SIGNER, v, r, s, "attestor", SIGNER2, 1 days);
    }

    function testRevokeDelegate() public {
        vm.prank(SIGNER);
        registry.addDelegate(SIGNER, "attestor", SIGNER2, 1 days);
        assertTrue(registry.validDelegate(SIGNER, "attestor", SIGNER2));
        vm.prank(SIGNER);
        registry.revokeDelegate(SIGNER, "attestor", SIGNER2);
        assertFalse(registry.validDelegate(SIGNER, "attestor", SIGNER2));
    }

    function testRevokeDelegateChangeOwner() public {
        vm.prank(SIGNER);
        registry.changeOwner(SIGNER, SIGNER3);
        vm.prank(SIGNER3);
        registry.addDelegate(SIGNER, "attestor", SIGNER2, 1 days);
        assertTrue(registry.validDelegate(SIGNER, "attestor", SIGNER2));
        vm.prank(SIGNER3);
        registry.revokeDelegate(SIGNER, "attestor", SIGNER2);
        assertFalse(registry.validDelegate(SIGNER, "attestor", SIGNER2));
    }

    function testRevokeDelegateChangeOwnerAsBadActor() public {
        vm.prank(SIGNER);
        registry.changeOwner(SIGNER, SIGNER3);
        vm.prank(SIGNER3);
        registry.addDelegate(SIGNER, "attestor", SIGNER2, 1 days);
        assertTrue(registry.validDelegate(SIGNER, "attestor", SIGNER2));
        vm.expectRevert("bad_actor");
        vm.prank(SIGNER);
        registry.revokeDelegate(SIGNER, "attestor", SIGNER2);
    }

    function testRevokeDelegateChangedTransactionBlock() public {
        vm.prank(SIGNER);
        registry.addDelegate(SIGNER, "attestor", SIGNER2, 1 days);
        uint256 startBlock = block.number;
        assertEq(block.number, registry.changed(SIGNER), "should record block number");
        vm.roll(block.number + 100);
        vm.prank(SIGNER);
        registry.revokeDelegate(SIGNER, "attestor", SIGNER2);
        assertEq(block.number, registry.changed(SIGNER), "should record block number");
        assertNotEq(startBlock, block.number, "block number must be different across calls");
    }

    function testRevokeDelegateExpectDelegateChangedEvent() public {
        vm.prank(SIGNER);
        uint256 startBlock = block.number;
        uint256 startTime = block.timestamp;
        registry.addDelegate(SIGNER, "attestor", SIGNER2, 1 days);
        vm.expectEmit();
        emit DIDDelegateChanged(SIGNER, "attestor", SIGNER2, startTime, startBlock);
        vm.prank(SIGNER);
        registry.revokeDelegate(SIGNER, "attestor", SIGNER2);
    }

    function testRevokeDelegateBadDelegate() public {
        vm.prank(SIGNER);
        registry.addDelegate(SIGNER, "attestor", SIGNER2, 1 days);
        vm.expectRevert("bad_actor");
        vm.prank(SIGNER2);
        registry.revokeDelegate(SIGNER, "attestor", SIGNER3);
    }

    function testRevokeDelegateSigned() public {
        vm.prank(SIGNER);
        registry.addDelegate(SIGNER, "attestor", SIGNER2, 1 days);
        assertTrue(registry.validDelegate(SIGNER, "attestor", SIGNER2));
        (uint8 v, bytes32 r, bytes32 s) = signRevoke(SIGNER, SIGNER2, address(registry), PRIVATE_KEY);
        registry.revokeDelegateSigned(SIGNER, v, r, s, "attestor", SIGNER2);
        assertFalse(registry.validDelegate(SIGNER, "attestor", SIGNER2));
    }

    function testRevokeDelegateSignedTransactionBlockIsChanged() public {
        uint256 startBlock = block.number;
        vm.prank(SIGNER);
        registry.addDelegate(SIGNER, "attestor", SIGNER2, 1 days);
        assertEq(block.number, registry.changed(SIGNER), "add should record block number");
        vm.roll(block.number + 100);
        (uint8 v, bytes32 r, bytes32 s) = signRevoke(SIGNER, SIGNER2, address(registry), PRIVATE_KEY);
        registry.revokeDelegateSigned(SIGNER, v, r, s, "attestor", SIGNER2);
        assertEq(block.number, registry.changed(SIGNER), "revoke should record block number");
        assertNotEq(block.number, startBlock, "block number must be different across calls");
    }

    function testRevokeDelegateSignedDelegateChangedEvent() public {
        uint256 startBlock = block.number;
        uint256 startTime = block.timestamp;
        vm.prank(SIGNER);
        registry.addDelegate(SIGNER, "attestor", SIGNER2, 1 days);
        vm.expectEmit();
        emit DIDDelegateChanged(SIGNER, "attestor", SIGNER2, startTime, startBlock);
        (uint8 v, bytes32 r, bytes32 s) = signRevoke(SIGNER, SIGNER2, address(registry), PRIVATE_KEY);
        registry.revokeDelegateSigned(SIGNER, v, r, s, "attestor", SIGNER2);
    }

    function testRevokeDelegateSignedBadSignature() public {
        vm.prank(SIGNER);
        registry.addDelegate(SIGNER, "attestor", SIGNER2, 1 days);
        (uint8 v, bytes32 r, bytes32 s) = signRevoke(SIGNER, SIGNER2, address(registry), PRIVATE_KEY);
        vm.expectRevert("bad_signature");
        registry.revokeDelegateSigned(SIGNER, v, r, s, "attestor", SIGNER3);
        vm.expectRevert("bad_signature");
        registry.revokeDelegateSigned(SIGNER3, v, r, s, "attestor", SIGNER);
    }

    function testRevokeDelegateSignedWrongSignatureKey() public {
        vm.prank(SIGNER);
        registry.addDelegate(SIGNER, "attestor", SIGNER2, 1 days);
        (uint8 v, bytes32 r, bytes32 s) = signRevoke(SIGNER, SIGNER2, address(registry), PRIVATE_KEY2);
        vm.expectRevert("bad_signature");
        vm.prank(SIGNER3);
        registry.revokeDelegateSigned(SIGNER, v, r, s, "attestor", SIGNER2);
    }

    function testRevokeDelegateSignedWrongData() public {
        vm.prank(SIGNER);
        registry.addDelegate(SIGNER, "attestor", SIGNER2, 1 days);
        (uint8 v, bytes32 r, bytes32 s) = signRevoke(SIGNER, SIGNER, address(registry), PRIVATE_KEY);
        vm.expectRevert("bad_signature");
        registry.revokeDelegateSigned(SIGNER, v, r, s, "attestor", SIGNER2);
    }

    function testRevokeDelegateSignedWithIncorrectNonce() public {
        vm.prank(SIGNER);
        registry.addDelegate(SIGNER, "attestor", SIGNER2, 1 days);
        bytes memory message = abi.encodePacked(bytes("revokeDelegate"), bytes32("attestor"), SIGNER2);
        address idOwner = registry.identityOwner(SIGNER2);
        uint256 ownerNonce = registry.nonce(idOwner) + 0x1; // not expected
        (uint8 v, bytes32 r, bytes32 s) = VmDigest.signData(
            vm,
            SIGNER,
            address(registry),
            PRIVATE_KEY,
            message,
            ownerNonce
        );
        vm.expectRevert("bad_signature");
        registry.revokeDelegateSigned(SIGNER, v, r, s, "attestor", SIGNER2);
    }

    /**
     * @dev Sign data with private key
     * @param _identity Identity address
     * @param _registry DID Registry address
     * @param _privateKey Private key
     * @param _message Message to sign
     * @return v Signature v
     * @return r Signature r
     * @return s Signature s
     */
    function signData(
        address _identity,
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
        address idOwner = registry.identityOwner(_identity);
        uint256 ownerNonce = registry.nonce(idOwner);
        return VmDigest.signData(vm, _identity, _registry, _privateKey, _message, ownerNonce);
    }

    /**
     * @dev Sign delegate with private key
     * @param _identity Identity address
     * @param _delegate Delegate address
     * @param _registry DID Registry address
     * @param _privateKey Private key
     * @return v Signature v
     * @return r Signature r
     * @return s Signature s
     */
    function signDelegate(
        address _identity,
        address _delegate,
        address _registry,
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
        bytes memory message = abi.encodePacked(bytes("addDelegate"), bytes32("attestor"), _delegate, uint256(1 days));
        return signData(_identity, _registry, _privateKey, message);
    }

    /**
     * @dev Sign revoke with private key
     * @param _identity Identity address
     * @param _delegate Delegate address
     * @param _registry DID Registry address
     * @param _privateKey Private key
     * @return v Signature v
     * @return r Signature r
     * @return s Signature s
     */
    function signRevoke(
        address _identity,
        address _delegate,
        address _registry,
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
        bytes memory message = abi.encodePacked(bytes("revokeDelegate"), bytes32("attestor"), _delegate);
        return signData(_identity, _registry, _privateKey, message);
    }
}
