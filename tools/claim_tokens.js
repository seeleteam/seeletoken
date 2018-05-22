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


var claim_tokens = async function () {
  console.log('token_address is ' + config.token_address);
  let tokenContract = await SeeleToken.at(config.token_address);

  let owner = await tokenContract.owner();
  console.log("tokenContract owner: " + owner);

  var data = await readFile(config.claim_address_file);
  var content = data.toString();
  var address_list = content.split("\n");
  console.log(address_list);
  console.log('from account balance: ' + web3.fromWei(web3.eth.getBalance(config.from_account), "ether"));
  var transaction = await tokenContract.claimTokens(address_list, {from: config.from_account, gasPrice:config.gasPrice, gas:config.gasLimit });
  console.log(transaction);
};

module.exports = function (callback) {
  console.log('tool start')
//  console.log(web3.eth.accounts)
//   var unlock = web3.personal.unlockAccount(config.from_account, config.from_account_password);
//   console.log(unlock);
  claim_tokens();
  //call_reclaim();
  console.log('tool end')
}