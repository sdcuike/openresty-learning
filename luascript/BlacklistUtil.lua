--
-- Created by IntelliJ IDEA.
-- User: sdcuike
-- Date: 2015
-- Time: 下午4:09
--


local modulename = "BlacklistUtil"
local _M = {}
_M._VERSION = '0.0.1'

local blacklistTableName = "nginx_blacklist"

-- 规则匹配,(正则等的支持....)
local checkIp = function(ip)
    if ip == blackRegex then
        return true
    end
end



_M.check = function(red, ip)
    local response =  red.redis:sismember(blacklistTableName,ip)

    if response == 1 then
        return true
    end

    return false
end




return _M

