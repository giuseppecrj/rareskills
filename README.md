# rareskills

- [x] An NFT on OpenSea. Create an ERC721 NFT that can be minted for free and has a collection of 10 items with traits and pictures. It should work on OpenSea per the tutorial. Use goerli or polygon for gas savings. Make sure I can mint your NFT from etherscan! You can follow the above tutorial to accomplish this

  - https://goerli.etherscan.io/address/0xc300B6b14b5e17F1D93637E74718D3c1266296f7

- [ ] ERC721 NFT with staking. You must create 3 separate smart contracts:

  - [ ] an ERC20 token
  - [ ] An ERC721 token
  - [ ] and a third smart contract that can mint new ERC20 tokens and receive ERC721 tokens. A classic feature of NFTs is being able to receive them to stake tokens. Users can send their NFTs and withdraw 10 ERC20 tokens every 24 hours. Don’t forget about decimal places! The user can withdraw the NFT at any time. The smart contract must take possession of the NFT and only the user should be able to withdraw it.

- [ ] ERC721Enumerable. The ERC721Enumerable protocol allows us to determine on-chain which NFTs are owned by an address.

  - [ ] Create a new NFT collection with 20 items using ERC721Enumerable. The token ids should be 1..20 inclusive.
  - [ ] Create a second smart contract that has a function which accepts an address and returns how many NFTs are owned by that address which have tokenIDs that are prime numbers. For example, if an address owns tokenIds 10, 11, 12, 13, it should return 2. In a real blockchain game, these would refer to special items, but we only care about the abstract functionality for this exercise.

- [ ] safeTransferFrom and transferFrom. What are the differences between these two functions? Create a markdown file describing their differences.

---
