pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/lifecycle/Pausable.sol';
import './SeeleToken.sol';


/// @title SeeleCrowdSale Contract
/// For more information about this token sale, please visit https://seele.pro
/// @author reedhong
contract SeeleCrowdSale is Pausable {
    using SafeMath for uint;

    /// Constant fields
    /// seele total tokens supply
    uint public constant SEELE_TOTAL_SUPPLY = 1000000000 ether;
    uint public constant MAX_SALE_DURATION = 4 days;
    uint public constant STAGE_1 = 6 hours;
    uint public constant STAGE_2 = 12 hours;
    uint public constant MIN_LIMIT = 0.1 ether;
    uint public constant MAX_STAGE_1_LIMIT = 1 ether;
    uint public constant MAX_STAGE_2_LIMIT = 2 ether;

    /// Exchange rates
    uint public  exchangeRate = 12500;


    uint public constant MINER_STAKE = 3000;    // for minter
    uint public constant OPEN_SALE_STAKE = 625; // for public
    uint public constant OTHER_STAKE = 6375;    // for others

    
    uint public constant DIVISOR_STAKE = 10000;

    // max open sale tokens
    uint public constant MAX_OPEN_SOLD = SEELE_TOTAL_SUPPLY * OPEN_SALE_STAKE / DIVISOR_STAKE;
    uint public constant STAKE_MULTIPLIER = SEELE_TOTAL_SUPPLY / DIVISOR_STAKE;

    /// All deposited ETH will be instantly forwarded to this address.
    address public wallet;
    address public minerAddress;
    address public otherAddress;

    /// Contribution start time
    uint public startTime;
    /// Contribution end time
    uint public endTime;

    /// Fields that can be changed by functions
    /// Accumulator for open sold tokens
    uint public openSoldTokens;
    /// ERC20 compilant seele token contact instance
    SeeleToken public seeleToken; 

    /// tags show address can join in open sale
    mapping (address => uint) public fullWhiteList;

    mapping (address => uint) public firstStageFund;
    mapping (address => uint) public secondStageFund;

    /*
     * EVENTS
     */
    event NewSale(address indexed destAddress, uint ethCost, uint gotTokens);
    event NewWallet(address onwer, address oldWallet, address newWallet);

    modifier notEarlierThan(uint x) {
        require(now >= x);
        _;
    }

    modifier earlierThan(uint x) {
        require(now < x);
        _;
    }

    modifier ceilingNotReached() {
        require(openSoldTokens < MAX_OPEN_SOLD);
        _;
    }  

    modifier isSaleEnded() {
        require(now > endTime || openSoldTokens >= MAX_OPEN_SOLD);
        _;
    }

    modifier validAddress( address addr ) {
        require(addr != address(0x0));
        require(addr != address(this));
        _;
    }

    function SeeleCrowdSale (
        address _wallet, 
        address _minerAddress,
        address _otherAddress
        ) public 
        validAddress(_wallet) 
        validAddress(_minerAddress) 
        validAddress(_otherAddress) 
        {
        paused = true;  
        wallet = _wallet;
        minerAddress = _minerAddress;
        otherAddress = _otherAddress;     

        openSoldTokens = 0;
        /// Create seele token contract instance
        seeleToken = new SeeleToken(this, msg.sender, SEELE_TOTAL_SUPPLY);

        seeleToken.mint(minerAddress, MINER_STAKE * STAKE_MULTIPLIER, false);
        seeleToken.mint(otherAddress, OTHER_STAKE * STAKE_MULTIPLIER, false);
    }

    function setExchangeRate(uint256 rate)
        public
        onlyOwner
        earlierThan(endTime)
    {
        exchangeRate = rate;
    }

    function setStartTime(uint _startTime )
        public
        onlyOwner
    {
        startTime = _startTime;
        endTime = startTime + MAX_SALE_DURATION;
    }

    /// @dev batch set quota for user admin
    /// if openTag <=0, removed 
    function setWhiteList(address[] users, uint openTag)
        public
        onlyOwner
        earlierThan(endTime)
    {
        require(saleNotEnd());
        for (uint i = 0; i < users.length; i++) {
            //WhiteList(users[i], openTag);
            fullWhiteList[users[i]] = openTag;
        }
    }


    /// @dev batch set quota for early user quota
    /// if openTag <=0, removed 
    function addWhiteList(address user, uint openTag)
        public
        onlyOwner
        earlierThan(endTime)
    {
        require(saleNotEnd());
        //WhiteList(user, openTag);
        fullWhiteList[user] = openTag;

    }

    /// @dev Emergency situation
    function setWallet(address newAddress)  external onlyOwner { 
        NewWallet(owner, wallet, newAddress);
        wallet = newAddress; 
    }

    /// @return true if sale not ended, false otherwise.
    function saleNotEnd() constant internal returns (bool) {
        return now < endTime && openSoldTokens < MAX_OPEN_SOLD;
    }

    /**
     * Fallback function 
     * 
     * @dev If anybody sends Ether directly to this  contract, consider he is getting seele token
     */
    function () public payable {
      buySeele(msg.sender);
    }

    /*
     * PUBLIC FUNCTIONS
     */
    /// @dev Exchange msg.value ether to Seele for account recepient
    /// @param receipient Seele tokens receiver
    function buySeele(address receipient) 
        public 
        payable 
        whenNotPaused  
        ceilingNotReached 
        earlierThan(endTime)
        validAddress(receipient)
        returns (bool) 
    {
        // Do not allow contracts to game the system
        require(!isContract(msg.sender));    
        require(tx.gasprice <= 100000000000 wei);
        require(msg.value >= MIN_LIMIT);

        uint inWhiteListTag = fullWhiteList[receipient];
        require(inWhiteListTag>0);
        
        if ( startTime <= now && now < startTime + STAGE_1 ) {
            require(msg.value <= MAX_STAGE_1_LIMIT);
        }else if ( startTime + STAGE_1 <= now && now < startTime + STAGE_2 ) {
            require(msg.value <= MAX_STAGE_2_LIMIT);
        }else {
            // 
        }

        doBuy(receipient);

        return true;
    }


    /// @dev Buy seele token normally
    function doBuy(address receipient) internal {
        // protect partner quota in stage one
        
        if ( startTime <= now && now < startTime + STAGE_1) {
            uint fund = firstStageFund[receipient];
            fund.add(msg.value);
            if (fund > 1 ether) {
                uint refund = fund.sub(MAX_STAGE_1_LIMIT);
                msg.value.sub(refund);
                msg.sender.transfer(refund);
            }
        }else if ( startTime + STAGE_1 <= now && now < startTime + STAGE_2 ) {
            uint fund = secondStageFund[receipient];
            fund.add(msg.value);
            if (fund > 2 ether) {
                uint refund = fund.sub(2 ether);
                msg.value.sub(refund);
                msg.sender.transfer(refund);
            }            
        }

        uint tokenAvailable = MAX_OPEN_SOLD.sub(openSoldTokens);
        require(tokenAvailable > 0);
        uint toFund;
        uint toCollect;
        (toFund, toCollect) = costAndBuyTokens(tokenAvailable);
        if (toFund > 0) {
            require(seeleToken.mint(receipient, toCollect,true));         
            wallet.transfer(toFund);
            openSoldTokens = openSoldTokens.add(toCollect);
            NewSale(receipient, toFund, toCollect);             
        }

        // not enough token sale, just return eth
        uint toReturn = msg.value.sub(toFund);
        if (toReturn > 0) {
            msg.sender.transfer(toReturn);
        }

        if ( startTime <= now && now < startTime + STAGE_1 ) {
            firstStageFund[receipient].add(msg.value);
        }else if ( startTime + STAGE_1 <= now && now < startTime + STAGE_2 ) {
            secondStageFund[receipient].add(msg.value);          
        }
    }

    /// @dev Utility function for calculate available tokens and cost ethers
    function costAndBuyTokens(uint availableToken) constant internal returns (uint costValue, uint getTokens) {
        // all conditions has checked in the caller functions
        getTokens = exchangeRate * msg.value;

        if (availableToken >= getTokens) {
            costValue = msg.value;
        } else {
            costValue = availableToken / exchangeRate;
            getTokens = availableToken;
        }
    }

    /// @dev Internal function to determine if an address is a contract
    /// @param _addr The address being queried
    /// @return True if `_addr` is a contract
    function isContract(address _addr) constant internal returns(bool) {
        uint size;
        if (_addr == 0) {
            return false;
        }

        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }
}