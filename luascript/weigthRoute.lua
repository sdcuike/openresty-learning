--
-- Created by IntelliJ IDEA.
-- User: sdcuike
-- Date: 16/1/11
-- Time: 上午10:05
-- To change this template use File | Settings | File Templates.
--

--[[  根据权重路由请求   --]]


local redisUti = require("luascript.Redis")
local redisConfig  = require("luascript.RedisInit")
local WeightedRoundRobin  = require("luascript.WeightedRoundRobin")
local cjson = require('cjson.safe')
local resty_lock = require("resty.lock")

local current_weigtht_lock = resty_lock:new("current_weigtht_lock")
local effecitve_weight_lock = resty_lock:new("effecitve_weight_lock")



local wrt = ngx.shared.server_current_weigtht_cache


local routForAppName = "routForAppName"     -- redis  哈希（Hashes) 路由信息key
local exptime = 1000 --

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
local function init_server_current_weigth(key,server_effecitve_weight,current_weigtht_lock,cjson)

    local server_current_weigth = {}
    print("init server_current_weigth for all 0 ")
    for k, v in pairs(server_effecitve_weight) do
        server_current_weigth[k] = 0
    end


    local wrt = ngx.shared.server_current_weigtht_cache
    local elapsed_lock, err_lock = current_weigtht_lock:lock(key)

    if not elapsed_lock then
        ngx.log(ngx.ERR,"[[".."failed to acquire the current_weigtht_lock:"..err_lock.."]]")
    end


    local succ, err, forcible = wrt:set(key, cjson.encode(server_current_weigth), 0)

    local ok_unlock, err_unlock = current_weigtht_lock:unlock()
    if not ok_unlock then
        ngx.log(ngx.ERR,"[[".."failed to unlock the lock:"..err_unlock.."]]")
    end



    if not succ then
        ngx.log(ngx.ERR,"[[".."update server_current_weigth cache error:"..err.."]]")
    end

end



--
-- 获取服务配置权重信息;缓存 or  redis
local function get_server_effecitve_weight(key,routForAppNameForRedis,effecitve_weight_lock,exptime,redisUti,redisConfig,cjson)
    local ewt = ngx.shared.server_effecitve_weight_cache

    local server_effecitve_weight = ewt:get(key)

    if not server_effecitve_weight then
        -- redis获取
        local red = redisUti:new(redisConfig.redisConf)

        local ok, err = red:connectdb()

        if not ok then
            ngx.log(ngx.ERR, "[[".."redis connect error "..err.."]]")
            return nil
        end

        --

        local res, err = red.redis:hget(routForAppNameForRedis,key)

        if not res then
            ngx.log(ngx.ERR, "[[".."failed to get redisHKey:"..key.."  from redis, error:"..err.."]]")
            return nil
        end

        if res and res == ngx.null then
            ngx.log(ngx.ERR,"[[".."policyKey:"..key.." not found from redis".."]]")
            return nil
        end

        ngx.log(ngx.INFO, "[[".."route:"..res.."]]")


        server_effecitve_weight = res

        --save cache

        local elapsed_lock, err_lock = effecitve_weight_lock:lock(key)

        if not elapsed_lock then
            ngx.log(ngx.ERR,"[[".."failed to acquire the lock:"..err_lock.."]]")
        end


        local succ, err, forcible = ewt:set(key, res, exptime)
        if not succ then
            ngx.log(ngx.ERR,"[[".."update erver_effecitve_weight_cache cache error:"..err.."]]")
        end


        local ok_unlock, err_unlock = effecitve_weight_lock:unlock()
        if not ok_unlock then
            ngx.log(ngx.ERR,"[[".."failed to unlock the effecitve_weight_lock:"..err_unlock..key.."]]")
        end
        --


    end


    return cjson.decode(server_effecitve_weight)
end







local host = ngx.req.get_headers()["Host"]

-- local uri = ngx.var.uri

local scheme = ngx.var.scheme

local infoForHost = "scheme:"..scheme.." host:"..host


ngx.log(ngx.INFO, "[["..infoForHost.."]]")


local redisHKey = scheme.."://"..host
ngx.log(ngx.INFO, "[[".."redisHKey:"..redisHKey.."]]")




-- 测试lua table 格式化的json
--[[
local tt = {["http://127.0.0.1:7080/lua"] = 30,["http://127.0.0.1:7080"] = 70}
local tv = cjson.encode(tt)
ngx.log(ngx.INFO, tv)

--]]

--

if not routeJson then
    ngx.log(ngx.ERR,"[[".."policyKey which from redis have not valid value type".."]]")
    return
end


--

local elapsed_lock, err_lock = current_weigtht_lock:lock(redisHKey)

if not elapsed_lock then
    ngx.log(ngx.ERR,"[[".."failed to acquire the lock:"..err_lock.."]]")
end

local server_current_weigth = get_server_current_weigth(redisHKey,routeJson)

local ok_unlock, err_unlock = current_weigtht_lock:unlock()
if not ok_unlock then
    ngx.log(ngx.ERR,"[[".."failed to unlock the lock:"..err_unlock.."]]")
end


--
ngx.log(ngx.INFO,"[[".."befor get destination".."]]")
for k, v in pairs(server_current_weigth) do
    ngx.log(ngx.INFO,"[[".."key:"..k.." value:"..v.."]]")
end
--



--
local destination = WeightedRoundRobin.get(server_current_weigth,routeJson)
ngx.var.backend = destination


--
ngx.log(ngx.INFO,"after get destination")
for k, v in pairs(server_current_weigth) do
    ngx.log(ngx.INFO,"[[".."key:"..k.." value:"..v.."]]")
end

--


local elapsed_lock, err_lock = current_weigtht_lock:lock(redisHKey)

if not elapsed_lock then
    ngx.log(ngx.ERR,"[[".."failed to acquire the lock:"..err_lock.."]]")
end


local succ, err, forcible = wrt:set(redisHKey, cjson.encode(server_current_weigth), 0)

local ok_unlock, err_unlock = current_weigtht_lock:unlock()
if not ok_unlock then
    ngx.log(ngx.ERR,"[[".."failed to unlock the lock:"..err_unlock.."]]")
end



if not succ then
    ngx.log(ngx.ERR,"[[".."update server_current_weigth cache error:"..err.."]]")
end



--  stop

red:close()

local toUrl = ngx.var.backend
ngx.log(ngx.INFO,"[[".."转发:"..toUrl.."]]")
--