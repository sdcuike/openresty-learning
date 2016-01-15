--
-- Created by IntelliJ IDEA.
-- User: sdcuike
-- Date: 2016-01-14
-- Time:  
--

--[[  后端服务健康状态检查 
      see https://github.com/openresty/lua-nginx-module#init_worker_by_lua
      https://github.com/openresty/lua-resty-upstream-healthcheck/blob/master/lib/resty/upstream/healthcheck.lua  
      http://www.willglynn.com/2013/12/03/health-checks-in-nginx/
      https://github.com/xiaomi-sa/ngx-lua-stats
      
        --]]


local delay = 30   -- in seconds  心跳功能时间间隔:30 ~ 180

local wrt = ngx.shared.server_current_weigtht_cache

local check

check = function(premature)
    if not premature then
        -- do the health check or other routine work
        local ok, err = ngx.timer.at(delay, check)
        if not ok then
            log(ERR, "failed to create timer: ", err)
            return
        end
    end
end


local ok, err = ngx.timer.at(delay, check)

if not ok then
    ngx.log(ERR, "failed to create timer: ", err)
    return
end