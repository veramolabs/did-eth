# Ethereum DID WG - 2023-01-26

## Attendees
- [Cody Hatfield](cody.hatfield@me.com)
- [Hersh Patel](hersh.patel@trinsic.id)
- [Mircea Nistor](mircea.nistor@mesh.xyz)
- [Nick Reynolds](nick.reynolds@mesh.xyz)
- [Otto Mora](omora@polygon.technology)
- [Philipp Bolte](philipp@bolte.id)
- [Simonas Karužas](simonas.karuzas@mesh.xyz)
- [Stephan Baur](stephan.x.baur@kp.org)
- and more...

## Notes
- Naming poll: did:evm won by a slight margin to did:eth
    - Nick: did:eth is more understandable as a user facing identifier
    - Hersh: People might confuse the method specific part as an ethereum address; did:evm could be an umbrella-term and did:eth lives under it
    - another poll incoming/ async discussion
- PR from Nick
    - created template file for new spec
    - people can bring in the content step by step
    - accepted and merged by group
- PR from Hersh
    - example implementation of diamond pattern did:ethr contract
    - (non-)adoption of 1056 still open topic
    - quick walkthrough by Hersh:
        - alternative to proxy pattern which has security issues
        - DID.sol (diamond) registers modules containing functions; can be delegate-called by the proxy
        - registering/ removing/ updating modules (e.g. resolvers) could be selectively permissioned (public vs DAO)
        - common storage space for all resolvers
        - resolving through diamond or resolver module directly could work
    - Mircea:
        - resolver implementers would need to adopt the storage pattern of the diamond
        - focus of modules: functionality (e.g. signature verifier) instead of resolvers
- Nick: split what parts of the DID document can be resolved on-chain vs off-chain
    - Sidetree inspiration: long-form and short-form DID

## Next up
- Next week: Polygon shows their DID method
- Coming weeks: requirements (*submit them in issues*), spec work

