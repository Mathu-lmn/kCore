Callbacks = {}

Core.Functions.RegisterServerCallback = function(name, cb)
    Callbacks[name] = cb
end

RegisterNetEvent('kCore:triggerCallback')
AddEventHandler('kCore:triggerCallback', function(name, requestId, ...)
    local source = source
    local callbackfn = Callbacks[name]

    if callbackfn then
        callbackfn(source, function(...)
            TriggerClientEvent('kCore:callbackResponse', source, requestId, ...)
        end, ...)
    else
        print('^1[kCore] ^7Callback ' .. name .. ' does not exist')
    end
end)

exports('RegisterServerCallback', Core.Functions.RegisterServerCallback)
