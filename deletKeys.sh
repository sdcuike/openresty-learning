#!/bin/bash

 
port=6379
hostName=127.0.0.1
passwd=123456

keys="*_"

./redis-cli -h  ${hostName}   -p ${port}  -a ${passwd}  keys  "$keys" | xargs   ./redis-cli -h  ${hostName}   -p ${port}  -a ${passwd}  del



