---
title: 'Ethereum DID Registry'
index: 0
category: 'ethr-did-registry'
type: 'reference'
source: 'https://github.com/uport-project/ethr-did-registry/blob/develop/README.md'
---

# Ethereum DID Registry

This library contains the Ethereum contract code that allows the owner of an ethr-did identity to update the attributes
that appear in its did-document. It exposes an API that allows developers to call the contract functions using
Javascript.

Use this if you want to interact directly with a deployed registry contract directly, or deploy a copy of the contract
to another Ethereum network.

A DID is an [Identifier](https://w3c.github.io/did-core/#a-simple-example) that allows you to lookup
a [DID document](https://w3c.github.io/did-core/#example-a-simple-did-document) that can be used to authenticate you and
messages created by you.

It's designed for resolving public keys for off-chain authentication—where the public key resolution is handled by using
decentralized technology.

This contract allows Ethereum addresses to present signing information about themselves with no prior registration. It
allows them to perform key rotation and specify different keys and services that are used on its behalf for both on and
off-chain usage.

## Contract Deployments

> WARNING
> Most of these are deployments of version 0.0.3 of the contract and they do not include recent updates.
> Join the discussion as to how to adopt these new changes [on our discord](https://discord.gg/MTeTAwSYe7)

| Network Name | name    | chainId    | hexChainId | Registry Address                                                                                                                       | Registry version                                                                                               |
| ------------ | ------- | ---------- | ---------- | -------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| Mainnet      | mainnet | 1          | 0x1        | [0xdca7ef03e98e0dc2b855be647c39abe984fcf21b](https://etherscan.io/address/0xdca7ef03e98e0dc2b855be647c39abe984fcf21b)                  | [4278342e](https://github.com/uport-project/ethr-did-registry/commit/4278342e9b1dec0ab4fd63f4bd5536094c4de9f0) |
| Ropsten      | ropsten | 3          | 0x3        | [0xdca7ef03e98e0dc2b855be647c39abe984fcf21b](https://ropsten.etherscan.io/address/0xdca7ef03e98e0dc2b855be647c39abe984fcf21b)          | [4278342e](https://github.com/uport-project/ethr-did-registry/commit/4278342e9b1dec0ab4fd63f4bd5536094c4de9f0) |
| Rinkeby      | rinkeby | 4          | 0x4        | [0xdca7ef03e98e0dc2b855be647c39abe984fcf21b](https://rinkeby.etherscan.io/address/0xdca7ef03e98e0dc2b855be647c39abe984fcf21b)          | [4278342e](https://github.com/uport-project/ethr-did-registry/commit/4278342e9b1dec0ab4fd63f4bd5536094c4de9f0) |
| Goerli       | goerli  | 5          | 0x5        | [0xdca7ef03e98e0dc2b855be647c39abe984fcf21b](https://goerli.etherscan.io/address/0xdca7ef03e98e0dc2b855be647c39abe984fcf21b)           | [4278342e](https://github.com/uport-project/ethr-did-registry/commit/4278342e9b1dec0ab4fd63f4bd5536094c4de9f0) |
| Kovan        | kovan   | 42         | 0x2a       | [0xdca7ef03e98e0dc2b855be647c39abe984fcf21b](https://kovan.etherscan.io/address/0xdca7ef03e98e0dc2b855be647c39abe984fcf21b)            | [4278342e](https://github.com/uport-project/ethr-did-registry/commit/4278342e9b1dec0ab4fd63f4bd5536094c4de9f0) |
| RSK          | rsk     | 30         | 0x1e       | [0xdca7ef03e98e0dc2b855be647c39abe984fcf21b](https://explorer.rsk.co/address/0xdca7ef03e98e0dc2b855be647c39abe984fcf21b)               | [4278342e](https://github.com/uport-project/ethr-did-registry/commit/4278342e9b1dec0ab4fd63f4bd5536094c4de9f0) |
| RSK Testnet  |         | 31         | 0x1f       | [0xdca7ef03e98e0dc2b855be647c39abe984fcf21b](https://explorer.testnet.rsk.co/address/0xdca7ef03e98e0dc2b855be647c39abe984fcf21b)       | [4278342e](https://github.com/uport-project/ethr-did-registry/commit/4278342e9b1dec0ab4fd63f4bd5536094c4de9f0) |
| EnergyWeb    | ewc     | 246        | 0xf6       | [0xe29672f34e92b56c9169f9d485ffc8b9a136bce4](https://explorer.energyweb.org/address/0xE29672f34e92b56C9169f9D485fFc8b9A136BCE4)        | [c9063836](https://github.com/uport-project/ethr-did-registry/commit/c90638361a76d247d61ef4e3eb245a78cf587f91) |
| EWC Volta    | volta   | 73799      | 0x12047    | [0xc15d5a57a8eb0e1dcbe5d88b8f9a82017e5cc4af](https://volta-explorer.energyweb.org/address/0xC15D5A57A8Eb0e1dCBE5D88B8f9a82017e5Cc4AF)  | [f4e17ee1](https://github.com/uport-project/ethr-did-registry/commit/f4e17ee1eb558c5a006bab1a04108f27d4e3f0d0) |
| ARTIS tau1   |         | 246785     | 0x3c401    | [0xdca7ef03e98e0dc2b855be647c39abe984fcf21b](https://explorer.tau1.artis.network/address/0xdCa7EF03e98e0DC2B855bE647C39ABe984fcF21B)   | [4278342e](https://github.com/uport-project/ethr-did-registry/commit/4278342e9b1dec0ab4fd63f4bd5536094c4de9f0) |
| ARTIS sigma1 |         | 246529     | 0x3c301    | [0xdca7ef03e98e0dc2b855be647c39abe984fcf21b](https://explorer.sigma1.artis.network/address/0xdCa7EF03e98e0DC2B855bE647C39ABe984fcF21B) | [4278342e](https://github.com/uport-project/ethr-did-registry/commit/4278342e9b1dec0ab4fd63f4bd5536094c4de9f0) |
| Polygon      | polygon | 137        | 0x89       | [0xdca7ef03e98e0dc2b855be647c39abe984fcf21b](https://polygonscan.com/address/0xdca7ef03e98e0dc2b855be647c39abe984fcf21b)               | [4278342e](https://github.com/uport-project/ethr-did-registry/commit/4278342e9b1dec0ab4fd63f4bd5536094c4de9f0) |
| Polygon test |         | 80001      | 0x13881    | [0xdca7ef03e98e0dc2b855be647c39abe984fcf21b](https://mumbai.polygonscan.com/address/0xdca7ef03e98e0dc2b855be647c39abe984fcf21b)        | [4278342e](https://github.com/uport-project/ethr-did-registry/commit/4278342e9b1dec0ab4fd63f4bd5536094c4de9f0) |
| Aurora       | aurora  | 1313161554 | 0x4E454152 | [0x63ed58b671eed12bc1652845ba5b2cdfbff198e0](https://explorer.mainnet.aurora.dev/address/0x63eD58B671EeD12Bc1652845ba5b2CDfBff198e0)   | [0ab4f151](https://github.com/uport-project/ethr-did-registry/commit/0ab4f151ddde5b7739b97827c4fb901289f57892) |

## Using the Registry

The DID Registry can be used from JavaScript as well as directly from other contracts.

To use the contract, we provide hardhat artifacts. Once you require the `ethr-did-registry` module, you will get an
object containing the JSON.

```javascript
const { DIDRegistry } = require('ethr-did-registry')
```

You can use [`ethers.js`](https://github.com/ethers-io/ethers.js/) to utilize these artifacts.

```javascript
const { ethers } = require('ethers')
const DidReg = new ethers.Contract(registryAddress, DIDRegistry.abi)
DidReg.connect(yourSignerOrProvider)
```

## On-chain vs. Off-chain

For on-chain interactions Ethereum has a built-in account abstraction that can be used regardless of whether the account
is a smart contract or a key pair. Any transaction has a `msg.sender` as the verified sender of the transaction.

Since each Ethereum transaction must be funded, there is a growing trend of on-chain transactions that are authenticated
via an externally created signature and not by the actual transaction originator. This allows for 3rd party funding
services, or for receivers to pay without any fundamental changes to the underlying Ethereum architecture.

These kinds of transactions have to be signed by an actual key pair and thus cannot be used to represent smart contract
based Ethereum accounts.

We propose a way of a smart contract or regular key pair delegating signing for various purposes to externally managed
key pairs. This allows a smart contract to be represented, both on-chain as well as off-chain or in payment channels
through temporary or permanent delegates.

## Identity Identifier

Any Ethereum account regardless of whether it's a key pair or smart contract based is considered to be an account
identifier.

An identity needs no registration.

## Identity Ownership

Each identity has a single address which maintains ultimate control over it. By default, each identity is controlled by
itself. As ongoing technological and security improvements occur, an owner can replace themselves with any other
Ethereum address, such as an advanced multi-signature contract.

There is only ever a single identity owner. More advanced ownership models are managed through a multi-signature
contract.

### Looking up Identity Ownership

Ownership of identity is verified by calling the `identityOwner(address identity) public view returns(address)`
function. This returns the address of the current Identity Owner.

### Changing Identity Ownership

The account owner can replace themselves at any time, by calling the `changeOwner(address identity, address newOwner)`
function.

There is also a version of this function which is called with an externally created signature, that is passed to a
transaction funding service.

The externally signed version has the following
signature `changeOwnerSigned(address identity, uint8 sigV, bytes32 sigR, bytes32 sigS, address newOwner)`.

The signature should be signed of the keccak256 hash of the following tightly packed parameters:

`byte(0x19), byte(0), address of registry, nonce[currentOwner], identity, "changeOwner", newOwner`

## Delegates

Delegates are addresses that are delegated for a specific time to perform a function on behalf of an identity.

They can be accessed both on and off-chain.

### Delegate Types

The type of function is simply a string, that is determined by a protocol or application higher up.

Examples:

- ‘DID-JWT’
- ‘Raiden’

### Validity

Delegates expire. The expiration time is application specific and dependent on the security requirements of the identity
owner.

Validity is set using the number of seconds from the time that adding the delegate is set.

### Looking up a Delegate

You can check to see if an address is a delegate for an identity using
the`validDelegate(address identity, bytes32 delegateType, address delegate) returns(bool)` function. This returns true
if the address is a valid delegate of the given delegateType.

### Adding a Delegate

An identity can assign multiple delegates to manage signing on their behalf for specific purposes.

The account owner can call the `addDelegate(address identity, bytes32 delegateType, address delegate, uint validity)`
function.

There is also a version of this function which is called with an externally created signature, that is passed to a
transaction funding service.

The externally signed version has the following
signature `addDelegateSigned(address identity, uint8 sigV, bytes32 sigR, bytes32 sigS, bytes32 delegateType, address delegate, uint validity)`
.

The signature should be signed of the keccak256 hash of the following tightly packed parameters:

`byte(0x19), byte(0), address of registry, nonce[currentOwner], identity, "addDelegate", delegateType, delegate, validity`

### Revoking a Delegate

A delegate may be manually revoked by calling
the `revokeDelegate(address identity, string delegateType, address delegate)` function.

There is also a version of this function which is called with an externally created signature, that is passed to a
transaction funding service.

The externally signed version has the following
signature `revokeDelegateSigned(address identity, uint8 sigV, bytes32 sigR, bytes32 sigS, bytes32 delegateType, address delegate)`
.

The signature should be signed of the keccak256 hash of the following tightly packed parameters:

`byte(0x19), byte(0), address of registry, nonce[currentOwner], identity, "revokeDelegate", delegateType, delegate`

### Enumerating Delegates Off-chain

Attributes are stored as `DIDDelegateChanged` events. A `validTo` of 0 indicates a revoked delegate.

```solidity
event DIDDelegateChanged(
    address indexed identity,
    bytes32 delegateType,
    address delegate,
    uint validTo,
    uint previousChange
  );
```

## Adding Off-chain Attributes

An identity may need to publish some information that is only needed off-chain but still requires the security benefits
of using a blockchain.

### Setting Attributes

These attributes are set using the `setAttribute(address identity, bytes32 name, bytes value, uint validity)` function
and published using events.

There is also a version of this function that is called with an externally created signature, that is passed to a
transaction funding service.

The externally signed version has the following
signature `setAttributeSigned(address identity, uint8 sigV, bytes32 sigR, bytes32 sigS, bytes32 name, bytes value, uint validity)`
.

The signature should be signed off the keccak256 hash of the following tightly packed parameters:

`byte(0x19), byte(0), address of registry, nonce[currentOwner], identity, "setAttribute", name, value, validity`

### Revoking Attributes

These attributes are revoked using the `revokeAttribute(address identity, bytes32 name, bytes value)` function and
published using events.

There is also a version of this function that is called with an externally created signature, that is passed to a
transaction funding service.

The externally signed version has the following
signature `revokeAttributeSigned(address identity, uint8 sigV, bytes32 sigR, bytes32 sigS, bytes32 name, bytes value)`.

The signature should be signed off the keccak256 hash of the following tightly packed parameters:

`byte(0x19), byte(0), address of registry, nonce[currentOwner], identity, "revokeAttribute", name, value`

### Reading attributes

Attributes are stored as `DIDAttributeChanged` events. A `validTo` of 0 indicates a revoked attribute.

```solidity
event DIDAttributeChanged(
    address indexed identity,
    bytes32 name,
    bytes value,
    uint validTo,
    uint previousChange
  );
```

### Delegate types and attribute names encoding

For gas cost reasons the names of attributes and types of delegates are fixed size `bytes32` values. In most situations,
this is not a problem since most can be represented by strings shorter than 32 bytes. To get a bytes32 value from them,
the recommended approach is to use the byte array representation of your string and right-pad it to get to 32 bytes.

## Enumerating Linked Identity Events

Contract Events are a useful feature for storing data from smart contracts exclusively for off-chain use. Unfortunately,
current Ethereum implementations provide a very inefficient lookup mechanism.

By using linked events that always link to the previous block with a change to the identity, we can solve this problem
with improved performance.

Each identity has its previously changed block stored in the `changed` mapping.

1. Lookup `previousChange` block for identity
2. Lookup all events for a given identity address using web3, but only for the `previousChange` block
3. Do something with the event
4. Find `previousChange` from the event and repeat

Example code

```js
const history = []
let prevChange = (await DidReg.changed(identityAddress)).toNumber()
while (prevChange) {
  const logs = await ethers.provider.getLogs({
    topics: [null, `0x000000000000000000000000${identityAddress}`],
    fromBlock: prevChange,
    toBlock: prevChange,
  })
  prevChange = 0
  for (const log of logs) {
    const logDescription = DidReg.interface.parseLog(log)
    history.unshift(logDescription)
    prevChange = logDescription.args.previousChange.toNumber()
  }
}
```

## Assemble a DID Document

The full spec describing how to interact with this registry to build a DID document can be found in
the [ehtr-did-resolver](https://github.com/decentralized-identity/ethr-did-resolver/blob/master/doc/did-method-spec.md)
repository.

In short, you would do something like this:

The primary owner key should be looked up using `identityOwner(identity)`. This should be the first of the public keys
listed.

Iterate through the `DIDDelegateChanged` events to build a list of additional keys and authentication sections as
needed. The list of delegateTypes to include is still to be determined.

Iterate through `DIDAttributeChanged` events for service entries, encrypted public keys, and other public names. The
attribute names are still to be determined.

## Deployment Address

| Contract        | Ethereum Address                           | Network                                                                                    |
| --------------- | ------------------------------------------ | ------------------------------------------------------------------------------------------ |
| EIP1056Registry | 0xd1D374DDE031075157fDb64536eF5cC13Ae75000 | [Sepolia](https://sepolia.etherscan.io/address/0xd1d374dde031075157fdb64536ef5cc13ae75000) |
| EIP1056Registry | 0xd1D374DDE031075157fDb64536eF5cC13Ae75000 | [Görli](https://goerli.etherscan.io/address/0xd1d374dde031075157fdb64536ef5cc13ae75000)    |

## Quick Start (Development)

### Submodules

First, init submodules from the project root

```bash
$ git submodule update --recursive --init -f
```

### Dev Containers Development

This contract supports containerized development. From Visual Studio Code Dev Containers extension

`Reopen in Container`

or

Command line build using docker

```bash
$ docker build packages/did-eth-registry -t did-eth:1
```

## Testing the Contracts

From the containerized environment:

```bash
$ yarn install --frozen-lockfile
$ yarn prettier:check
$ yarn lint
$ forge test -vvv
```

## Initial Deployment

### Using vanity address

1\. dump out registry init code

```bash
$ yarn dumpregistry
```

2\. compute the address for the registry

```bash
$ yarn registryaddress
```

Make a note of the registry address and registry salt. Convert the salt to a 32 byte hex string using `cast --tobase`

```bash
$ cast --to-base 74093810807909736385031531802484957602545215186873255285560364360670735082938 16
0xa3cf9c5bc4043744d6ce20e743000b2a92113cff47d618a20365366f8729a5ba
```

3\. dump out the proxy init code

```bash
CONTRACT_ROLE_ADMIN=0x521DBc90a1687d0ed050Cf4ba47d5A04d8253f46 \
REGISTRY_ADDRESS=0xD1D8360742139fD76C16c397A4d5ECA9E2A73c4b \
yarn dumpproxy
```

4\. run the create2 function to choose a vanity address for the proxy

```bash
$ yarn vanity
```

Make a note of the salt for the proxy contract. Convert the salt to a 32 byte hex string using cast --to-base

```bash
cast --to-base 75226583542044164422273476230409956855417563147003477807955548159938739788128 16
0xa650bcc7b18a1b8ee999056c89f3adbe79f5c69bcc68f164e9760a0e0e1b5960
```

5.  Deploy the registry and proxy

```bash
$ CONTRACT_ROLE_ADMIN=0x521DBc90a1687d0ed050Cf4ba47d5A04d8253f46 \
CONTRACT_ROLE_UPGRADE="0x521DBc90a1687d0ed050Cf4ba47d5A04d8253f46,0x2746bC0bE84D7CC9A63526C02746d12FA20621F3" \
CONTRACT_SALT=0xa650bcc7b18a1b8ee999056c89f3adbe79f5c69bcc68f164e9760a0e0e1b5960 \
REGISTRY_SALT=0xa3cf9c5bc4043744d6ce20e743000b2a92113cff47d618a20365366f8729a5ba \
forge script ./script/DeployRegistry.s.sol:DeployRegistry --sig 'deploy()' --slow --broadcast --rpc-url ${RPC_URL} --private-key ${PRIVATE_KEY} --etherscan-api-key ${ETHERSCAN_API_KEY} --verify
```

### Upgrade Deployment

Post initial deployment, the contract can be upgraded directly through the [UUPSUpgradeable](https://docs.openzeppelin.com/contracts/4.x/api/proxy#UUPSUpgradeable) interface

```solidity
   registry.upgradeToAndCall(address(logic), "");
```
