#!/bin/bash

 
port=6379
hostName=127.0.0.1
passwd=123456



# old
./redis-cli -h  ${hostName}    -p  ${port}   -a   ${passwd}   set  2.3.1_http://127.0.0.1:7080  http://127.0.0.1:7080/v1
./redis-cli -h  ${hostName}    -p  ${port}   -a   ${passwd}   set  2.3.0_http://127.0.0.1:7080  http://127.0.0.1:7080/v2
 



