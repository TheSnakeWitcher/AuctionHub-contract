# AuctionHub


AuctionHub is an descentralized auction platform.
**Its purpose is to allow you buy/sell in auctions easily any item**.


# Index


1. [Process](#Process)
3. [Documentation](#Documentation)
3. [Troubleshooting](#Troubleshooting)
4. [License](#License)


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


# Documentation


# Troubleshooting


# License


[MIT](./LICENSE.md)
