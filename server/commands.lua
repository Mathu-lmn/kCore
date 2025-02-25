-- commands don't have permissions checks this early on

RegisterCommand('addmoney', function(source, args)
    if source ~= 0 and not Core.Functions.HasPermission(source, "command.money") then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            args = {"SYSTEM", "Insufficient permissions."}
        })
        return
    end

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
    if source ~= 0 and not Core.Functions.HasPermission(source, "command.money") then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            args = {"SYSTEM", "Insufficient permissions."}
        })
        return
    end

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
    if source ~= 0 and not Core.Functions.HasPermission(source, "command.money") then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            args = {"SYSTEM", "Insufficient permissions."}
        })
        return
    end

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

RegisterCommand('createPolice', function(source, args)
    if source ~= 0 and not Core.Functions.HasPermission(source, "command.jobs") then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            args = {"SYSTEM", "Insufficient permissions."}
        })
        return
    end

    Core.Functions.CreateJob("police", "LSPD", {
        grades = {{
            name = 'Cadet',
            salary = 1000,
            rank = 1
        }, {
            name = 'Officer',
            salary = 1500,
            rank = 2
        }, {
            name = 'Sergeant',
            salary = 2000,
            rank = 3
        }}
    }, true) 

    TriggerClientEvent('kCore:debugJob', source)
end)

RegisterCommand('createFire', function(source, args)
    if source ~= 0 and not Core.Functions.HasPermission(source, "command.jobs") then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            args = {"SYSTEM", "Insufficient permissions."}
        })
        return
    end

    Core.Functions.CreateJob("fire", "LSFD", {
        grades = { [0] = {
            name = 'Paramedic',
            salary = 1000,
            rank = 0
        }, [1] = {
            name = 'Firefighter',
            salary = 1500,
            rank = 1
        }, [2] = {
            name = 'Chief',
            salary = 2000,
            rank = 2
        }}
    }, true) 

    TriggerClientEvent('kCore:debugJob', source)
end)

RegisterCommand('setjob', function(source, args)
    if source ~= 0 and not Core.Functions.HasPermission(source, "command.jobs") then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            args = {"SYSTEM", "Insufficient permissions."}
        })
        return
    end

    local playerId = tonumber(args[1])
    local job = args[2]
    local grade = tonumber(args[3])

    if source == 0 then 
        if not playerId or not job or not grade then
            print("^1Usage: setjob [playerID] [job] [grade]^7")
            return
        end

        if Core.Functions.SetPlayerJob(playerId, job, grade) then
            print("^2Successfully changed job of player " .. playerId .. " to " .. job .. " grade " .. grade .. "^7")
        else
            print("^1Failed to change job. Player might not exist or invalid job/grade specified.^7")
        end
    else 
        if not playerId or not job or not grade then
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 0, 0},
                args = {"SYSTEM", "Usage: /setjob [playerID] [job] [grade]"}
            })
            return
        end

        if Core.Functions.SetPlayerJob(playerId, job, grade) then
            TriggerClientEvent('chat:addMessage', source, {
                color = {0, 255, 0},
                args = {"SYSTEM",
                        "Successfully changed job of player " .. playerId .. " to " .. job .. " grade " .. grade}
            })
        else
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 0, 0},
                args = {"SYSTEM", "Failed to change job. Player might not exist or invalid job/grade specified."}
            })
        end
    end
end, false)

RegisterCommand('ground', function(source, args)
    local src = source
    local groundId = args[1]
    if not groundId then
        TriggerClientEvent('chat:addMessage', src, {
            color = {255, 0, 0},
            args = {'SYSTEM', 'Usage: /ground [id]'}
        })
        return
    end

    local Player = Core.Functions.GetPlayer(src)
    if not Player then
        return
    end

    if not groundId:match('^ground_') then
        groundId = 'ground_' .. groundId
    end

    local groundInv = Core.Functions.GetInventoryById(groundId)
    groundInv.viewers[src] = true

    local inventoryData = {{
        id = 'player',
        name = 'Player Inventory',
        rows = Player.Inventory.rows,
        columns = Player.Inventory.columns,
        items = Player.Inventory.items or {}
    }, {
        id = groundInv.id,
        name = groundInv.name,
        rows = groundInv.rows,
        columns = groundInv.columns,
        items = groundInv.items or {}
    }}

    TriggerClientEvent('kCore:openInventory', src, inventoryData)
end)
