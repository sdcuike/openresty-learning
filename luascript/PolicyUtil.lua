--
-- Created by IntelliJ IDEA.
-- User: sdcuike
-- Date: 2015
-- Time: 下午4:09
--



local logUtil = require("luascript.Util")



local modulename = "PolicyUtil"
local _M = {}
_M._VERSION = '0.0.1'


local separator = "_"

-- 协议头版本号header 名
local versioncode = "versioncode"

_M.getPolicy = function(includeUri)

    local headers = ngx.req.get_headers()
    --
    for k, v in pairs(headers) do
        logUtil.logInfo("key:"..k.." value:"..v)
    end
    --

    local version = headers[versioncode]
    if not version then
        ngx.log(ngx.ERR, "[[".."failed to get versioncode from http header".."]]")
        return nil
    end
    
    local host = headers["Host"]
    -- local uri = ngx.escape_uri(ngx.var.uri)
    local uri = ngx.var.uri
    logUtil.logInfo("uri:"..uri)
    local scheme = ngx.var.scheme

    local src =""
    if includeUri then
        src = scheme.."://"..host..uri
    else
        src = scheme.."://"..host
    end
    
    local policyKey = version..separator..src

    logUtil.logInfo("policyKey:"..policyKey)

    return policyKey

end

return _M
