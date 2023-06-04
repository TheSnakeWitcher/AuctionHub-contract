//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0 ;
pragma abicoder v2 ;


import "../lib/openzeppelin-contracts/contracts/security/Pausable.sol" ;
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol" ;


/**
 * @title PausableByOwner
 * @dev This contract is intended to be a preset of `Pausable` contract
 *      that use `Ownable` contract that make public pause/unpause
 *      capabilities but restrict its access to contract owner.
 *
 * Description:
 *
 * The modifier onlyOwner can restrict access to critical functions.
 * With this extensions can exist an aditional separation
 * between admin capabilities and pausable user capabilities.
 */
contract PausableByOwner is Ownable , Pausable {

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     * - contract must not be paused
     * - caller must be the owner
     */
    function pause() public onlyOwner {
      _pause();
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - contract must be paused
     * - caller must be the owner
     */
    function unpause() public onlyOwner {
      _unpause();
    }

}
