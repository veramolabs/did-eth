# did:eth Method Specification

**Authors**: 
**Latest version**: https://github.com/veramolabs/did-eth/blob/main/did-eth-method-draft.md  
**Status**: Draft  

## Introduction

### Problem Statement


### Relationship to other DID architectures

### Combination with other DID methods

## Design Goals


## DID Method Name

The namestring that shall identify this DID method is: `eth`

A DID that uses this method MUST begin with the following prefix: `did:eth`. Per the DID specification, this string
MUST be in lowercase. The remainder of the DID, after the prefix, is specified below.

## Method Specific Identifier

The method specific identifier is represented as the HEX-encoded secp256k1 public key (in compressed form),
or the corresponding HEX-encoded Ethereum address on the target network, prefixed with `0x`.

    eth-did = "did:ethr:" eth-specific-identifier
    eth-specific-identifier = [ ethr-network ":" ] ethereum-address / public-key-hex / ens-name
    eth-network = "mainnet" / "goerli" / network-chain-id
    network-chain-id = "0x" *HEXDIG
    ethereum-address = "0x" 40*HEXDIG
    public-key-hex = "0x" 66*HEXDIG
    ens-name = website ".eth"

The `ethereum-address` or `public-key-hex` or `ens-name` are case-insensitive, however, the corresponding `blockchainAccountId`
MAY be represented using
the [mixed case checksum representation described in EIP55](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-55.md)
in the resulting DID document.

Note, if no public Ethereum network was specified, it is assumed that the DID is anchored on the Ethereum mainnet by
default. This means the following DIDs will resolve to equivalent DID Documents:

    did:ethr:mainnet:0xb9c5714089478a327f09197987f16f9e5d936e8a
    did:ethr:0x1:0xb9c5714089478a327f09197987f16f9e5d936e8a
    did:ethr:0xb9c5714089478a327f09197987f16f9e5d936e8a

If the identifier is a `public-key-hex`:

- it MUST be represented in compressed form (see https://en.bitcoin.it/wiki/Secp256k1)
- the corresponding `blockchainAccountId` entry is also added to the default DID document, unless the `owner` property
  has been changed to a different address.
- all Read, Update, and Delete operations MUST be made using the corresponding `blockchainAccountId` and MUST originate
  from the correct controller account (ECR1056 `owner`).

If the `eth-specific-identifier` is a `ens-name`:

- the `chainId` MUST be "mainnet" ("0x1") or "goerli" ("0x5")
- the `controller` of the ENS Name is used as the `blockchainAccountId` of the DID

### Examples


## CRUD Operations

### Create


### Read (Resolve)


### Update


### Delete

