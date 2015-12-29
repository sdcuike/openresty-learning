#! /bin/bash

version=` /usr/local/openresty/nginx/sbin/nginx -V `

/usr/local/openresty/nginx/sbin/nginx -t    -p  ~/etc/openrestyscript  -c  ~/etc/openrestyscript/nginx.conf

 