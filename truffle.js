module.exports = {
  networks: {
    develop: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*" // Match any network id
    },

    test: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*" // Match any network id
    },

    mine: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*", // Match any network id
      //gas: 4700036
    },

    mainnet: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*", // Match any network id
      //gas: 4700036
    },

    ropsten:  {
      network_id: "*", // Match any network id
      host: "localhost",
      port:  8545,
      gas: 4700036
    }
  }  
};