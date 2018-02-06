pragma solidity ^0.4.4;
//import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/lifecycle/Pausable.sol';

contract TestAddress is Pausable {
    //address public admin;
    
    modifier validAddress( address addr ) {
        require(addr != address(0x0));
        require(addr != address(this));
        _;
    }
    function TestAddress (address _admin, uint val ) public validAddress(_admin) {
        transferOwnership(_admin);
    }
}