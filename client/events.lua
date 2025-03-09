---@param newHunger number
---@param newThirst number
RegisterNetEvent('kCore:updateNeeds', function(newHunger, newThirst)
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

---@param moneyData {cash: number, bank: number} https://kco.re/docs/kCore/PlayerObject#money for reference/format
RegisterNetEvent('kCore:updateMoney', function(moneyData)
    Core.Player.Money = moneyData
    exports["kNotify"]:Notify({
        type = "cash",
        title = "Money Updated. (Core Debug)",
        message = json.encode(moneyData),
        duration = 5000,
        position = "top-right",
        playSound = true
    })
end)

---@param item table item data
RegisterNetEvent('kCore:drink', function(item)
    exports['kCore']:StartProgress({
        duration = 3000,
        label = "Drinking " .. string.upper(item.name),
        color = "blue"
    }, function(success)
        TriggerServerEvent('kCore:updateStats', item)
    end)
end)

---@param message string message to show in the notification
RegisterNetEvent('kCore:notification', function(message)
    exports['kNotify']:Notify({
        type = "information",
        title = "kCore",
        message = message,
        duration = 3000,
        position = "top",
        playSound = true
    })
end)

---@param jobs table
RegisterNetEvent('kCore:syncJobs', function(jobs)
    Shared.Jobs = jobs
end)
