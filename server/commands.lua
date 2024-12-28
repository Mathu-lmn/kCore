RegisterCommand('addmoney', function(source, args)
    local playerId = tonumber(args[1])
    local amount = tonumber(args[2])
    local type = args[3]
    if source == 0 then
        if not playerId or not amount or not type then
            print("^1Usage: addmoney [playerID] [amount] [cash/bank]^7")
            return
        end

        if Core.Functions.AddMoney(playerId, amount, type) then
            print("^2Successfully added $" .. amount .. " to player " .. playerId .. "'s " .. type .. "^7")
        else
            print("^1Failed to add money. Player might not exist or invalid type specified.^7")
        end
    else
        if not playerId or not amount or not type then
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 0, 0},
                args = {"SYSTEM", "Usage: /addmoney [playerID] [amount] [cash/bank]"}
            })
            return
        end

        if Core.Functions.AddMoney(playerId, amount, type) then
            TriggerClientEvent('chat:addMessage', source, {
                color = {0, 255, 0},
                args = {"SYSTEM", "Added $" .. amount .. " to player " .. playerId .. "'s " .. type}
            })
        else
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 0, 0},
                args = {"SYSTEM", "Failed to add money. Player might not exist or invalid type specified."}
            })
        end
    end
end, false)

RegisterCommand('removemoney', function(source, args)
    local playerId = tonumber(args[1])
    local amount = tonumber(args[2])
    local type = args[3]
    if source == 0 then
        if not playerId or not amount or not type then
            print("^1Usage: removemoney [playerID] [amount] [cash/bank]^7")
            return
        end

        if Core.Functions.RemoveMoney(playerId, amount, type) then
            print("^2Successfully removed $" .. amount .. " from player " .. playerId .. "'s " .. type .. "^7")
        else
            print(
                "^1Failed to remove money. Player might not exist, have insufficient funds, or invalid type specified.^7")
        end
    else
        if not playerId or not amount or not type then
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 0, 0},
                args = {"SYSTEM", "Usage: /removemoney [playerID] [amount] [cash/bank]"}
            })
            return
        end

        if Core.Functions.RemoveMoney(playerId, amount, type) then
            TriggerClientEvent('chat:addMessage', source, {
                color = {0, 255, 0},
                args = {"SYSTEM", "Removed $" .. amount .. " from player " .. playerId .. "'s " .. type}
            })
        else
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 0, 0},
                args = {"SYSTEM",
                        "Failed to remove money. Player might not exist, have insufficient funds, or invalid type specified."}
            })
        end
    end
end, false)

RegisterCommand('checkmoneystate', function(source)
    if source == 0 then
        return
    end
    local Player = Core.Functions.GetPlayer(source)
    if Player then
        print("^3[Money Debug] Player Money State^7")
        print("Source:", source)
        print("CitizenID:", Player.citizenid)
        print("Cash:", Player.Money.cash)
        print("Bank:", Player.Money.bank)
        print("Raw Money Object:", json.encode(Player.Money))
    else
        print("^1Error: No player found for source^7:", source)
    end
end)
