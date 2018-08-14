#!/bin/bash

cd flatten_contracts 
rm -rf *
cd ..
truffle-flattener contracts/SeeleCrowdSale.sol >flatten_contracts/SeeleCrowdSaleFlat.sol
truffle-flattener contracts/SeeleToken.sol >flatten_contracts/SeeleTokenFlat.sol
truffle-flattener contracts/SeeleTokenLock.sol >flatten_contracts/SeeleTokenLockFlat.sol
truffle-flattener contracts/TestToken.sol >flatten_contracts/TestTokenFlat.sol
truffle-flattener contracts/AirDropContract.sol >flatten_contracts/AirDropContractFlat.sol
truffle-flattener contracts/SeeleTokenSelfLock.sol >flatten_contracts/SeeleTokenSelfLockFlat.sol