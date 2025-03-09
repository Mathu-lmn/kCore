local currentWeapon = nil

---@param weaponData table
RegisterNetEvent('kCore:equipWeapon', function(weaponData)
    local playerPed = PlayerPedId()
    local weaponHash = weaponData.weaponHash

    GiveWeaponToPed(playerPed, weaponHash, 0, false, true)
    SetCurrentPedWeapon(playerPed, weaponHash, true)

    if weaponData.metadata and weaponData.metadata.ammo then
        SetPedAmmo(playerPed, weaponHash, weaponData.metadata.ammo)
    end

    currentWeapon = weaponData
end)

---@param weaponHash string
RegisterNetEvent('kCore:saveWeaponMetadata', function(weaponHash)
    if currentWeapon and currentWeapon.slot then
        local currentAmmo = GetAmmoInPedWeapon(PlayerPedId(), weaponHash)

        local Player? = Core.Functions.GetPlayer()
        local currentItem

        for _, item in ipairs(Player.Inventory.items) do
            if item.position.x == currentWeapon.slot.x and item.position.y == currentWeapon.slot.y then
                currentItem = item
                break
            end
        end

        if currentItem then
            local metadata = currentItem.metadata or {}
            metadata.ammo = currentAmmo

            TriggerServerEvent('kCore:updateItemMetadata', currentWeapon.slot, metadata)
        end
    end
end)

---@param newAmmo integer
RegisterNetEvent('kCore:updateWeaponAmmo', function(newAmmo)
    if currentWeapon then
        SetPedAmmo(PlayerPedId(), currentWeapon.weaponHash, newAmmo)
        TriggerServerEvent('kCore:updateItemMetadata', currentWeapon.slot, {
            ammo = newAmmo
        })
    end
end)

---@param weaponHash string
RegisterNetEvent('kCore:removeWeapon', function(weaponHash)
    local playerPed = PlayerPedId()
    RemoveWeaponFromPed(playerPed, weaponHash)
    currentWeapon = nil
end)

---@param ammoData table
RegisterNetEvent('kCore:useAmmo', function(ammoData)
    local playerPed = PlayerPedId()

    if not currentWeapon then
        print('^1You need to have a weapon equipped to use ammo')
        return
    end

    if currentWeapon.ammoType ~= ammoData.name then
        print('^1Wrong ammo type')
        return
    end

    local currentAmmo = GetAmmoInPedWeapon(playerPed, currentWeapon.weaponHash)

    TriggerServerEvent('kCore:ammoUsed', ammoData, currentWeapon.slot, currentAmmo)
end)
