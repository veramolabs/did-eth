// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import { Script } from "forge-std/Script.sol";

import { DIDRegistry } from "../contracts/DIDRegistry.sol";
import { EIP1056RegistryProxy } from "../contracts/EIP1056RegistryProxy.sol";
import { EIP1056Registry } from "../contracts/EIP1056Registry.sol";

/**
 * @notice - This is the script for deploying DIDRegistry
 */
contract DeployRegistry is Script {
    event RegistryDeployment(address proxy);

    /**
     * @notice - save the bytecode for DIDRegistry to a file
     * @dev requires fs_permissions
     */
    function dumpRegistry() external {
        bytes memory createCode = abi.encodePacked(type(DIDRegistry).creationCode);
        vm.writeFile("./DIDRegistry.bin", vm.toString(createCode));
    }

    /**
     * @notice - save the bytecode for EIP1056RegistryProxy to a file
     * @dev requires fs_permissions
     */
    function dumpProxy() external {
        address _contractRoleAdmin = vm.envAddress("CONTRACT_ROLE_ADMIN");
        address _registryAddress = vm.envAddress("REGISTRY_ADDRESS");
        bytes memory createCode = abi.encodePacked(
            type(EIP1056RegistryProxy).creationCode,
            abi.encode(_registryAddress, _contractRoleAdmin)
        );
        vm.writeFile("./EIP1056RegistryProxy.bin", vm.toString(createCode));
    }

    /**
     * @notice - deploy DIDRegistry and Proxy
     */
    function deploy() external {
        vm.startBroadcast();
        address _contractRoleAdmin = vm.envAddress("CONTRACT_ROLE_ADMIN");
        address[] memory _contractUpgradeAdmin = vm.envAddress("CONTRACT_ROLE_UPGRADE", ",");
        bytes32 _registrySalt = vm.envBytes32("REGISTRY_SALT");
        bytes32 _vanitySalt = vm.envBytes32("CONTRACT_SALT");
        DIDRegistry logic = new DIDRegistry{ salt: _registrySalt }();
        EIP1056RegistryProxy proxy = new EIP1056RegistryProxy{ salt: _vanitySalt }(address(logic), _contractRoleAdmin);
        address proxyAddress = address(proxy);
        DIDRegistry registry = DIDRegistry(proxyAddress);
        for (uint256 i = 0; i < _contractUpgradeAdmin.length; i++) {
            address admin = _contractUpgradeAdmin[i];
            registry.grantRole(logic.REGISTRY_ADMIN_ROLE(), admin);
        }
        emit RegistryDeployment(proxyAddress);
        vm.stopBroadcast();
    }

    /**
     * @notice - upgrade DIDRegistry Proxy
     */
    function upgrade() external {
        vm.startBroadcast();
        address _proxyAddress = vm.envAddress("PROXY_ADDRESS");
        DIDRegistry logic = new DIDRegistry();
        DIDRegistry registry = DIDRegistry(_proxyAddress);
        registry.upgradeToAndCall(address(logic), "");
        vm.stopBroadcast();
    }
}
