CreateThread(function()
    while true do
        Wait(0)
        DisableControlAction(0, 37, true)
    end
end)


RegisterNetEvent('kCore:debugJob', function()
    print('yipee')
    Wait(1000)
    print(json.encode(Shared.Jobs))
end)