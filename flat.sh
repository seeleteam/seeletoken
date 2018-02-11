#!/bin/bash

cd flatten_contracts 
rm -rf *
cd ..
truffle-flattener contracts/SeeleCrowdSale.sol >flatten_contracts/SeeleCrowdSaleFlat.sol
