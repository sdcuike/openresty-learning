--
-- Created by IntelliJ IDEA.
-- User: sdcuike
-- Date: 2015
-- Time: 下午4:09
--


--[[    redisConf redis配置文件    --]]

local modulename = "RedisInit"
local _M = {}

_M._VERSION = '0.0.1'

_M.redisConf = {
    ["host"]     = '127.0.0.1',
    ["port"]     = '6379',
    ["passwd"]   ="123456",          --redis passwd
    ["poolsize"] = 1000,             --redis ngx_lua cosocket connection pool https://github.com/openresty/lua-resty-redis
    ["idletime"] = 90000,
    ["timeout"]  = 10000,
    ["dbid"]     = 0                 --redis select db command
}


return _M
