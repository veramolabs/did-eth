// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { IERC165 } from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import { IAccessControl } from "@openzeppelin/contracts/access/IAccessControl.sol";
import { ERC1967Utils } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";
import { Initializable } from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

import { Test } from "forge-std/Test.sol";
import { VmSafe } from "forge-std/Vm.sol";

import { EIP1056Registry } from "../contracts/EIP1056Registry.sol";
import { DIDRegistry } from "../contracts/DIDRegistry.sol";
import { createEIP1056Registry, EIP1056RegistryProxy } from "../contracts/EIP1056RegistryProxy.sol";

import { VmDigest } from "./VmDigest.sol";

contract DIDRegistryTest is Test {
    event DIDOwnerChanged(address indexed identity, address owner, uint256 previousChange);

    address internal constant ROLE_ADMIN = address(0x45ee);

    bytes internal constant PRIVATE_KEY = hex"a285ab66393c5fdda46d6fbad9e27fafd438254ab72ad5acb681a0e9f20f5d7b";
    address internal constant SIGNER = 0x2036C6CD85692F0Fb2C26E6c6B2ECed9e4478Dfd;

    bytes internal constant PRIVATE_KEY2 = hex"a285ab66393c5fdda46d6fbad9e27fafd438254ab72ad5acb681a0e9f20f5d7a";
    address internal constant SIGNER2 = 0xEA91e58E9Fa466786726F0a947e8583c7c5B3185;

    DIDRegistry public registry;

    function setUp() public {
        address registryProxy = createEIP1056Registry(ROLE_ADMIN);
        registry = DIDRegistry(registryProxy);
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

    function testSupportsInterfaceIERC165() public {
        bool result = registry.supportsInterface(type(IERC165).interfaceId);
        assertTrue(result, "should support IERC165");
    }

    function testSupportsInterfaceAccessControl() public {
        bool result = registry.supportsInterface(type(IAccessControl).interfaceId);
        assertTrue(result, "should support IAccessControl");
    }

    function testSupportsInterfaceEIP1056Registry() public {
        bool result = registry.supportsInterface(type(EIP1056Registry).interfaceId);
        assertTrue(result, "should support EIP1056Registry");
    }

    function testDefaultRoleIsSet() public {
        assertTrue(registry.hasRole(registry.DEFAULT_ADMIN_ROLE(), ROLE_ADMIN));
    }

    function testGrantRole() public {
        address _next = address(0x123);
        assertEq(
            registry.DEFAULT_ADMIN_ROLE(),
            registry.getRoleAdmin(registry.REGISTRY_ADMIN_ROLE()),
            "expect default admin role"
        );
        vm.startPrank(ROLE_ADMIN);
        registry.grantRole(registry.REGISTRY_ADMIN_ROLE(), _next);
        vm.stopPrank();
        assertFalse(registry.hasRole(registry.DEFAULT_ADMIN_ROLE(), _next));
        assertTrue(registry.hasRole(registry.REGISTRY_ADMIN_ROLE(), _next));
    }

    function testRevokeOwner() public {
        vm.startPrank(ROLE_ADMIN);
        registry.revokeRole(registry.DEFAULT_ADMIN_ROLE(), address(this));
        vm.stopPrank();
        assertFalse(registry.hasRole(registry.DEFAULT_ADMIN_ROLE(), address(this)));
    }

    function testUpgradeAsAdmin() public {
        DIDRegistry logic = new DIDRegistry();
        address upgradeAdmin = address(0x123);
        vm.startPrank(ROLE_ADMIN);
        registry.grantRole(registry.REGISTRY_ADMIN_ROLE(), upgradeAdmin);
        vm.stopPrank();
        vm.prank(upgradeAdmin);
        vm.expectEmit();
        emit ERC1967Utils.Upgraded(address(logic));
        registry.upgradeToAndCall(address(logic), "");
    }

    function testUpgradeNotPermitted() public {
        DIDRegistry logic = new DIDRegistry();
        address badActor = address(0xffff);
        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector,
                badActor,
                registry.REGISTRY_ADMIN_ROLE()
            )
        );
        vm.prank(badActor);
        registry.upgradeToAndCall(address(logic), "");
    }

    function testRevokeDefaultAdminRole() public {
        address upgradeAdmin = address(0x133);
        vm.startPrank(ROLE_ADMIN);
        registry.grantRole(registry.REGISTRY_ADMIN_ROLE(), upgradeAdmin);
        vm.stopPrank();
        DIDRegistry logic = new DIDRegistry();
        vm.expectEmit();
        emit ERC1967Utils.Upgraded(address(logic));
        vm.prank(upgradeAdmin);
        registry.upgradeToAndCall(address(logic), "");
        vm.startPrank(ROLE_ADMIN);
        registry.revokeRole(registry.REGISTRY_ADMIN_ROLE(), upgradeAdmin);
        registry.revokeRole(registry.DEFAULT_ADMIN_ROLE(), ROLE_ADMIN);
        vm.stopPrank();
        assertFalse(registry.hasRole(registry.REGISTRY_ADMIN_ROLE(), upgradeAdmin));
        assertFalse(registry.hasRole(registry.DEFAULT_ADMIN_ROLE(), ROLE_ADMIN));
    }

    function testDuplicateInitializeFails() public {
        vm.expectRevert(abi.encodeWithSelector(Initializable.InvalidInitialization.selector));
        registry.initialize(address(0x123));
    }

    function testInitializeNotPossible() public {
        DIDRegistry _registry = new DIDRegistry();
        vm.expectRevert(abi.encodeWithSelector(Initializable.InvalidInitialization.selector));
        _registry.initialize(address(0x123));
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
