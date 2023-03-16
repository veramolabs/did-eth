# did:eth Method Specification

**Authors**: 
**Latest version**: https://github.com/veramolabs/did-eth/blob/main/did-eth-method-draft.md  
**Status**: Draft  

## Introduction

`did-eth` is intended to be a modern DID method for the Ethereum ecosystem. It serves as a successor to `did-ethr` in this regard, and should be fully [DID-core](https://www.w3.org/TR/did-core/) compliant, fully supporting all possible verification methods and services. This DID method should be resolvable both off-chain (by querying for and processing EVM events) as well as on-chain (by processing EVM state directly from within a smart contract), although it should be considered acceptable if the on-chain resolution involves only a subset of verification methods or services, as specified later in this document.

### Problem Statement


### Relationship to other DID architectures

### Combination with other DID methods

## Design Goals


## Identifier scheme

### Syntax and Interpretation

```
eth-did    = "did:eth:<chain_id>:" address
chain_id   = chain_id according to [CAIP-2]
address    = account_id according to [CAIP-10]
```

### Examples


## CRUD Operations

### Create


### Read (Resolve)


### Update


### Delete

