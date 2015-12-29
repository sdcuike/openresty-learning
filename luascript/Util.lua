--
-- Created by IntelliJ IDEA.
-- User: sdcuike
-- Date: 2015
-- Time: 下午4:09
--



local cjson = require('cjson.safe')


-- 日志功能组件 begin  ---

local modulename = "Util"
local _M = {}
_M._VERSION = '0.0.1'



_M.logInfo = function ( info )
    ngx.log(ngx.INFO, "[["..info.."]]")
end


_M.logError = function (error)
    ngx.log(ngx.ERR, "[["..error.."]]")
end


-- 日志功能组件 end  ---

local  function tableToString2(tableValue)
    if not tableValue then
        return ""
    end

    if type(tableValue) ~= "table" then
        return ""..tableValue
    end

    local info = ""
    for k, v in pairs(tableValue) do
        info = info.."[key:"..k.." value:"..tableToString2(v).."]"
    end

    return info
end



_M.tableToString = function(tableValue)
    if type(tableValue) ~= "table" then
        _M.logError("input is not a tabe type :"..tableValue)
        return nil
    end

    return tableToString2(tableValue);
end





return _M