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

A DID that uses this method MUST begin with the following prefix: `did:eth:`. Per the DID specification, this string
MUST be in lowercase. The remainder of the DID, after the prefix, is specified below.

## Method Specific Identifier

The method specific identifier should be understood simply as a [CAIP-10 compliant identifier](https://github.com/ChainAgnostic/CAIPs/blob/master/CAIPs/caip-10.md), prefixed with the "did:eth:". In other words:
  * eth-did = "did:eth:" + CAIP-10 Identifier

Examples:
  * Ethereum: did:eth:eip155:1:0xb9c5714089478a327f09197987f16f9e5d936e8a
  * Polygon: did:eth:eip155:137:0x4e90e8a8191c1c23a24a598c3ab4fb47ce926ff5
  * Hedera: did:eth:eip155:296:0xa0ae58da58dfa46fa55c3b86545e7065f90ff011
  * Sepiola Testnet: did:eth:eip155:11155111:0xb9c5714089478a327f09197987f16f9e5d936e8a

### Examples


## CRUD Operations

### Create


### Read (Resolve)


### Update


### Delete

