local isDead = false
local deathTime = 5 -- seconds before respawn is available
local holdStartTime = 0


-- this whole system should probably be changed, we will need a death anim and stuff instead of funky ah ragdolls so if someone would like to do that, go for it <3
---@param event string name of the game Event
---@param data table data from the game event
AddEventHandler('gameEventTriggered', function(event, data)
    if event == 'CEventNetworkEntityDamage' then
        local victim, attacker, victimDied, weapon = data[1], data[2], data[4], data[7]
        if not IsEntityAPed(victim) then return end
        if victimDied and NetworkGetPlayerIndexFromPed(victim) == PlayerId() and IsEntityDead(PlayerPedId()) then
            if not isDead then
                IsDead(true)
            end
        end
    end
end)


---@param state boolean is player dead or alive
function IsDead(state)
    isDead = state

    if state then
        local timer = deathTime
        exports['kHUD']:UpdateDeathState(isDead, timer)

        CreateThread(function()
            while isDead and timer > 0 do
                Wait(1000)
                timer = timer - 1
                exports['kHUD']:UpdateDeathState(isDead, timer)
            end
            if isDead then
                exports['kHUD']:UpdateCanRespawn(true)
            end
        end)

        CreateThread(function()
            while isDead do
                Wait(0)
                if IsControlJustPressed(0, 38) and timer <= 0 then
                    ReviveUser()
                    break
                end
            end
        end)
    else
        exports['kHUD']:UpdateDeathState(isDead, 0)
        exports['kHUD']:UpdateCanRespawn(false)
        exports['kHUD']:UpdateRespawnProgress(0)
    end
end


-- function ReviveUser()
--     local playerPed = PlayerPedId()
--     local pos = GetEntityCoords(playerPed, true)

--     exports['kHUD']:UpdateRespawnProgress(0)
--     exports['kHUD']:UpdateCanRespawn(false)

--     NetworkResurrectLocalPlayer(pos.x, pos.y, pos.z, GetEntityHeading(playerPed), true, false)
--     SetEntityHealth(playerPed, 200) -- Fixed: was using 'player' instead of 'playerPed'
--     ClearPedBloodDamage(playerPed) -- Fixed: was using 'player' instead of 'playerPed'

--     isDead = false
--     holdStartTime = 0
--     exports['kHUD']:UpdateDeathState(isDead, 0)
-- end

-- exports('ReviveUser', ReviveUser)

-- RegisterCommand('revive', function()
--     ReviveUser()
-- end, false)
