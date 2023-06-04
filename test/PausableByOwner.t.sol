// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19 ;


import "../lib/forge-std/src/Test.sol" ;
import "./TestUtil.t.sol" ;
import "../src/PausableByOwner.sol" ;


bytes constant MsgPaused = "Pausable: paused" ;
bytes constant MsgUnpaused = "Pausable: not paused" ;
bytes constant MsgNotOwner = "Ownable: caller is not the owner" ;


contract PausableByOwnerTest is Test , TestUtil {

    PausableByOwner testContract ;

    event Paused(address account);
    event Unpaused(address account);

    function setUp() public {
        testContract = new PausableByOwner() ;
    }

    function test_pause_owner() public {
        vm.expectEmit(false,false,false,true,address(testContract));
        emit Paused(address(this));
        testContract.pause() ;
    }

    function testFail_pause_owner_already_paused_contract() public {
        testContract.pause() ;
        testContract.pause() ;
    }

    function testRevert_pause_owner_already_paused_contract() public {
        vm.expectEmit(false,false,false,true,address(testContract));
        emit Paused(address(this));
        testContract.pause() ;

        vm.expectRevert(MsgPaused);
        testContract.pause() ;
    }

    function testFail_pause_not_owner() public {
        vm.prank(makeAddr("user")) ;
        testContract.pause() ;
    }

    function testRevert_pause_not_owner() public {
        vm.expectRevert(MsgNotOwner);
        vm.prank(makeAddr("user")) ;
        testContract.pause() ;
    }

    function testFail_pause_0address() public {
        vm.prank(address(0));
        testContract.pause();
    }

    function testRevert_pause_0address() public {
        vm.expectRevert(MsgNotOwner);
        vm.prank(address(0));
        testContract.pause();
    }

    function testFail_pause_already_paused_contract() public {
        testContract.pause();
        testContract.pause();
    }

    function testRevert_pause_already_paused_contract() public {
        vm.expectEmit(false,false,false,true,address(testContract));
        emit Paused(address(this));
        testContract.pause();

        vm.expectRevert(MsgPaused);
        testContract.pause();
    }

    function test_unpause_owner() public {
        vm.expectEmit(false,false,false,true,address(testContract));
        emit Paused(address(this));
        testContract.pause();

        vm.expectEmit(false,false,false,true,address(testContract));
        emit Unpaused(address(this));
        testContract.unpause();
    }

    function testFail_unpause_owner_already_unpaused_contract() public {
        testContract.unpause();
    }

    function testRevert_unpause_owner_already_unpaused_contract() public {
        vm.expectRevert(MsgUnpaused);
        testContract.unpause();
    }

    function testFail_unpause_not_owner() public {
        vm.prank(makeAddr("user")) ;
        testContract.unpause();
    }

    function testRevert_unpause_not_owner(address user) public {
        vm.expectRevert(MsgNotOwner) ;
        vm.prank(user) ;
        testContract.unpause() ;
    }

    function testFail_unpause_0address() public {
        vm.prank(address(0));
        testContract.unpause();
    }

    function testRevert_unpause_0address() public {
        vm.expectRevert(MsgNotOwner) ;
        vm.prank(address(0));
        testContract.unpause();
    }

    function testFail_unpause_already_unpaused_contract_by_user() public {
        vm.prank(makeAddr("user")) ;
        testContract.unpause();
    }

    function testRevert_unpause_already_unpaused_contract() public {
        vm.expectEmit(false,false,false,true,address(testContract)) ;
        emit Paused(address(this)) ;
        testContract.pause() ;

        vm.expectRevert(MsgNotOwner) ;
        vm.prank(makeAddr("user")) ;
        testContract.unpause();
    }
}
