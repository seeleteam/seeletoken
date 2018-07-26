var config = require("./config");
var AirDropContract = artifacts.require("AirDropContract");
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


var airdrop = async function () {
  console.log('airdropContract is ' + config.airdrop_contract_address);
  let airdropContract = await AirDropContract.at(config.airdrop_contract_address);


  var adderss_data = await readFile(config.airdrop_address_file);
  var content = adderss_data.toString();
  var address_list = content.split("\n");

  var value_data = await readFile(config.airdrop_value_file);
  content = value_data.toString();
  var value_list = content.split("\n");

  if( address_list.length != value_list.length){
    console.log('list value error');
    return ;
  }


  console.log(address_list);
  console.log('from account balance: ' + web3.fromWei(web3.eth.getBalance(config.airdrop_from_account), "ether"));
  var transaction = await airdropContract.transfer(config.erc20_contract_address, address_list,value_list,
    {from: config.airdrop_from_account, gasPrice:config.gasPrice, gas:config.gasLimit });
  console.log(transaction);

};

module.exports = function (callback) {
  console.log('tool start')
//  console.log(web3.eth.accounts)
//   var unlock = web3.personal.unlockAccount(config.from_account, config.from_account_password);
//   console.log(unlock);
    airdrop();
  //call_reclaim();
  console.log('tool end')
}