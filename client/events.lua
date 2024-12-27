

RegisterNetEvent('kCore:updateNeeds')
AddEventHandler('kCore:updateNeeds', function(newHunger, newThirst)
    Core.Player.Stats.hunger = newHunger
    Core.Player.Stats.thirst = newThirst
    exports['kNotify']:Notify({
        type = "information",
        title = "Needs",
        message = json.encode(Core.Player.Stats),
        duration = 3000,
        position = "top",
        playSound = false
    })
end)

RegisterNetEvent('kCore:updateMoney')
AddEventHandler('kCore:updateMoney', function(moneyData)
    Core.Player.Money = moneyData
    exports["kNotify"]:Notify({type = "cash", title = "Money Updated. (Core Debug)", message = json.encode(moneyData), duration = 5000, position = "top-right", playSound = true})
end)

RegisterNetEvent('kCore:drink')
AddEventHandler('kCore:drink', function(item)
    exports['kCore']:StartProgress({
        duration = 3000,
        label = "Drinking " .. string.upper(item.name),
        color = "blue"
    }, function(success)
        TriggerServerEvent('kCore:updateStats', item)
    end)
end)

RegisterNetEvent('kCore:notification')
AddEventHandler('kCore:notification', function(message)
    exports['kNotify']:Notify({
        type = "information",
        title = "kCore",
        message = message,
        duration = 3000,
        position = "top",
        playSound = true
    })
end)

