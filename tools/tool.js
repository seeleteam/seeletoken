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

var call_reclaim = async function () {
  let tokenContract = await SeeleToken.at(config.token_address);
  console.log(tokenContract);
  let owner = await tokenContract.owner();
  console.log("tokenContract owner: " + owner);
  // var transaction = await tokenContract.unlockFoundationToken({ from: config.from_account });
  // console.log(transaction);
}

var call_set_whitelist = async function () {
  console.log('sale_contract_address is ' + config.sale_contract_address);
  let saleContract = await SeeleCrowdSale.at(config.sale_contract_address);

  let saleOwner = await saleContract.owner();
  console.log("saleContract owner: " + saleOwner);

  var data = await readFile(config.whitelist_file);
  var content = data.toString();
  var whitelist = content.split("\n");
  console.log(whitelist);
  console.log('from account balance: ' + web3.fromWei(web3.eth.getBalance(config.from_account), "ether"));
  var transaction = await saleContract.setWhiteList(whitelist, config.whitelist_flag, {from: config.from_account, 
    gasPrice:config.gasPrice });
  console.log(transaction);
};

module.exports = function (callback) {
  console.log('tool start')
  console.log(web3.eth.accounts)
  var unlock = web3.personal.unlockAccount(config.from_account, config.from_account_password);
  console.log(unlock);
  call_set_whitelist();
  //call_reclaim();
  console.log('tool end')
}