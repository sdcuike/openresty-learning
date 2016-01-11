--
-- Created by IntelliJ IDEA.
-- User: sdcuike
-- Date: 16/1/11
-- Time: 上午10:05
-- To change this template use File | Settings | File Templates.
--

local redisUti = require("luascript.Redis")
local redisConfig  = require("luascript.RedisInit")
local WeightedRoundRobin  = require("luascript.WeightedRoundRobin")

local cjson = require('cjson.safe')

local routForAppName = "routForAppName"
--
local red = redisUti:new(redisConfig.redisConf)

local ok, err = red:connectdb()

if not ok then
    ngx.log(ngx.ERR, "[[".."redis connect error "..err.."]]")
    return
end

--


local host = ngx.req.get_headers()["Host"]

-- local uri = ngx.var.uri

local scheme = ngx.var.scheme

local infoForHost = "scheme:"..scheme.." host:"..host


ngx.log(ngx.INFO, "[["..infoForHost.."]]")


local redisHKey = scheme.."://"..host
ngx.log(ngx.INFO, "[[".."redisHKey:"..redisHKey.."]]")


local res, err = red.redis:hget(routForAppName,redisHKey)

if not res then
    ngx.log(ngx.ERR, "[[".."failed to get redisHKey:"..redisHKey.." error:"..err.."]]")
    return
end

if res and res == ngx.null then
    ngx.log(ngx.ERR,"policyKey:"..redisHKey.." not found ")
    return
end


ngx.log(ngx.INFO, "[[".."route:"..res.."]]")

local routeJson = cjson.decode(res)

-- 测试lua table 格式化的json
--[[
local tt = {["http://127.0.0.1:7080/lua"] = 30,["http://127.0.0.1:7080"] = 70}
local tv = cjson.encode(tt)
ngx.log(ngx.INFO, tv)

--]]

--

if not routeJson then
    ngx.log(ngx.ERR,"policyKey have not valid value type:")
    return
end



local destination = WeightedRoundRobin.get(routeJson)
ngx.var.backend = destination

--  stop

red:close()

local toUrl = ngx.var.backend
ngx.log(ngx.INFO,"转发:"..toUrl)
--