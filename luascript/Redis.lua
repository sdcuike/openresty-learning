--
-- Created by IntelliJ IDEA.
-- User: sdcuike
-- Date: 2015
-- Time: 下午4:09
--



--  redis api

local modulename = "Redis"
local _M = {}

_M._VERSION = '0.0.1'


local redis = require('resty.redis')


_M.new = function(self, conf)
    self.host       = conf.host
    self.port       = conf.port
    self.timeout    = conf.timeout
    self.poolsize   = conf.poolsize
    self.idletime   = conf.idletime
    self.passwd     = conf.passwd
    self.dbid       = conf.dbid

    local red = redis:new()

    return setmetatable({redis = red}, { __index = _M } )

end


_M.connectdb = function(self)
    local host  = self.host
    local port  = self.port
    local red   = self.redis

    if  not (host and port) then
        return nil, 'no  tcp avaliable provided'
    end

    if not dbid then
        dbid = 0
    end


    local timeout   = self.timeout 
    if not timeout then 
        timeout = 1000   -- 10s
    end
    red:set_timeout(timeout)

    local ok, err 


    if host and port then
        ok, err = red:connect(host, port)
        if ok then
            local auth, error = red:auth(self.passwd)
            if not auth then
                ngx.log(ngx.ERR, "[[".."failed to authenticate: "..error.."]]")
                return nil,error
            end

            return red:select(dbid)
        end
    end

    return ok, err

end

_M.keepalivedb = function(self)
    local   pool_max_idle_time  = self.idletime --毫秒
    local   pool_size           = self.poolsize --连接池大小

    if not pool_size then pool_size = 1000 end
    if not pool_max_idle_time then pool_max_idle_time = 90000 end
    
    return self.redis:set_keepalive(pool_max_idle_time, pool_size)  
end

_M.close = function(self)
    local ok, err = self.redis:close()
    if not ok then
        ngx.log(ngx.ERR, "[[".."failed to close:"..err.."]]")
    end
end

return _M
