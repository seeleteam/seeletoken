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
        totalSupply = 100000000 ether;
        paused = false;
        balances[0x0020116131498D968DeBCF75E5A11F77e7e1CadE] = totalSupply;
    }
}