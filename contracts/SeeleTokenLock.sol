pragma solidity ^0.4.4;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/token/ERC20.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import './SeeleToken.sol';

/**
 * @title SeeleTokenTimelock
 * @dev TokenTimelock is a token holder contract that will allow a
 * beneficiary to extract the tokens after a given release time
 */
contract SeeleTokenLock is Ownable {
    using SafeMath for uint;


    SeeleToken public token;

    // timestamp when token release is enabled
    uint public privateLockTime = 90 days;
    uint public minerLockTime = 140 days;
    
    // release time
    uint public privateReleaseTime = 0;
    uint public minerRelaseTime = 0;
    
    // amount
    uint public privateLockedAmount = 200000000 ether;
    uint public minerLockedAmount = 300000000 ether;

    address public privateLockAddress;
    address public minerLockAddress;

    uint public lockedAt = 0; 

    //Has not been locked yet
    modifier notLocked {
        require(lockedAt == 0);
        _;
    }

    modifier locked {
        require(lockedAt > 0);
        _;
    }

    modifier validAddress( address addr ) {
        require(addr != address(0x0));
        require(addr != address(this));
        _;
    }

    function TokenTimelock(ERC20 _token, address _privateLockAddress,  address _minerLockAddress) 
        public 
        validAddress(_privateLockAddress)
        validAddress(_minerLockAddress) 
        {

        token = SeeleToken(_token);
        privateLockAddress = _privateLockAddress;
        minerLockAddress = _minerLockAddress;
    }

    //In the case locking failed, then allow the owner to reclaim the tokens on the contract.
    //Recover Tokens in case incorrect amount was sent to contract.
    function recoverFailedLock() public 
        notLocked  
        onlyOwner 
        {
        // Transfer all tokens on this contract back to the owner
        require(token.transfer(owner, token.balanceOf(address(this))));
    }


    function lock() public 
        notLocked 
        onlyOwner 
        {
        uint totalLockedAmount = privateLockedAmount.add(minerLockedAmount);
        require(token.balanceOf(address(this)) == totalLockedAmount);
        
        lockedAt = block.timestamp;

        privateReleaseTime = lockedAt.add(privateLockTime);
        minerRelaseTime = lockedAt.add(minerLockTime);
    }

    /**
    * @notice Transfers tokens held by timelock to beneficiary.
    */
    function unlockPrivate() public locked {
        require(block.timestamp >= privateReleaseTime);

        uint256 amount = token.balanceOf(this);
        require(amount >= privateLockedAmount);
        token.transfer(privateLockAddress, privateLockedAmount);
    }

    /**
    * @notice Transfers tokens held by timelock to beneficiary.
    */
    function unlockMiner() public locked {
        require(block.timestamp >= minerRelaseTime);

        uint256 amount = token.balanceOf(this);
        require(amount >= minerLockedAmount);
        token.transfer(minerLockAddress, minerLockedAmount);
    }
}
