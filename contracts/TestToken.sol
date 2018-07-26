pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/token/PausableToken.sol';


/// @author reedhong
contract TestToken is PausableToken {
    using SafeMath for uint;

    /// Constant token specific fields
    string public constant name = "TestToken";
    string public constant symbol = "Test";
    uint public constant decimals = 18;

    function TestToken() 
        public 
        {
        totalSupply = 1000000 ether;
        paused = false;
        balances[0x0039988DAFc038058d19512DDF477Ff4a1649846] = totalSupply;
    }
}