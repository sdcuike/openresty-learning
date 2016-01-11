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


local server_current_weigth

_M.get = function(server_effecitve_weight)
    local total = 0
    local max_weight = 0
    local max_weight_server_index = "a"

    --TODO:redis路由信息更新更新server_current_weigth
    if not server_current_weigth then
        server_current_weigth = {}
        print("init server_current_weigth")
        for k, v in pairs(server_effecitve_weight) do
            server_current_weigth[k] = 0
        end
    end


    for k, v in pairs(server_current_weigth) do
        server_current_weigth[k] = server_current_weigth[k] + server_effecitve_weight[k]
        total = total + server_effecitve_weight[k]

        if server_current_weigth[k] > max_weight then
            max_weight = server_current_weigth[k]
            max_weight_server_index = k
        end
    end


    --
    for k, v in pairs(server_current_weigth) do
        print("befor:" .. k .. server_current_weigth[k])
    end
    --
    print(total)


    server_current_weigth[max_weight_server_index] = server_current_weigth[max_weight_server_index] - total


    --
    for k, v in pairs(server_current_weigth) do
        print("after:" .. k .. server_current_weigth[k])
    end
    --
    return max_weight_server_index

end


return _M