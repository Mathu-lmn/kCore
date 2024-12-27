local HUNGER_DECAY_RATE = 1 
local THIRST_DECAY_RATE = 2 
local NEEDS_UPDATE_INTERVAL = 60000 
local CRITICAL_THRESHOLD = 90 
local DAMAGE_INTERVAL = 1000 
local DAMAGE_AMOUNT = 2

function Core.Stats.UpdateNeeds(source)
    local Player = Core.Functions.GetPlayer(source)
    if not Player or not Player.Stats then 
        print('No player data or stats found')
        return 
    end
    
    Player.Stats.hunger = math.max(0, Player.Stats.hunger - HUNGER_DECAY_RATE)
    Player.Stats.thirst = math.max(0, Player.Stats.thirst - THIRST_DECAY_RATE)
    
    TriggerClientEvent('kCore:updateNeeds', source, Player.Stats.hunger, Player.Stats.thirst)
    Player.Functions.Save()
end


function Core.Stats.UpdateStat(source, statName, amount)
    local Player = Core.Functions.GetPlayer(source) -- should be rewritten to use player 
    if not Player or not Player.Stats then 
        return false
    end
    
    if Player.Stats[statName] ~= nil then
        Player.Stats[statName] = math.min(100, math.max(0, Player.Stats[statName] + amount))
        
        if statName == "hunger" or statName == "thirst" then
            TriggerClientEvent('kCore:updateNeeds', source, Player.Stats.hunger, Player.Stats.thirst)
            Player.Functions.Save()
        end
        return true
    end

    return false
end

CreateThread(function()
    while true do
        Wait(NEEDS_UPDATE_INTERVAL)
        for source, _ in pairs(Core.Players) do
            Core.Stats.UpdateNeeds(source)
        end
    end
end)

function Core.Stats.AreNeedsInitialized(source)
    local Player = Core.Functions.GetPlayer(source)
    return Player 
        and Player.Stats 
        and Player.Stats.hunger ~= nil 
        and Player.Stats.thirst ~= nil
end



RegisterServerEvent('kCore:updateStats')
AddEventHandler('kCore:updateStats', function(item)
    local Player = Core.Functions.GetPlayer(source) 
    if not Player or not Player.Stats then 
        return false
    end

    Core.Stats.UpdateStat(source, "thirst", Player.Stats.thirst + 10)
end)