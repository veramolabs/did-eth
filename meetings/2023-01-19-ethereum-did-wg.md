# Ethereum DID WG 2023-01-19

Notes:
- Review technical discussion regarding Solidity Diamond pattern
    - clarified resolver for the did:ethr upgrade vs universal evm resolver
- Hersh committed to developing Diamond Pattern version of did-ethr
- Need someone to upgrade "normal" contract
    - replace or extend signing pattern (relates to meta tx?) / use EIP-712 / EIP-191
    - consider "upgrade" path
    - allow user to choose which elements are on-chain vs event-only
    - Action Item: fork did-ethr repos
        - publicKeyHex -> publicKeyMultibase
        - "owner" vs "controller"
    - https://eips.ethereum.org/EIPS/eip-1056
        - do we need breaking changes against this EIP for new DID method
- Prioritize did-core compliance
    - ethr/smart contract owner vs controller key
- Poll for name
- DID URL support