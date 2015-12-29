#!/bin/bash

 
port=6379
hostName=127.0.0.1
passwd=123456



# old
./redis-cli -h  ${hostName}    -p  ${port}   -a   ${passwd}   set  key value
 



