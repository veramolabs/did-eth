// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import { Test } from "forge-std/Test.sol";
import { VmSafe } from "forge-std/Vm.sol";

import { EthereumDIDRegistry } from "../contracts/EthereumDIDRegistry.sol";
import { VmDigest } from "./VmDigest.sol";

contract EthereumDIDRegistryTest is Test {
    event DIDOwnerChanged(address indexed identity, address owner, uint256 previousChange);

    EthereumDIDRegistry public registry;

    bytes internal constant PRIVATE_KEY = hex"a285ab66393c5fdda46d6fbad9e27fafd438254ab72ad5acb681a0e9f20f5d7b";
    address internal constant SIGNER = 0x2036C6CD85692F0Fb2C26E6c6B2ECed9e4478Dfd;

    bytes internal constant PRIVATE_KEY2 = hex"a285ab66393c5fdda46d6fbad9e27fafd438254ab72ad5acb681a0e9f20f5d7a";
    address internal constant SIGNER2 = 0xEA91e58E9Fa466786726F0a947e8583c7c5B3185;

    function setUp() public {
        registry = new EthereumDIDRegistry();
    }

    function testIdentityOwner() public {
        address owner = address(0x123);
        address result = registry.identityOwner(owner);
        assertEq(result, owner, "should identify address itself");
    }

    function testChangeOwner() public {
        address owner = address(0x123);
        address newOwner = address(0x456);
        vm.prank(owner);
        registry.changeOwner(owner, newOwner);
        assertEq(registry.identityOwner(owner), newOwner, "should change owner");
    }

    function testChangeOwnerDelegate() public {
        address owner = address(0x123);
        address newOwner = address(0x456);
        address newOwner2 = address(0x789);
        vm.prank(owner);
        registry.changeOwner(owner, newOwner);
        vm.prank(newOwner);
        registry.changeOwner(owner, newOwner2);
        assertEq(registry.identityOwner(owner), newOwner2, "should change owner twice");
    }

    function testChangeOwnerOriginalAddressIsBadActor() public {
        address owner = address(0x123);
        address newOwner = address(0x456);
        vm.prank(owner);
        registry.changeOwner(owner, newOwner);
        vm.prank(owner);
        vm.expectRevert("bad_actor");
        registry.changeOwner(owner, owner);
    }

    function testChangeOwnerAsBadActor() public {
        address owner = address(0x123);
        address newOwner = address(0x456);
        vm.prank(newOwner);
        vm.expectRevert("bad_actor");
        registry.changeOwner(owner, newOwner);
    }

    function testChangedTransactionBlock() public {
        address owner = address(0x123);
        address newOwner = address(0x456);
        vm.prank(owner);
        registry.changeOwner(owner, newOwner);
        assertEq(registry.changed(owner), block.number, "should record block number");
    }

    function testExpectDIDOwnerChangedEvent() public {
        address owner = address(0x123);
        address newOwner = address(0x456);
        vm.expectEmit();
        emit DIDOwnerChanged(owner, newOwner, 0);
        vm.prank(owner);
        registry.changeOwner(owner, newOwner);
    }

    function testChangeOwnerSignedMapping() public {
        bytes memory message = abi.encodePacked("changeOwner", SIGNER2);
        (uint8 v, bytes32 r, bytes32 s) = signData(SIGNER, address(registry), PRIVATE_KEY, message);
        registry.changeOwnerSigned(SIGNER, v, r, s, SIGNER2);

        address owner = registry.owners(SIGNER);
        assertEq(SIGNER2, owner, "signed change ownership expected");
    }

    function testChangeOwnerSignedIncrementNonce() public {
        bytes memory message = abi.encodePacked("changeOwner", SIGNER2);
        (uint8 v, bytes32 r, bytes32 s) = signData(SIGNER, address(registry), PRIVATE_KEY, message);
        registry.changeOwnerSigned(SIGNER, v, r, s, SIGNER2);

        uint256 nonce = registry.nonce(SIGNER);
        assertEq(1, nonce, "nonce should be incremented");
    }

    function testChangeOwnerSignedTransactionBlock() public {
        bytes memory message = abi.encodePacked("changeOwner", SIGNER2);
        (uint8 v, bytes32 r, bytes32 s) = signData(SIGNER, address(registry), PRIVATE_KEY, message);
        registry.changeOwnerSigned(SIGNER, v, r, s, SIGNER2);

        uint256 blockNumber = registry.changed(SIGNER);
        assertEq(block.number, blockNumber, "should record block number");
    }

    function testChangeOwnerSignedEventEmit() public {
        vm.expectEmit();
        emit DIDOwnerChanged(SIGNER, SIGNER2, 0);
        bytes memory message = abi.encodePacked("changeOwner", SIGNER2);
        (uint8 v, bytes32 r, bytes32 s) = signData(SIGNER, address(registry), PRIVATE_KEY, message);
        registry.changeOwnerSigned(SIGNER, v, r, s, SIGNER2);
    }

    function testChangeOwnerSignedOriginalOwnerBadSignature() public {
        vm.prank(SIGNER);
        registry.changeOwner(SIGNER, SIGNER2);

        bytes memory digestMessage = abi.encodePacked("changeOwner", SIGNER);
        (uint8 v, bytes32 r, bytes32 s) = signData(SIGNER, address(registry), PRIVATE_KEY, digestMessage);
        vm.expectRevert("bad_signature");
        registry.changeOwnerSigned(SIGNER, v, r, s, SIGNER);
    }

    function testChangeOwnerSignedBadSignature() public {
        bytes memory digestMessage = abi.encodePacked("changeOwner", SIGNER);
        (uint8 v, bytes32 r, bytes32 s) = signData(SIGNER, address(registry), PRIVATE_KEY2, digestMessage);
        vm.expectRevert("bad_signature");
        registry.changeOwnerSigned(SIGNER, v, r, s, SIGNER);
    }

    function testChangeOwnerSignedWrongSignature() public {
        bytes memory digestMessage = abi.encodePacked("changeOwner", SIGNER);
        (uint8 v, bytes32 r, bytes32 s) = signData(SIGNER2, address(registry), PRIVATE_KEY, digestMessage);
        vm.expectRevert("bad_signature");
        registry.changeOwnerSigned(SIGNER, v, r, s, SIGNER);
    }

    function testChangeOwnerSignedOwnerNonceBadSignature() public {
        bytes memory digestMessage = abi.encodePacked("changeOwner", SIGNER2);
        (uint8 v, bytes32 r, bytes32 s) = VmDigest.signData(
            vm,
            SIGNER,
            address(registry),
            PRIVATE_KEY,
            digestMessage,
            0x111
        );
        vm.expectRevert("bad_signature");
        registry.changeOwnerSigned(SIGNER, v, r, s, SIGNER2);
    }

    /**
     * @dev Sign data with private key
     * @param _identity Identity address
     * @param _registry DID Registry address
     * @param _privateKey Private key
     * @param _message Digest message
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
}
