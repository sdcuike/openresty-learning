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
local resty_lock = require("resty.lock")

local current_weigtht_lock = resty_lock:new("my_lock")

local wrt = ngx.shared.server_current_weigtht_cache



-- 更新当前权重 TODO:redis路由信息更新更新server_current_weigth
local function get_server_current_weigth(key,server_effecitve_weight)
    local wrt = ngx.shared.server_current_weigtht_cache

    local server_current_weigth = wrt:get(key)

    -- 缓存没有,刚启动ningx情况下
    if not server_current_weigth then
        ngx.log(ngx.INFO, "[[".."cache not find server_current_weigth for key: "..key.."]]")
        server_current_weigth = {}
        print("init server_current_weigth for all 0 ")
        for k, v in pairs(server_effecitve_weight) do
            server_current_weigth[k] = 0
        end

        return server_current_weigth
    end


    -- TODO:缓存有,但redis路由信息更新了

    --

    return cjson.decode(server_current_weigth)
end

--


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


--

local elapsed_lock, err_lock = current_weigtht_lock:lock(redisHKey)

if not elapsed_lock then
    ngx.log(ngx.ERR,"failed to acquire the lock:",err_lock)
end

local server_current_weigth = get_server_current_weigth(redisHKey,routeJson)

local ok_unlock, err_unlock = current_weigtht_lock:unlock()
if not ok_unlock then
    ngx.log(ngx.ERR,"failed to unlock the lock:",err_unlock)
end


--
ngx.log(ngx.INFO,"befor get destination")
for k, v in pairs(server_current_weigth) do
    ngx.log(ngx.INFO,"key:"..k.." value:"..v)
end
--



--
local destination = WeightedRoundRobin.get(server_current_weigth,routeJson)
ngx.var.backend = destination


--
ngx.log(ngx.INFO,"after get destination")
for k, v in pairs(server_current_weigth) do
    ngx.log(ngx.INFO,"key:"..k.." value:"..v)
end

--


local elapsed_lock, err_lock = current_weigtht_lock:lock(redisHKey)

if not elapsed_lock then
    ngx.log(ngx.ERR,"failed to acquire the lock:",err_lock)
end


local succ, err, forcible = wrt:set(redisHKey, cjson.encode(server_current_weigth), 0)

local ok_unlock, err_unlock = current_weigtht_lock:unlock()
if not ok_unlock then
    ngx.log(ngx.ERR,"failed to unlock the lock:",err_unlock)
end



if not succ then
    ngx.log(ngx.ERR,"update server_current_weigth cache error:"..err)
end



--  stop

red:close()

local toUrl = ngx.var.backend
ngx.log(ngx.INFO,"转发:"..toUrl)
--