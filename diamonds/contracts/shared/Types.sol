//SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

/// @notice File to store shared structs

struct Document {
    address owner;
    string info;
    int256 version;
}
