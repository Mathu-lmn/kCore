local function RegisterWeaponHandlers()
    for itemName, item in pairs(Shared.Items) do
        if item.type == 'weapon' then
            Core.Functions.CreateUseableItem(itemName, function(source, item, slot)
                local Player = Core.Functions.GetPlayer(source)
                if not Player then
                    return
                end

                local weaponItem
                for _, invItem in ipairs(Player.Inventory.items) do
                    if invItem.id == item.id then
                        weaponItem = invItem
                        break
                    end
                end

                if not weaponItem then
                    return
                end
                local currentWeapon = GetSelectedPedWeapon(GetPlayerPed(source))
                if currentWeapon ~= GetHashKey('WEAPON_UNARMED') then
                    TriggerClientEvent('kCore:saveWeaponMetadata', source, currentWeapon)
                end

                TriggerClientEvent('kCore:equipWeapon', source, {
                    name = item.name,
                    slot = slot,
                    weaponHash = GetHashKey(string.upper(item.name)),
                    ammoType = item.ammoType,
                    metadata = weaponItem.metadata or {
                        ammo = 0
                    }
                })
            end)
        end
    end
end

local function RegisterAmmoHandlers()
    for itemName, item in pairs(Shared.Items) do

        local isAmmoType = false
        for _, weaponItem in pairs(Shared.Items) do
            if weaponItem.type == 'weapon' and weaponItem.ammoType == itemName then
                isAmmoType = true
                break
            end
        end

        if isAmmoType then
            Core.Functions.CreateUseableItem(itemName, function(source, item, slot)
                local Player = Core.Functions.GetPlayer(source)
                if not Player then
                    return
                end

                TriggerClientEvent('kCore:useAmmo', source, {
                    name = item.name,
                    slot = slot
                })
            end)
        end
    end
end

---@param ammoData table
---@param weaponSlot table
---@param currentAmmo integer
RegisterNetEvent('kCore:ammoUsed', function(ammoData, weaponSlot, currentAmmo)
    local src = source

    if Core.Functions.RemoveItem(src, ammoData.name, 1, ammoData.slot) then
        local Player? = Core.Functions.GetPlayer(src)
        local currentItem

        for _, item in ipairs(Player.Inventory.items) do
            if item.position.x == weaponSlot.x and item.position.y == weaponSlot.y then
                currentItem = item
                break
            end
        end

        if currentItem then
            local metadata = currentItem.metadata or {} -- i want to have a "dynamic" metadata system so this is what we do. get>update>set
            metadata.ammo = currentAmmo + 30

            Core.Functions.UpdateItemMetadata(src, weaponSlot, metadata)
            TriggerClientEvent('kCore:updateWeaponAmmo', src, currentAmmo + 30)
        end
    end
end)

---@param newAmmo integer
RegisterNetEvent('kCore:updateWeaponAmmo', function(newAmmo)
    if currentWeapon then
        SetPedAmmo(PlayerPedId(), currentWeapon.weaponHash, newAmmo)
    end
end)

RegisterAmmoHandlers()
RegisterWeaponHandlers()
