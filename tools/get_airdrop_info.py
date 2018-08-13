#!/bin/python

address_list = open('airdrop_address.txt').read().split('\n')
print("address len %d "%len(address_list))
sa = ",".join(address_list)
print sa

value_list = open('airdrop_value.txt').read().split('\n')
print("value len %d "%len(value_list))
va = ",".join([item+"000000000000000000" for item in value_list])
print va