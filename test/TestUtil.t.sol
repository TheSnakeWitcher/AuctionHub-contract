//SPDX-License-Identifier: UNLICENCED
pragma solidity ^0.8;
pragma abicoder v2;


/**
 * @title TestUtil
 * @dev   Base utility contract for tests, holds variables/functions
 *        common to most test cases
 *
 * Description:
 *
 * This module is used through inheritance. It will make available the
 * all variables/constant/functions.
 */
abstract contract TestUtil {

    /// deployer address used by foundry during test
    address constant _DEPLOYER_ADDRESS = 0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84 ;

    // forks
    uint256 internal _localFork;
    uint256 internal _btcFork;
    uint256 internal _tbtcFork;
    uint256 internal _ethereumFork;
    uint256 internal _goerliFork;
    uint256 internal _polygonFork;
    uint256 internal _mumbaiFork;
    uint256 internal _avalancheFork;
    uint256 internal _fujiFork;
    uint256 internal _bscFork;
    uint256 internal _bsctFork;

    // forks blocks
    uint256 internal _localForkBlock;
    uint256 internal _btcForkBlock;
    uint256 internal _tbtcForkBlock;
    uint256 internal _ethereumForkBlock;
    uint256 internal _goerliForkBlock;
    uint256 internal _polygonForkBlock;
    uint256 internal _mumbaiForkBlock;
    uint256 internal _avalancheForkBlock;
    uint256 internal _fujiForkBlock;
    uint256 internal _bscForkBlock;
    uint256 internal _bsctForkBlock;

    // forks names
    string internal _localForkName = "local" ;
    string internal _btcForkName = "btc" ;
    string internal _tbtcForkName = "tbtc" ;
    string internal _ethereumForkName = "ethereum" ;
    string internal _goerliForkName = "goerli" ;
    string internal _polygonForkName = "polygon" ;
    string internal _mumbaiForkName = "mumbai" ;
    string internal _avalancheForkName = "avalanche " ;
    string internal _fujiForkName = "fuji " ;
    string internal _bscForkName = "bsc " ;
    string internal _bsctForkName = "bsct " ;


    function genAddr() public returns (address) {
        /* 
            return makeAddr(randomTextGenerator())
            return makeAddr(randomNumberGenerator())
        */
    }

}
