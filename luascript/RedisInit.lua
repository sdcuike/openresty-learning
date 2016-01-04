--
-- Created by IntelliJ IDEA.
-- User: sdcuike
-- Date: 2015
-- Time: 下午4:09
--



local modulename = "RedisInit"
local _M = {}

_M._VERSION = '0.0.1'

_M.redisConf = {
    ["host"]     = '127.0.0.1',
    ["port"]     = '6379',
    ["passwd"]   ="123456",
    ["poolsize"] = 1000,
    ["idletime"] = 90000,
    ["timeout"]  = 10000,
    ["dbid"]     = 0
}


return _M
