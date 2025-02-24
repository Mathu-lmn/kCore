local DisableControlAction = DisableControlAction



CreateThread(function()
    while true do
        DisableControlAction(0, 37, true)
    
        Wait(0)
    end
end)