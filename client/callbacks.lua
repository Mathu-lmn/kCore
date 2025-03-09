CallbackResponses = {}
local requestId = 0

---@param name string The name of the event that is triggered
---@param cb fun(...: any) The callback function that is executed after the event responded
---@param ... any any additional params for the event
Core.Functions.TriggerServerCallback = function(name, cb, ...)
    requestId = requestId + 1
    CallbackResponses[requestId] = cb
    TriggerServerEvent('kCore:triggerCallback', name, requestId, ...)
end


---@param id integer requestid to identify callback
---@param ... any any additional params from the event
RegisterNetEvent('kCore:callbackResponse', function(id, ...)
    if source ~= 65535 then return end -- if not server
    local cb = CallbackResponses[id]
    if cb then
        cb(...)
        CallbackResponses[id] = nil
    end
end)

exports('TriggerServerCallback', Core.Functions.TriggerServerCallback)
