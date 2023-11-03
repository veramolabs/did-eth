// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { ERC1967Utils } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";

import { EIP1056RegistryProxy } from "./EIP1056RegistryProxy.sol";
import { DIDRegistry } from "./DIDRegistry.sol";

contract EIP1056RegistryProxy is ERC1967Proxy {
    constructor(address _logic, address _roleAdmin)
        ERC1967Proxy(_logic, abi.encodeWithSignature("initialize(address)", _roleAdmin))
    // solhint-disable-next-line no-empty-blocks
    {

    }
}

// solhint-disable-next-line func-visibility
function createEIP1056Registry(address _roleAdmin) returns (address) {
    DIDRegistry logic = new DIDRegistry(); // logic contract
    EIP1056RegistryProxy proxy = new EIP1056RegistryProxy(address(logic), _roleAdmin);
    return address(proxy);
}
