var TestAddress = artifacts.require("TestAddress");

module.exports = function(deployer, network, accounts) {
  console.log('network is '+network);
  console.log(accounts);
  deployer.deploy(TestAddress, accounts[0], 100);
};
