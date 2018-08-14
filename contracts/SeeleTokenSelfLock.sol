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


    SeeleToken public token = SeeleToken(0x773de57850ADA330014cFe7bf786495E6Be5e735);
    address public teamLockAddress = 0x773de57850ADA330014cFe7bf786495E6Be5e735;
    
    uint256 public teamLockedAmount = 50000000 ether;
    address public teamLockAddress;
    uint public perLockTime =  30 days;
    uint public perLockAmount = 4000000 ether;

    uint256 public lockedAt = 0; 

    uint256 public lastUnlockTime = 0;

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

    function SeeleTokenSelfLock() 
        public 
        {
            // nothing
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
            
        require(token.balanceOf(address(this)) == teamLockedAmount);
        
        lockedAt = block.timestamp;
        lastUnlockTime = lockedAt;
    }

    /**
    * @notice Transfers tokens held by timelock to private.
    */
    function unlock() public 
        locked 
        onlyOwner
        {
        
        uint25 currenLockTime = lastUnlockTime.add(perLockTime);
        require(block.timestamp >= currenLockTime);

        uint256 amount = token.balanceOf(this);
        require(amount >= perLockAmount);

        token.transfer(teamLockAddress, perLockAmount);
        
        lastUnlockTime = currenLockTime;
    }

    function unlockFinal() public 
        locked 
        onlyOwner
        {
        uint25 finalLockTime = lockedAt.add(perLockTime*12);
        require(block.timestamp >= finalLockTime);

        uint256 amount = token.balanceOf(this);
        token.transfer(teamLockAddress, amount);
        
        lastUnlockTime = currenLockTime;
    }
}
