pragma solidity ^0.4.4;

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
    uint public maxTotalSupply;

    /// Fields that are only changed in constructor
    /// seele sale  contract
    address public minter; 

    /// ICO start time
    uint public startTime;
    /// ICO end time
    uint public endTime;

    /*
     * MODIFIERS
     */
    modifier onlyMinter {
        assert(msg.sender == minter);
        _;
    }

    modifier isLaterThan (uint x){
        assert(now > x);
        _;
    }

    modifier maxTokenAmountNotReached (uint amount){
        assert(totalSupply.add(amount) <= maxTotalSupply);
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
     * @param _startTime start time
     * @param _endTime End Time
     */
    function SeeleToken(address _minter, address _admin, uint _maxTotalSupply, uint _startTime, uint _endTime) 
        public 
        validAddress(_admin)
        validAddress(_minter)
        {
        minter = _minter;
        startTime = _startTime;
        endTime = _endTime;
        maxTotalSupply = _maxTotalSupply;
        transferOwnership(_admin);
    }

    /**
     * EXTERNAL FUNCTION 
     * 
     * @dev SeeleCrowdSale contract instance mint token
     * @param receipent The destination account owned mint tokens    
     * @param amount The amount of mint token
     * be sent to this address.
     */

    function mint(address receipent, uint amount)
        external
        onlyMinter
        maxTokenAmountNotReached(amount)
        returns (bool)
    {
        require(now <= endTime);
        balances[receipent] = balances[receipent].add(amount);
        totalSupply = totalSupply.add(amount);
        return true;
    }
}