Callbacks = {}
CallbackRequests = {}

Core.Functions.RegisterServerCallback = function(name, cb)
    local resource = GetInvokingResource()
    if not resource then return end
    Callbacks[name] = cb
end

RegisterNetEvent('kCore:triggerCallback', function(name, requestId, ...)
    local source = source


    local callbackfn = Callbacks[name]
    if not callbackfn then
        DropPlayer(source, "Invalid callback")
        return
    end

    local currentTime = GetGameTimer()
    local playerRequests = 0
    for _, data in pairs(CallbackRequests) do
        if data.source == source and (currentTime - data.time) < 1000 then
            playerRequests = playerRequests + 1
            if playerRequests > 10 then 
                DropPlayer(source, "Callback spam detected")
                return
            end
        end
    end

    CallbackRequests[requestId] = {
        source = source,
        time = currentTime
    }
    
    callbackfn(source, function(...)
        if CallbackRequests[requestId] and CallbackRequests[requestId].source == source then
            TriggerClientEvent('kCore:callbackResponse', source, requestId, ...)
            CallbackRequests[requestId] = nil
            print(json.encode(CallbackRequests))
        end
    end, ...)

    print(json.encode(CallbackRequests))
end)

exports('RegisterServerCallback', Core.Functions.RegisterServerCallback)
