CallbackResponses = {}
local requestId = 0

Core.Functions.TriggerServerCallback = function(name, cb, ...)
    requestId = requestId + 1
    CallbackResponses[requestId] = cb
    TriggerServerEvent('kCore:triggerCallback', name, requestId, ...)
end


---@param id integer
---@param ... any
RegisterNetEvent('kCore:callbackResponse', function(id, ...)
    if source ~= 65535 then return end -- if not server
    local cb = CallbackResponses[id]
    if cb then
        cb(...)
        CallbackResponses[id] = nil
    end
end)

exports('TriggerServerCallback', Core.Functions.TriggerServerCallback)
