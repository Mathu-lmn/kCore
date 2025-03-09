---@param charData table
local function LoadCharacterAppearance(charData)
    local ped = PlayerPedId()
    if charData and charData.Appearance then
        print("Loading Appearance data:", json.encode(charData.Appearance))

        local model = charData.Appearance.model
        if model then
            if type(model) == 'string' then
                model = GetHashKey(model)
            end

            if IsModelValid(model) then
                RequestModel(model)
                while not HasModelLoaded(model) do
                    Wait(0)
                end
                SetPlayerModel(PlayerId(), model)
                SetModelAsNoLongerNeeded(model)
                ped = PlayerPedId()
            else
                print("Invalid model:", model)
                return
            end
        end

        if charData.Appearance.model == "mp_m_freemode_01" or charData.Appearance.model == "mp_f_freemode_01" then
            if not charData.Appearance.genetics then

                charData.Appearance.genetics = {
                    mother = 21,
                    father = 0,
                    shapeMix = 0.5,
                    skinMix = 0.5
                }
            end
        end

        if DoesEntityExist(ped) then
            exports['kClothing']:ApplyAppearance(charData.Appearance, ped)
        end
    end
end

---@param data table player data
RegisterNetEvent('kCore:updateData', function(data)
    Core.Player = data
    print(json.encode(data) .. ' FUCKING DATA')
end)

---@param data table player data
---@param isNew boolean was the char just created?
RegisterNetEvent('kCore:loadPlayer', function(data, isNew)
    Core.Player = data

    if data.position then
        SetEntityCoords(PlayerPedId(), data.position.x, data.position.y, data.position.z, false, false, false, false)
        SetEntityHeading(PlayerPedId(), data.position.heading)
    end

    if isNew then
        exports["kClothing"]:ShowCharacterMenu(true, true)
    else
        LoadCharacterAppearance(data)
        exports["kHUD"]:initHUD()
    end

    Core.Player.IsLoaded = true
    DiscordStatus()
end)

---@param AppearanceData table
RegisterNetEvent('refreshAppearance', function(AppearanceData)
    if AppearanceData then
        local ped = PlayerPedId()
        if DoesEntityExist(ped) then
            exports['kClothing']:ApplyAppearance(AppearanceData, ped)
        end
    end
end)
