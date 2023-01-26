//SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "./AppStorage.sol";
import "./DocumentStorage.sol";

// Naughty Import, just so I can do this quickly
import "./documents/didETHStorage.sol";

library LibResolver {
    // This doesn't actually work, just leaving it here
    function getIntendedResolver__LibMeta()
        internal
        view
        returns (address resolver)
    {
        if (msg.sender == address(this)) {
            bytes memory array = msg.data;
            uint256 index = msg.data.length;
            assembly {
                // Load the 32 bytes word from memory with the address on the lower 20 bytes, and mask those.
                resolver := and(
                    mload(add(array, index)),
                    0xffffffffffffffffffffffffffffffffffffffff
                )
            }
        } else {
            resolver = msg.sender;
        }
    }

    // Naughty function, just to show an example. This should be secured by pinning to the actual resolver called.
    // When this is done well, it should look something like the above getIntendedResolver__LibMeta function,
    // where we get the intended resolver from the calldata.
    function getIntendedResolver() internal view returns (address resolver) {
        didETHStorage.Storage storage s = didETHStorage.getStorage();
        resolver = s.idProxyAddress;
    }

    // Naughty function, just to show an example.
    function getIntendedResolverStorage()
        internal
        view
        returns (mapping(int256 => Document) storage s)
    {
        address resolver = getIntendedResolver();
        s = DocumentStorage.getStoragePointer(resolver);
    }
}
