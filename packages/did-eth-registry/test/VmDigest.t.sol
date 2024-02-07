// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { Test } from "forge-std/Test.sol";
import { VmDigest } from "./VmDigest.sol";

contract DIDRegistryTest is Test {
    function testToUint256() public {
        bytes memory b1 = hex"10";
        bytes memory b2 = hex"1000";
        bytes memory b3 = hex"100000";
        bytes memory b4 = hex"10000000";
        bytes memory b5 = hex"1000000000";
        bytes memory b6 = hex"100000000000";
        bytes memory b7 = hex"10000000000000";
        bytes memory b8 = hex"1000000000000000";
        bytes memory b9 = hex"100000000000000000";
        bytes memory b10 = hex"10000000000000000000";
        bytes memory b11 = hex"1000000000000000000000";
        bytes memory b12 = hex"100000000000000000000000";
        bytes memory b13 = hex"10000000000000000000000000";
        bytes memory b14 = hex"1000000000000000000000000000";

        assertEq(VmDigest.toUint256(b1), 0x1 << 252, "should convert bytes to uint256");
        assertEq(VmDigest.toUint256(b2), 0x1 << 252, "should convert bytes to uint256");
        assertEq(VmDigest.toUint256(b3), 0x1 << 252, "should convert bytes to uint256");
        assertEq(VmDigest.toUint256(b4), 0x1 << 252, "should convert bytes to uint256");
        assertEq(VmDigest.toUint256(b5), 0x1 << 252, "should convert bytes to uint256");
        assertEq(VmDigest.toUint256(b6), 0x1 << 252, "should convert bytes to uint256");
        assertEq(VmDigest.toUint256(b7), 0x1 << 252, "should convert bytes to uint256");
        assertEq(VmDigest.toUint256(b8), 0x1 << 252, "should convert bytes to uint256");
        assertEq(VmDigest.toUint256(b9), 0x1 << 252, "should convert bytes to uint256");
        assertEq(VmDigest.toUint256(b10), 0x1 << 252, "should convert bytes to uint256");
        assertEq(VmDigest.toUint256(b11), 0x1 << 252, "should convert bytes to uint256");
        assertEq(VmDigest.toUint256(b12), 0x1 << 252, "should convert bytes to uint256");
        assertEq(VmDigest.toUint256(b13), 0x1 << 252, "should convert bytes to uint256");
        assertEq(VmDigest.toUint256(b14), 0x1 << 252, "should convert bytes to uint256");
    }

    function testToUint256With32ByteValue() public {
        bytes memory b32 = hex"1000000000000000000000000000000000000000000000000000000000000000";
        assertEq(VmDigest.toUint256(b32), 0x1 << 252, "should convert bytes to uint256");
    }

    function testToUint256Requires32BytesOrLess() public {
        bytes memory b33 = hex"100000000000000000000000000000000000000000000000000000000000000000";
        vm.expectRevert("toUint256_outOfBounds");
        VmDigest.toUint256(b33);
    }
}
