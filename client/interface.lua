local activeProgress = nil
local activeCallback = nil

RegisterNUICallback('progressComplete', function(data, cb)
    if not activeProgress then 
        cb({ status = 'error', message = 'No active progress' })
        return 
    end
    
    local callback = activeCallback
    activeProgress = nil
    activeCallback = nil
    
    if callback then
        callback(data.success)
    end
    
    cb({ status = 'ok' })
end)

local function StartProgress(options, cb)
    if activeProgress then
        SendNUIMessage({ action = "cancelProgress" })
        Wait(100)
    end
    
    activeProgress = true
    activeCallback = cb
    
    SendNUIMessage({
        action = "startProgress",
        data = {
            duration = options.duration,
            label = options.label,
            color = options.color or "green" 
        }
    })
end

local function CancelProgress()
    if not activeProgress then return false end
    
    SendNUIMessage({ action = "cancelProgress" })
    
    activeProgress = nil
    activeCallback = nil
    
    return true
end

exports('StartProgress', StartProgress)
exports('CancelProgress', CancelProgress)

RegisterCommand('testprogress', function()
    StartProgress({
        duration = 3000,
        label = "TESTING...",
        color = "#ff0000"
    }, function(success)
        print("Progress completed:", success)
    end)
end)

RegisterCommand('cancelprogress', CancelProgress)