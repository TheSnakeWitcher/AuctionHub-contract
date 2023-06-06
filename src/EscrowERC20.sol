// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/escrow/Escrow.sol)
pragma solidity ^0.8.19;
pragma abicoder v2 ;


import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol" ;
import "../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol" ;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";


/**
 * @title EscrowErc20
 * @dev This contract is based on {Escrow} contract to
 *      to be able to hold ERC20 tokens
 *
 * See {escrow}
 */
contract EscrowERC20 is Ownable {

    using SafeERC20 for IERC20 ;

    event Deposited(address indexed seller,address indexed bidder, uint256 indexed amount);
    event Withdrawn(address indexed seller,address indexed bidder, uint256 indexed amount);
    event Moved(address indexed seller,address indexed newSeller,address indexed bidder,uint256 amount);

    mapping(address => mapping(address => uint256)) private _deposits; /// bids in `seller` auction of `bidder`
    // mapping(address => mapping(address => uint256)) private _pool;
    IERC20 token ;


    /**
     * @notice escrow contract handle transfers of `token`
     */
    constructor(address _token) {
        token = IERC20(_token) ;
    }

    /**
     * @notice get address of `token` managed by contract
     */
    function getToken() public view returns (address) {
        return address(token);
    }

    /**
     * @notice get deposits of `bidder` in auction of `seller`
     */
    function depositsOf(address seller,address bidder) public view returns (uint256) {
        return _deposits[seller][bidder];
    }

    /**
     * @dev Stores the sent amount as credit to be withdrawn.
     * @param seller The destination address of the funds.
     *
     * Emits a {Deposited} event.
     */
    function deposit(address seller,address bidder,uint256 bid) public payable virtual onlyOwner {
        token.safeTransferFrom(bidder,address(this),bid) ;
        _deposits[seller][bidder] += bid;
        emit Deposited(seller,bidder,bid);
    }

    /**
     * @notice Move accumulated balance of `bidder` in auction
     *         of `seller` to auction of `newSeller`
     * @param seller The address of current auction
     * @param newSeller The address of new auction
     * @param bidder The address of bidder
     *
     * Emits a {Move} event.
     */
    function move(address seller,address newSeller,address bidder) public virtual onlyOwner {
        uint256 bid = bidOf(seller,bidder);
        _deposits[newSeller][bidder] = bid;
        emit Moved(seller,newSeller,bidder,bid);
    }

    /**
     * @dev Withdraw accumulated balance of `token` for `payee`
     * @param seller The address that will received tokens
     *
     * Emits a {Withdrawn} event.
     */
    function withdraw(address seller,address bidder) public virtual onlyOwner {
        uint256 payment = bidOf(seller,bidder);
        token.safeTransferFrom(address(this),bidder,payment) ;
        emit Withdrawn(seller,bidder,payment);
    }

    /**
     * @dev Withdraw accumulated balance of `token` for `payee`
     * @param seller The address that will received tokens
     *
     * Emits a {Withdrawn} event.
     */
    function claim(address seller,address bidder,uint256 fee,address owner) public virtual onlyOwner {
        uint256 payment = bidOf(seller,bidder) ;
        uint256 ownerPayment = payment * fee ;
        uint256 sellerPayment = payment - ownerPayment ;

        token.safeTransferFrom(address(this),seller,sellerPayment) ;
        token.safeTransferFrom(address(this),owner,ownerPayment) ;
        emit Withdrawn(seller,bidder,payment);
    }

    /**
    * @notice get bid of `bidder` on auction of `seller` 
    * @return `bid` of `bidder` on auction of `seller` 
    */
    function bidOf(address seller,address bidder) private returns (uint256) {
        uint256 bid = _deposits[seller][bidder] ; 
        _deposits[seller][bidder] = 0 ;
        return bid ;
    }

}
