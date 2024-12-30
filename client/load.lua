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

RegisterNetEvent('kCore:loadPlayer')
AddEventHandler('kCore:loadPlayer', function(data, isNew)
    Core.Player = data

    print(Core.Player.Appearance.model, 'MODEL DATA')

    print(json.encode(data.position) .. ' FUCKING POSITION')

    if data.position then
        SetEntityCoords(PlayerPedId(), data.position.x, data.position.y, data.position.z, false, false, false, false)
        SetEntityHeading(PlayerPedId(), data.position.heading)
    end

    if isNew then
        exports["kClothing"]:ShowCharacterMenu(true, true)
    else
        LoadCharacterAppearance(data)
    end

    Core.Player.IsLoaded = true
    DiscordStatus()
end)

RegisterNetEvent('refreshAppearance')
AddEventHandler('refreshAppearance', function(AppearanceData)
    if AppearanceData then
        local ped = PlayerPedId()
        if DoesEntityExist(ped) then
            exports['kClothing']:ApplyAppearance(AppearanceData, ped)
            print("Appearance refreshed successfully")
        end
    end
end)

