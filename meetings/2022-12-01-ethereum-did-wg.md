# Ethereum DID WG - 2022-12-01

### Attendees:
- [Ajay Jadhav](ajay@ayanworks.com)
- [Cody Hatfield](cody.hatfield@me.com)
- [Dennis von der Bey](dennis@vonderbey.eu)
- [Hersh Patel](hersh.patel@trinsic.id)
- [Italo Borssatto](italo.borssatto@mesh.xyz)
- [Keith Kowal](keith.kowal@swirldslabs.com)
- [Lauritz Leifermann](laudileif@gmail.com)
- [Mircea Nistor](mircea.nistor@mesh.xyz)
- [Nick Reynolds](nick.reynolds@mesh.xyz)
- [Otto Mora](omora@polygon.technology)
- [Philipp Bolte](philipp@bolte.id)
- [Simonas Karužas](simonas.karuzas@mesh.xyz)
- [Stephan Baur](stephan.x.baur@kp.org)


Notes:

- Did:ethr spec has been maintained by the Veramo team
- Some improvements have been suggested during IIW35
- The Spherity team brought a review from IIW35. Basically, what is in the [notes](https://docs.google.com/document/d/1iKtSEJk88Kdj9Wlhsu5qXM6MoWNzOplZIAy_EjKjhM8/edit)[ ](https://docs.google.com/document/d/1iKtSEJk88Kdj9Wlhsu5qXM6MoWNzOplZIAy_EjKjhM8/edit)[from](https://docs.google.com/document/d/1iKtSEJk88Kdj9Wlhsu5qXM6MoWNzOplZIAy_EjKjhM8/edit)[ ](https://docs.google.com/document/d/1iKtSEJk88Kdj9Wlhsu5qXM6MoWNzOplZIAy_EjKjhM8/edit)[IIW](https://docs.google.com/document/d/1iKtSEJk88Kdj9Wlhsu5qXM6MoWNzOplZIAy_EjKjhM8/edit)[35 ](https://docs.google.com/document/d/1iKtSEJk88Kdj9Wlhsu5qXM6MoWNzOplZIAy_EjKjhM8/edit)[meeting](https://docs.google.com/document/d/1iKtSEJk88Kdj9Wlhsu5qXM6MoWNzOplZIAy_EjKjhM8/edit).
- Governance issues were discussed:
  - Which entity will host repositories?
    - DIF, EF and a new DAO have been brought as options.
    - Current governance should be evolved, not centralized in the Veramo team.
    - If EF is chosen to host the new spec it'd be interesting to have other specs using Ethereum listed.
    - There are some worries about start using EF as the host, just to have more flexibility initially.
    - Veramo will be the host of new discussions initially and later we can donate to DIF
    - Nick asked if there are any concerns on having the Veramo team hosting initially? No.
    - The new repository is: [https](https://github.com/veramolabs/did-eth)[://](https://github.com/veramolabs/did-eth)[github](https://github.com/veramolabs/did-eth)[.](https://github.com/veramolabs/did-eth)[com](https://github.com/veramolabs/did-eth)[/](https://github.com/veramolabs/did-eth)[veramolabs](https://github.com/veramolabs/did-eth)[/](https://github.com/veramolabs/did-eth)[did](https://github.com/veramolabs/did-eth)[-](https://github.com/veramolabs/did-eth)[eth](https://github.com/veramolabs/did-eth)
    - Some people brought the difficulties of accessing DIF and participating. It's an intimidating flow to be onboarded. Too many barriers for newbies.
  - How mail lists will manage participants
- Is the project an evolution of current did:ethr or we move to a new spec in a new repository? Should it be backward compatible?
  - Spherity team already talked about these issues and they suggested moving to a totally new specification. Start fresh!
  - Stephan Baur prefers going to the option to increment the current version
  - Questions about how many have been using the DID method. Difficult to answer. 
- Requirements for the new DID method:
  - A new did method for EVM compatible networks
    - Does it interfere with having EF as the host in the future?
  - Upgradability:
    - Diamond pattern suggested
    - Check all the security issues when adopting upgradability
  - Identify requirements like decentralized storage as well
  - Messaging
    - On use cases, the main use case I am interested in is messaging. Specifically enabling an EVM wallet to use DIDComm Messaging, which basically comes down to allowing encryption keys to be added to keyAgreements. There is no standard around attaching encryption keys to an ETH address.
  - Support to account abstraction was also mentioned.
- Stephan Baur brought the importance of evolving from the existing DID method, in terms of functionality upgrades.
- Need to have EF involved and have them educated about the DID efforts.
- Bounties and grants
  - Important for smart contract reviews
  - Having the method maintained by a non-profit institution help on that
- Next meeting will be organized in 2 slots (30 mins each): governance and technical discussions.
- [Discussions](https://github.com/veramolabs/did-eth/discussions)[ ](https://github.com/veramolabs/did-eth/discussions)[in](https://github.com/veramolabs/did-eth/discussions)[ ](https://github.com/veramolabs/did-eth/discussions)[Github](https://github.com/veramolabs/did-eth/discussions) started during the meeting!

