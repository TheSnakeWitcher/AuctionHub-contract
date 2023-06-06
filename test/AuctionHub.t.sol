// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19 ;


import "../lib/forge-std/src/Test.sol" ;
import "./TestUtil.t.sol" ;
import "../src/AuctionHub.sol" ;
import "../src/EscrowERC20.sol" ;


address constant POLYGON_TOKEN_ADDRESS = 0xc2132D05D31c914a87C6611C10748AEb04B58e8F ;
address constant MUMBAI_TOKEN_ADDRESS = 0xA02f6adc7926efeBBd59Fd43A84f4E0c0c91e832 ;
uint32 constant AUCTION_FEE = 5 ;
uint32 constant AUCTION_PERIOD = 5 weeks ;

address constant newSeller = makeAddr("seller") ;
uint32 constant newAuctionFee = 20 ;
uint32 constant newAuctionPeriod = 2 weeks ;
bytes constant MsgOnlyOwner = "Ownable: caller is not the owner" ;


contract AuctionHubTest is Test , TestUtil {

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

    AuctionHub testContract ;

    function setUp() public {
        _mumbaiFork = vm.createFork(vm.rpcUrl(_mumbaiForkName)) ;
        vm.selectFork(_mumbaiFork) ;
        testContract = new AuctionHub(MUMBAI_TOKEN_ADDRESS,AUCTION_FEE,AUCTION_PERIOD) ;
    }


    function test_getAuctionPeriod() public {
        uint32 auctionPeriod = testContract.getAuctionPeriod() ;
        assertEq(auctionPeriod,AUCTION_PERIOD) ;
    }

    function test_setAuctionPeriod_calledByOwner() public {
        testContract.setAuctionPeriod(newAuctionPeriod) ;  
        uint32 auctionPeriod = testContract.getAuctionPeriod() ;
        assertEq(auctionPeriod,newAuctionPeriod) ;
    }

    function test_setAuctionPeriod_calledByOwner_emit_AuctionPeriodChanged() public {
        vm.expectEmit(true,false,false,false,address(testContract)) ;
        emit AuctionPeriodChanged(newAuctionPeriod) ;
        testContract.setAuctionPeriod(newAuctionPeriod) ;  

        uint32 auctionPeriod = testContract.getAuctionPeriod() ;
        assertEq(auctionPeriod,newAuctionPeriod) ;
    }

    function testFail_setAuctionPeriod_calledByUser() public {
        vm.prank(makeAddr("user")) ;
        testContract.setAuctionPeriod(newAuctionPeriod) ;  
    }

    function testRevert_setAuctionPeriod_calledByUser() public {
        vm.expectRevert(MsgOnlyOwner);
        vm.prank(makeAddr("user")) ;
        testContract.setAuctionPeriod(newAuctionPeriod) ;  
    }


    function test_getAuctionFee() public {
        uint32 auctionFee = testContract.getAuctionFee() ;
        assertEq(auctionFee,AUCTION_FEE) ;
    }

    function test_setAuctionFee_calledByOwner() public {
        testContract.setAuctionFee(newAuctionFee) ;
        uint32 auctionFee = testContract.getAuctionFee() ;
        assertEq(auctionFee,newAuctionFee) ;
    }

    function test_setAuctionFee_calledByOwner_emit_AuctionFeeChanged() public {
        vm.expectEmit(true,false,false,false,address(testContract)) ;
        emit AuctionFeeChanged(newAuctionFee) ;
        testContract.setAuctionFee(newAuctionFee) ;

        uint32 auctionFee = testContract.getAuctionFee() ;
        assertEq(auctionFee,newAuctionFee) ;
    }

    function testFail_setAuctionFee_calledByUser() public {
        vm.prank(makeAddr("user"));
        testContract.setAuctionFee(newAuctionFee) ;
    }

    function testFail_setAuctionFee_calledBy0Address() public {
        vm.prank(address(0));
        testContract.setAuctionFee(newAuctionFee) ;
    }

    function testRevert_setAuctionFee_calledByUser() public {
        vm.expectRevert(MsgOnlyOwner);
        vm.prank(makeAddr("user"));
        testContract.setAuctionFee(newAuctionFee) ;
    }


    // function test_auctionStartOnTokenTransfer() public  {
    //     vm.deal() ;
    // }


    // function test_stopAuction() public {
    //     testContract.stopAuction(seller);
    // }
    //
    // function test_stopAuction_calledByOwner() public {
    //     testContract.stopAuction(seller);
    // }
    //
    // function test_stopAuction_calledByUser() public {
    //     testContract.stopAuction(seller);
    // }


    // function test_getBid_calledByBidder_toExistentAuction() public {
    //     vm.prank(makeAddr("user")) ;
    //     testContract.getBid(seller);
    // }
    //
    // function test_getBid_calledByBidder_toUnexistentAuction() public {
    //     vm.prank(makeAddr("user")) ;
    //     testContract.getBid(seller);
    // }
    //
    // function test_getBid_calledByUser_toExistentAuction() public {
    //     vm.prank(makeAddr("user")) ;
    //     testContract.getBid(seller);
    // }
    //
    // function test_getBid_calledByUser_toUnexistentAuction() public {
    //     vm.prank(makeAddr("user")) ;
    //     testContract.getBid(seller);
    // }


    // function test_bid_ExistentBidder_ExistentAuction() public {
    //     testContract.bid(seller);
    // }
    //
    // function test_bid_ExistentBidder_UnexistentAuction() public {
    //     testContract.bid(seller);
    // }
    //
    // function test_bid_UnexistentBidder_ExistentAuction() public {
    //     testContract.bid(seller);
    // }
    //
    // function test_bid_UnexistentBidder_UnexistentAuction() public {
    //     testContract.bid(seller);
    // }


    // function test_withdrawn_ExistentBidder_ExistentAuction() public {
    //     testContract.withdrawn(newSeller);
    // }
    //
    // function test_withdrawn_ExistentBidder_UnexistentAuction() public {
    //     testContract.withdrawn(newSeller);
    // }
    //
    // function test_withdrawn_UnexistentBidder_ExistentAuction() public {
    //     testContract.withdrawn(newSeller);
    // }
    //
    // function test_withdrawn_UnexistentBidder_UnexistentAuction() public {
    //     testContract.withdrawn(newSeller);
    // }


    // function test_move() public {
    //     testContract.move(seller);
    // }

}
