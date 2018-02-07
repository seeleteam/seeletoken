pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/token/PausableToken.sol';


/// @title SeeleToken Contract
/// For more information about this token sale, please visit https://seele.pro
/// @author reedhong
contract SeeleToken is PausableToken {
    using SafeMath for uint;

    /// Constant token specific fields
    string public constant name = "SeeleToken";
    string public constant symbol = "Seele";
    uint public constant decimals = 18;

    /// seele total tokens supply
    uint public currentSupply;

    /// Fields that are only changed in constructor
    /// seele sale  contract
    address public minter; 

    /// Fields that can be changed by functions
    mapping (address => uint) public lockedBalances;

    /*
     * MODIFIERS
     */
    modifier onlyMinter {
        assert(msg.sender == minter);
        _;
    }

    modifier maxTokenAmountNotReached (uint amount){
        assert(currentSupply.add(amount) <= totalSupply);
        _;
    }

    modifier validAddress( address addr ) {
        require(addr != address(0x0));
        require(addr != address(this));
        _;
    }

    /**
     * CONSTRUCTOR 
     * 
     * @dev Initialize the Seele Token
     * @param _minter The SeeleCrowdSale Contract 
     * @param _maxTotalSupply total supply token    
     */
    function SeeleToken(address _minter, address _admin, uint _maxTotalSupply) 
        public 
        validAddress(_admin)
        validAddress(_minter)
        {
        minter = _minter;
        totalSupply = _maxTotalSupply;
        transferOwnership(_admin);
    }

    /**
     * EXTERNAL FUNCTION 
     * 
     * @dev SeeleCrowdSale contract instance mint token
     * @param receipent The destination account owned mint tokens    
     * @param amount The amount of mint token
     * @param isLock Lock token flag
     * be sent to this address.
     */

    function mint(address receipent, uint amount, bool isLock)
        external
        onlyMinter
        maxTokenAmountNotReached(amount)
        returns (bool)
    {
        if (isLock ) {
            lockedBalances[receipent] = lockedBalances[receipent].add(amount);
        } else {
            balances[receipent] = balances[receipent].add(amount);
        }
        currentSupply = currentSupply.add(amount);
        return true;
    }

     /*
     * PUBLIC FUNCTIONS
     */

    /// @dev Locking period has passed - Locked tokens have turned into tradeable
    function claimTokens(address receipent)
        public
        onlyOwner
    {
        balances[receipent] = balances[receipent].add(lockedBalances[receipent]);
        lockedBalances[receipent] = 0;
    }

    /*
     * CONSTANT METHODS, get lock balance of address
     */
    function lockedBalanceOf(address _addr) 
        constant 
        public
        returns (uint balance) 
        {
        return lockedBalances[_addr];
    }
}