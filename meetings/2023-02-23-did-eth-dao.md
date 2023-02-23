# did-eth DAO 2023-02-23

* Discussion of https://github.com/veramolabs/did-eth/issues/27
    * Consensus was formed to update https://github.com/veramolabs/did-eth/pull/25 to use "strict CAIP-10"
* Discussed if use of events would somehow make did-eth not DID-core compliant, decided it wasn't a problem, but that on-chain resolvability needs to be considered.
    * There is general consensus on continuing to use events to build DID documents in the resolver.
    * This doesn't prevent on-chain storage of data
    * Using chains of events keeps the door open for potentially using this same spec on other types of chains that support events.
* Discussed separating the contract upgradeability track so that work can start on other aspects of the contracts.
    * There is potential spec upgradeability that still needs to be considered
    * A simple solution is to use versions in the DID string. This also implies that potentially old resolvers still need to be maintained.
* Raised the possiblity of `initialState` params to be able to onboard more complex DID documents without transactions.
    * The only concern about this is that of lazy resolvers that don't bother to check on-chain and simply use the initialState as canon.
    * An example is the didKit implementation of did:ethr