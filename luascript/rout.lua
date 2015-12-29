--
-- Created by IntelliJ IDEA.
-- User: sdcuike
-- Date: 2015
-- Time: 下午4:09
--



-- 模块
local logUtil = require("luascript.Util")
local blacklistUtil = require("luascript.BlacklistUtil")
local redisUti = require("luascript.Redis")
local redisConfig  = require("luascript.RedisInit")
local cjson = require('cjson.safe')
local policyUtil = require("luascript.PolicyUtil")


-- 默认走源url
local scheme = ngx.var.scheme
local headers = ngx.req.get_headers()
local defaultUrl = scheme.."://"..headers["Host"]

-- ngx.var.backend = defaultUrl


-- 黑名单验证 begin --

local remoteAddr = ngx.var.remote_addr
logUtil.logInfo("remoteAddr:"..remoteAddr)


local red = redisUti:new(redisConfig.redisConf)

local ok, err = red:connectdb()

if not ok then
    logUtil.logError("redis connect error "..err)
    return
end


local policyKey = policyUtil.getPolicy(true)

if policyKey then

    local res, err = red.redis:get(policyKey)


    if not res then
        logUtil.logError("failed to get policyKey:"..policyKey.." error:"..err)
        return
    end


    if res and res == ngx.null then
        logUtil.logError("policyKey:"..policyKey.." not found ")

        policyKey = policyUtil.getPolicy(false)
        
        if not policyKey then
            return
        end

        res, err = red.redis:get(policyKey)

        if not res then
            logUtil.logError("failed to get policyKey:"..policyKey.." error:"..err)
            return
        end

        if res and res == ngx.null then
            logUtil.logError("policyKey:"..policyKey.." not found ")
        else
            logUtil.logInfo("policyKey:"..policyKey.." value:"..res)
             ngx.var.backend = res
        end


    else
        logUtil.logInfo("policyKey:"..policyKey.." value:"..res)
        ngx.var.backend = res
    end

end



--  stop

red:close()

local toUrl = ngx.var.backend
logUtil.logInfo("转发:"..toUrl)
--