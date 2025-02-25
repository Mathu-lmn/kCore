function Core.Functions.GetPlayer()
    return Core.Player
end

function Core.Functions.GetPlayerMoney()
    return Core.Player.Money
end

function Core.Functions.GetPlayerStats()
    return Core.Player.Stats
end

function Core.Functions.IsPlayerLoaded()
    return Core.Player.IsLoaded
end

function DiscordStatus()
    local presence = {
        state = "Visit kco.re for more info",
        details = ("%s / %s | Playing as %s %s"):format(
            tostring(GlobalState.numberPlayer),
            tostring(GlobalState.maxClients),
            Core.Player.Name.first_name,
            Core.Player.Name.last_name
        ),
        largeImageKey = "kcoreme",
        largeImageText = "KCore - Visit kco.re for more info.", 
    }
    SetDiscordAppId('1322859534003208192')
    SetDiscordRichPresenceAsset(presence.largeImageKey)
    SetDiscordRichPresenceAssetText(presence.largeImageText)
    SetRichPresence(presence.details)
end

AddStateBagChangeHandler('numberPlayer', 'global', function(bagName, key, value, reserved, replicated)
    DiscordStatus()
end)

AddStateBagChangeHandler('maxClients', 'global', function(bagName, key, value, reserved, replicated)
    DiscordStatus()
end)
