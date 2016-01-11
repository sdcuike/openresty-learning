--
-- Created by IntelliJ IDEA.
-- User: sdcuike
-- Date: 2016-1-8
-- Nginx的负载均衡 - 加权轮询 (Weighted Round Robin)  

local modulename = "WeightedRoundRobin"
local _M = {}
_M._VERSION = '0.0.1'

--[[
local server_effecitve_weight = {}
server_effecitve_weight.a = 4
server_effecitve_weight.b = 2
server_effecitve_weight.c = 1

--]]

--[[local server_current_weigth = {}
server_current_weigth.a = 0
server_current_weigth.b = 0
server_current_weigth.c = 0
--]]


_M.get = function(server_current_weigth,server_effecitve_weight)
    local total = 0
    local max_weight = 0
    local max_weight_server_index = "a"

    for k, v in pairs(server_current_weigth) do
        server_current_weigth[k] = server_current_weigth[k] + server_effecitve_weight[k]
        total = total + server_effecitve_weight[k]

        if server_current_weigth[k] > max_weight then
            max_weight = server_current_weigth[k]
            max_weight_server_index = k
        end
    end
    
    server_current_weigth[max_weight_server_index] = server_current_weigth[max_weight_server_index] - total
    
    return max_weight_server_index

end


return _M