pragma solidity ^0.4.4;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/token/ERC20.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import './SeeleToken.sol';

/**
 * @title SeeleTokenSelfLock
 * @dev SeeleTokenSelfLock for lock some seele token
 */
contract SeeleTokenSelfLock is Ownable {
    using SafeMath for uint;


    SeeleToken public token = SeeleToken(0xA28d8b77F95874D0a05aA74A05DE9083b92C1216);
    address public teamLockAddress = 0x00B04d6D08748B073E4D827A7DA515Cb13921c0c;
    
    uint256 public teamLockedAmount = 50000000 ether;
    uint public perLockTime =  10 minutes ; //30 days;
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
        
        uint256 currenLockTime = lastUnlockTime.add(perLockTime);
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
        uint256 finalLockTime = lockedAt.add(perLockTime*12);
        require(block.timestamp >= finalLockTime);

        uint256 amount = token.balanceOf(this);
        token.transfer(teamLockAddress, amount);
    }
}
