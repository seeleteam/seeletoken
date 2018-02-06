var SeeleCrowdSale = artifacts.require("SeeleCrowdSale");

module.exports = function(deployer, network, accounts) {
  console.log('network is '+network);
  console.log(accounts);
  console.log(accounts[0]);
  if(network == 'develop' || network == 'test'){
    console.log('deploy SeeleCrowdSale contract to develop network, account address is '+accounts[0]);
    deployer.deploy(SeeleCrowdSale, accounts[0],accounts[1],accounts[2],accounts[3],accounts[4]);

  }else if(network == 'mine'){
    console.log('deploy SeeleCrowdSale contract to mine network, account address is '+accounts[0]);
    let now = (new Date()).valueOf()/1000;
    deployer.deploy(SeeleCrowdSale, "0x9f54644be957d34720f5b728214233ef64c40390", 
      "0x39668764c03d32577c0d0ced923f50dbfccbb324","0x5d4b8d2c0c09f46f5b6fabb25b78e08518dd1d9a",
      "0xa99d1dfcafa25ae0029fef1008835bc7c07946db", "0xafff6cbbf276e195c5689a5d8dc21e83c5c09029",
      "0x91be17353f311a9d25fc9b927254a8d4bdcbed10",now);

  }else{
    console.log('just test')
  }
};
