pragma solidity ^0.4.4;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/token/ERC20.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import './SeeleToken.sol';

/**
 * @title SeeleTokenLock
 * @dev SeeleTokenLock for lock some seele token
 */
contract SeeleTokenLock is Ownable {
    using SafeMath for uint;


    SeeleToken public token;

    // timestamp when token release is enabled
    uint public firstPrivateLockTime =  90 days;
    uint public secondPrivateLockTime = 180 days;
    uint public minerLockTime = 120 days;
    
    // release time
    uint public firstPrivateReleaseTime = 0;
    uint public secondPrivateReleaseTime = 0;
    uint public minerRelaseTime = 0;
    
    // amount
    uint public firstPrivateLockedAmount = 160000000 ether;
    uint public secondPrivateLockedAmount = 80000000 ether;
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

    function SeeleTokenLock(address _seeleToken, address _privateLockAddress,  address _minerLockAddress) 
        public 
        validAddress(_seeleToken)
        validAddress(_privateLockAddress)
        validAddress(_minerLockAddress) 
        {

        token = SeeleToken(_seeleToken);
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
            
        uint totalLockedAmount = firstPrivateLockedAmount.add(secondPrivateLockedAmount);
        totalLockedAmount = totalLockedAmount.add(minerLockedAmount);

        require(token.balanceOf(address(this)) == totalLockedAmount);
        
        lockedAt = block.timestamp;

        firstPrivateReleaseTime = lockedAt.add(firstPrivateLockTime);
        secondPrivateReleaseTime = lockedAt.add(secondPrivateLockTime);
        minerRelaseTime = lockedAt.add(minerLockTime);
    }

    /**
    * @notice Transfers tokens held by timelock to private.
    */
    function unlockFirstPrivate() public 
        locked 
        onlyOwner
        {
        require(block.timestamp >= firstPrivateReleaseTime);
        require(firstPrivateLockedAmount > 0);

        uint256 amount = token.balanceOf(this);
        require(amount >= firstPrivateLockedAmount);

        token.transfer(privateLockAddress, firstPrivateLockedAmount);
        firstPrivateLockedAmount = 0;
    }


    /**
    * @notice Transfers tokens held by timelock to private.
    */
    function unlockSecondPrivate() public 
        locked 
        onlyOwner
        {
        require(block.timestamp >= secondPrivateReleaseTime);
        require(secondPrivateLockedAmount > 0);

        uint256 amount = token.balanceOf(this);
        require(amount >= secondPrivateLockedAmount);

        token.transfer(privateLockAddress, secondPrivateLockedAmount);
        secondPrivateLockedAmount = 0;
    }

    /**
    * @notice Transfers tokens held by timelock to miner.
    */
    function unlockMiner() public 
        locked 
        onlyOwner
        {
        require(block.timestamp >= minerRelaseTime);
        require(minerLockedAmount > 0);
        uint256 amount = token.balanceOf(this);
        require(amount >= minerLockedAmount);
        token.transfer(minerLockAddress, minerLockedAmount);

        minerLockedAmount = 0;
    }
}
