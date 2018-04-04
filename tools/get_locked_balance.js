var config = require("./config");
var SeeleToken = artifacts.require("SeeleToken");
var SeeleCrowdSale = artifacts.require("SeeleCrowdSale");
var fs = require('fs');

var readFile = async function (fileName) {
  return new Promise(function (resolve, reject) {
    fs.readFile(fileName, function (error, data) {
      if (error) reject(error);
      resolve(data);
    });
  });
};


var get_whitelist_lock_balance = async function () {
  //console.log('sale_contract_address is ' + config.sale_contract_address);
  let tokenContract = await SeeleToken.at(config.token_address);

  let owner = await tokenContract.owner();
  console.log("saleContract owner: " + owner);

  var data = await readFile(config.all_whitelist_file);
  var content = data.toString();
  var whitelist = content.split("\n");
  for(var i in whitelist){
    var addr = whitelist[i]
    let tokenCount = await tokenContract.lockedBalances(addr);
    console.log(tokenCount)
  }
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