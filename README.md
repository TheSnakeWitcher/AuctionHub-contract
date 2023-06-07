# AuctionHub


AuctionHub is an decentralized auction platform. **Its purpose is to
allow you to buy/sell in auctions easily any item**. The contract is
written in solidity and is deployed on Goerli testnet at address
`0xE2449a4ea0e0A9FC5D3A53Ce8F31c3b4d4D20067`. Check transaction
hash `0x6ec6e206abf3005980b693d8652edfbf097613f542f9535972b27f3b871cddaf`.

The ui is a basic svelte app(i am not a front end developer) , code
here [AuctionHub-ui](https://github.com/TheSnakeWitcher/AuctionHub-ui)
and the server is written in go and can be found here
[AuctionHub-server](https://github.com/TheSnakeWitcher/AuctionHub-server)

NOTE: Due to some time problems I could not finish a completely
      functional app , but any way post the code.


# Process


1. A owner transfer a ERC721 token to contract.

2. When a token is received the contract starts an auction in behalf of
   token owner with some starting price determined by the owner it self.

3. Bidders can bid using the platform, every new bid must be
   greater than the last like in a normal auction, this is
   enforced by the contract. Every bid tokens are transfered
   to an escrow contract that locks this tokens untill auction
   stops.

4. The `stopAuction` function of contract needs to be called after
   the `auctionPeriod` has ended to determine auction result, this
   is done automatically by the a server but can be done by any account.

5. When `stopAuction` is trigger if there is not an highest bidder then
   the auction is canceled an owner can withdraw his token, if there is
   an highest bidder owner can withdrawn his profits minus a fee charged
   by the platform and highest bidder can withdraw the token.

6. When auction stops bidders(except highest bidder) can withdraw his
   bids or move its to another auction.


# License


[MIT](./LICENSE.md)
