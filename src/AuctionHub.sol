//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19; // test PUSH0 using pragma solidity ^0.8.20 
pragma abicoder v2;


import "../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "./EscrowERC20.sol";

import "./PausableByOwner.sol";
import "../lib/openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";


/**
 * @title AuctionHub
 * @author Alex Virelles <thesnakewitcher@gmail.com>
 */
contract AuctionHub is IERC721Receiver, PausableByOwner, ReentrancyGuard {

    event AuctionStarted(
        address indexed seller,
        uint256 indexed startAt,
        uint256 indexed endAt,
        uint256 startPrice
    );
    event AuctionStoped(
        address indexed seller,
        address indexed highestBidder,
        uint256 indexed endPrice
    );
    event AuctionCanceled(address seller, uint256 itemId, uint256 startPrice);
    event BidIncreased(address newHighestBidder, uint256 newHighestBid);
    event AuctionFeeChanged(uint256 indexed auctionFee);
    event AuctionPeriodChanged(uint256 indexed auctionPeriod);

    modifier endedAuction(address seller) {
        require(auctions[seller].startAt == 0, "ActionHub: auction pending");
        _;
    }

    struct AuctionData {
        uint256 startPrice;    /// item start price
        uint256 startAt;       /// time when auction starts
        uint256 endAt;         /// time when auction ends
        uint256 fee;           /// auction fee
        address highestBidder; /// auction highest bidder
        uint256 itemId;        /// auctioned item id
        address itemContract;  /// auctioned item id
    }

    mapping(address => AuctionData) private auctions;

    uint32 private auctionPeriod;
    uint32 private auctionFee;
    EscrowERC20 private escrow;

    constructor(address _tokenAddress,uint32 _auctionFee,uint32 _auctionPeriod) {
        escrow = new EscrowERC20(_tokenAddress);
        auctionFee = _auctionFee;
        auctionPeriod = _auctionPeriod;
    }

    /**
     * @return current value of `auctionPeriod`
     */
    function getAuctionPeriod() public view returns (uint32) {
        return auctionPeriod;
    }

    /**
     * @notice change value of `auctionPeriod`
     *         period of auction in process will not change
     *         on a call to this function due that an auction
     *         period is seted at their beggining
     */
    function setAuctionPeriod(uint32 _auctionPeriod) external onlyOwner {
        auctionPeriod = _auctionPeriod;
        emit AuctionPeriodChanged(_auctionPeriod) ;
    }

    /**
     * @return current value of `auctionFee`
     */
    function getAuctionFee() public view returns (uint32) {
        return auctionFee;
    }

    /**
     * @return AuctionData of `seller` auction
     */
    function getAuctionData(address seller) external view returns (AuctionData memory) {
        return auctions[seller] ;
    }

    /**
     * @notice called by `owner` to change `auctionFee`
     *         fee of auction in process will not change
     *         on a call to this function due that an auction
     *         period is seted at their beggining
     */
    function setAuctionFee(uint32 _auctionFee) external onlyOwner {
        auctionFee = _auctionFee;
        emit AuctionFeeChanged(_auctionFee);
    }

    /**
     * @notice called by contract when receive a ERC721 token and
     *         an auction meet requirements the to be started
     */
    function startAuction(
        address seller,
        uint256 itemId,
        address itemContract,
        uint256 startPrice
    ) private {
        uint256 startAt = block.timestamp;
        uint256 endAt = startAt + getAuctionPeriod();

        auctions[seller] = AuctionData({
            startPrice: startPrice,
            startAt: startAt,
            endAt: endAt,
            fee: getAuctionFee(),
            highestBidder: address(0),
            itemId: itemId,
            itemContract: itemContract
        });
        emit AuctionStarted(seller, startAt, endAt, startPrice);
    }

    /**
     * @notice called automatically at `endAt` of auctions to
     *         select an auction winner if any,stop auction and
     *         claim profits of `seller` and `owner`
     */
    function stopAuction(address seller) external {
        AuctionData memory auction = auctions[seller];
        require(block.timestamp < auction.endAt, "ActionHub: auction ended") ;

        address highestBidder = auction.highestBidder;
        if (highestBidder == address(0)) {
            delete auctions[seller];
            emit AuctionCanceled(seller, auction.itemId, auction.startPrice);
            IERC721(auction.itemContract).approve(seller,auction.itemId) ;
            return ;
        }

        uint256 endPrice = _getBid(seller, highestBidder);
        delete auctions[seller];
        emit AuctionStoped(seller, highestBidder, endPrice);

        uint256 fee = auction.fee / 100;
        escrow.claim(seller, highestBidder, fee,owner());
        IERC721(auction.itemContract).approve(highestBidder,auction.itemId) ;
    }

    /**
     * @notice called by bidder to get his `bid` on auction of `seller`
     * @return current `bid` amount
     */
    function getBid(address seller) external view returns (uint256) {
        return _getBid(seller, _msgSender()) ;
    }

    /**
     * @notice called by bidder to `bid` in `seller` auction
     */
    function bid(address _seller, uint256 _bid) external {
        require(auctions[_seller].startAt == 0, "ActionHub: auction pending");
        address bidder = _msgSender();
        address highestBidder = auctions[_seller].highestBidder;

        uint256 currentBid = _getBid(_seller, bidder);
        uint256 highestBid = _getBid(_seller, highestBidder);
        uint256 newHighestBid = currentBid + _bid;

        require(newHighestBid > highestBid, "AuctionHub: needed higher bid");
        escrow.deposit(_seller, bidder, _bid);
        auctions[_seller].highestBidder = bidder;
        emit BidIncreased(bidder, newHighestBid);
    }

    /**
     * @notice called by `bidder` to withdraw his bids from `seller` auction
     *
     * Emits a {Withdrawn} event
     * See {EscrowERC20}
     */
    function withdraw(address seller) external endedAuction(seller) nonReentrant {
        escrow.withdraw(seller, _msgSender());
    }

    /**
     * @notice called by `bidder` to move his balance from
     *         auction of `seller` to auction of `newSeller`
     *
     * Emits a {Moved} event
     * See {EscrowERC20} event
     */
    function move(address seller, address newSeller) external endedAuction(seller) {
        escrow.move(seller, newSeller, _msgSender());
    }

    /**
     * @dev See {IERC721Receiver-onERC721Received}
     * @notice start a new auction when receive an ERC721
     * @return `IERC721Receiver.onERC721Received.selector` to accept transaction
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes memory data
    ) public virtual override whenNotPaused returns (bytes4) {
        require(
            auctions[from].startAt == 0,
            "AuctionHub: seller has a auction already"
        );
        uint256 startPrice = abi.decode(data, (uint256));
        startAuction(from, tokenId,operator, startPrice);
        return this.onERC721Received.selector;
    }

    /**
    * @return bid of `bidder` in auction of `seller`
    */
    function _getBid(address seller,address bidder) private view returns (uint256) {
        return escrow.depositsOf(seller,bidder);
    }

}
