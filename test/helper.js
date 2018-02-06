exports.fromWei = function(n) {
    return new web3.BigNumber(web3.fromWei(n, 'ether'))
}

exports.toWei = function(n) {
    return new web3.BigNumber(web3.toWei(n, 'ether'))
  }