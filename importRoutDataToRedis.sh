#!/bin/bash

 
port=6379
hostName=127.0.0.1
passwd=123456



./redis-cli -h  ${hostName}    -p  ${port}   -a   ${passwd}   hset  routForAppName  http://127.0.0.1:7080  '{"http://127.0.0.1:7080/weigthRoute1":40,"http://127.0.0.1:7080/weigthRoute2":50,"http://127.0.0.1:7080/weigthRoute3":10}'

 



