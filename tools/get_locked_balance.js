var config = require("./config");
var SeeleToken = artifacts.require("SeeleToken");
var SeeleCrowdSale = artifacts.require("SeeleCrowdSale");
var fs = require('fs');
var BigNumber = require('bignumber.js');

var readFile = async function (fileName) {
  return new Promise(function (resolve, reject) {
    fs.readFile(fileName, function (error, data) {
      if (error) reject(error);
      resolve(data);
    });
  });
};


var get_whitelist_lock_balance = async function () {
  console.log('token_address is ' + config.token_address);
  let tokenContract = await SeeleToken.at(config.token_address);

  let owner = await tokenContract.owner();
  console.log("saleContract owner: " + owner);

  var data = await readFile(config.whitelist_file);
  var content = data.toString();
  var whitelist = content.split("\n");
  var total = new BigNumber("0");
  //console.log(total);
  for(var i in whitelist){
    var addr = whitelist[i]
    let tokenCount = await tokenContract.lockedBalances(addr);
    let ethCount = web3.fromWei(tokenCount, 'ether');
    //console.log(ethCount);
    total = total.plus(ethCount);
    //console.log(total);
    if(tokenCount > 0){
      console.log(addr)
    }
  }
  console.log('total', total);
};

module.exports = function (callback) {
  console.log('tool start')
//  console.log(web3.eth.accounts)
//   var unlock = web3.personal.unlockAccount(config.from_account, config.from_account_password);
//   console.log(unlock);
    get_whitelist_lock_balance();
  //call_reclaim();
  console.log('tool end')
}