Core.UsableItems = {}
GroundInventories = {} -- keep within core, pr if needed

function Core.Functions.CreateUseableItem(itemName, cb)
    Core.UsableItems[itemName] = cb
end

function Core.Functions.AddItem(source, itemName, amount, metadata)
    local Player = Core.Functions.GetPlayer(source)
    if not Player then return false end

    local itemData = Core.Shared.Items[itemName]
    if not itemData then return false end

    if not Player.Inventory then
        Player.Inventory = {
            maxWeight = 100,
            rows = 10,
            columns = 10,
            items = {}
        }
    end

    amount = tonumber(amount) or 1
    local inventory = Player.Inventory
    local positionMap = {}

    for _, existingItem in ipairs(inventory.items) do
        local itemSize = Core.Shared.Items[existingItem.name].size
        print(json.encode(itemSize))
        local size = existingItem.rotation == 90 and 
            { width = itemSize.height, height = itemSize.width } or 
            itemSize
        
        for y = existingItem.position.y, existingItem.position.y + size.height - 1 do
            for x = existingItem.position.x, existingItem.position.x + size.width - 1 do
                positionMap[y * inventory.columns + x] = true
            end
        end
    end

    if not itemData.unique then
        for _, existingItem in ipairs(inventory.items) do
            if existingItem.name == itemName and existingItem.count < (itemData.maxStack or 64) then
                local spaceInStack = (itemData.maxStack or 64) - existingItem.count
                local amountToAdd = math.min(amount, spaceInStack)
                existingItem.count = existingItem.count + amountToAdd
                amount = amount - amountToAdd
                
                if amount <= 0 then
                    Player.Functions.UpdateInventory(inventory)
                    return true
                end
            end
        end
    end

    while amount > 0 do
        local newItem = {
            id = itemName..Core.Functions.GenerateUID(),
            name = itemName,
            position = nil, 
            rotation = 0,
            count = itemData.unique and 1 or math.min(amount, (itemData.maxStack or 64)),
            metadata = metadata or {}
        }

        local found = false
        for _, rotation in ipairs({0, 90}) do
            newItem.rotation = rotation
            local size = rotation == 90 and 
                { width = itemData.size.height, height = itemData.size.width } or 
                itemData.size
            
            for y = 0, inventory.rows - size.height do
                for x = 0, inventory.columns - size.width do
                    local positionValid = true
                    for checkY = y, y + size.height - 1 do
                        for checkX = x, x + size.width - 1 do
                            if positionMap[checkY * inventory.columns + checkX] then
                                positionValid = false
                                break
                            end
                        end
                        if not positionValid then break end
                    end
                    
                    if positionValid then
                        newItem.position = { x = x, y = y }
                        found = true
                        break
                    end
                end
                if found then break end
            end
            if found then break end
        end
        
        if not found then return false end
        
        table.insert(inventory.items, newItem)
        amount = amount - newItem.count
    end

    Player.Functions.UpdateInventory(inventory)
    return true
end

exports('AddItem', Core.Functions.AddItem(source, itemName, amount, metadata))

function Core.Functions.RemoveItem(source, itemName, amount, slot)
    local Player = Core.Functions.GetPlayer(source)
    if not Player then return false end

    amount = tonumber(amount) or 1
    local inventory = Player.Inventory
    local found = false

    if slot then
        for i, item in ipairs(inventory.items) do
            if item.name == itemName and item.position.x == slot.x and item.position.y == slot.y then
                if item.count and item.count > amount then
                    item.count = item.count - amount
                    found = true
                    break
                elseif item.count and item.count == amount then
                    table.remove(inventory.items, i)
                    found = true
                    break
                end
            end
        end
    else
        print("^1No slot provided^7")
    end

    if found then
        Player.Functions.UpdateInventory(inventory)
        TriggerClientEvent('inventory:client:ItemBox', source, Shared.Items[itemName], "remove")
        return true
    end
    return false
end


function Core.Functions.UpdateItemMetadata(source, slot, metadata)
    local Player = Core.Functions.GetPlayer(source)
    if not Player then return false end

    for _, item in ipairs(Player.Inventory.items) do
        if item.position.x == slot.x and item.position.y == slot.y then
            item.metadata = metadata
            Player.Functions.UpdateInventory(Player.Inventory)
            return true
        end
    end
    return false
end


function Core.Functions.CreateGroundInventory(src,id)
    if not id then return nil end
    
    if not GroundInventories[id] then
        GroundInventories[id] = {
            id = id,
            name = 'Ground',
            maxWeight = 1000,
            rows = 4,
            columns = 5,
            items = {},
            viewers = {
                [src] = true
            }
        }
    end
    
    return GroundInventories[id]
end

function Core.Functions.GetInventoryById(id)
    return id and GroundInventories[id] or Core.Functions.CreateGroundInventory(id)
end

function Core.Functions.MoveInventoryItem(src, item, sourceId, targetId)
    local Player = Core.Functions.GetPlayer(src)
    if not Player then return false end
    

    local sourceInv = sourceId == 'player' and Player.Inventory or Core.Functions.GetInventoryById(sourceId)
    local targetInv = targetId == 'player' and Player.Inventory or Core.Functions.GetInventoryById(targetId)


    print('^2'..targetId, json.encode(targetInv), 'targetInv')
    if not sourceInv or not targetInv then 
        print("^1Error: Invalid inventory objects^7")
        return false, nil 
    end

    local sourceItemIndex
    local sourceItem
    for i, existingItem in ipairs(sourceInv.items) do
        if existingItem and existingItem.id == item.id then
            sourceItemIndex = i
            sourceItem = existingItem
            break
        end
    end

    if not sourceItemIndex then 
        print("^1Error: Source item not found^7")
        return false, nil 
    end

    local targetItem
    local targetItemIndex
    for i, existingItem in ipairs(targetInv.items) do
        if existingItem and 
           existingItem.position.x == item.position.x and 
           existingItem.position.y == item.position.y and
           existingItem.name == sourceItem.name and  
           not existingItem.isUnique and
           existingItem.id ~= item.id and  
           ((existingItem.count or 1) + (sourceItem.count or 1)) <= (existingItem.maxStack or 64) then
            targetItem = existingItem
            targetItemIndex = i
            break
        end
    end

    print("^3Source Item:^7", json.encode(sourceItem))
    if targetItem then
        print("^3Target Item for Stacking:^7", json.encode(targetItem))
    end

    if targetItem then
        print("^2Stacking items^7")
        targetItem.count = (targetItem.count or 1) + (sourceItem.count or 1)
        table.remove(sourceInv.items, sourceItemIndex)
        print("^2New stack count:^7", targetItem.count)
    else
        print("^2Moving item to new position^7")
        local movedItem = table.remove(sourceInv.items, sourceItemIndex)
        if movedItem then
            movedItem.position = item.position
            movedItem.rotation = item.rotation or 0
            movedItem.inventoryId = targetId
            movedItem.metadata = sourceItem.metadata
            table.insert(targetInv.items, movedItem)
        end
    end

    if sourceId == 'player' or targetId == 'player' then
        Player.Functions.UpdateInventory(Player.Inventory)
    end

    -- update viewers
    if sourceId:match('^ground_') then 
        GroundInventories[sourceId] = sourceInv 
        for viewerId in pairs(sourceInv.viewers) do
            if viewerId ~= src then
                TriggerClientEvent('kCore:refreshInventory', viewerId, {
                    id = sourceId,
                    name = sourceInv.name,
                    rows = sourceInv.rows,
                    columns = sourceInv.columns,
                    items = sourceInv.items
                })
            end
        end
    end

    if targetId:match('^ground_') then 
        GroundInventories[targetId] = targetInv 

        for viewerId in pairs(targetInv.viewers) do
            if viewerId ~= src then
                TriggerClientEvent('kCore:refreshInventory', viewerId, {
                    id = targetId,
                    name = targetInv.name,
                    rows = targetInv.rows,
                    columns = targetInv.columns,
                    items = targetInv.items
                })
            end
        end
    end


    local responseData = {
        {
            id = 'player',
            name = 'Player Inventory',
            rows = Player.Inventory.rows,
            columns = Player.Inventory.columns,
            items = Player.Inventory.items
        }
        }

    if sourceId ~= 'player' then
        local otherInv = Core.Functions.GetInventoryById(sourceId)
        if otherInv then
            table.insert(responseData, {
                id = otherInv.id,
                name = otherInv.name,
                rows = otherInv.rows,
                columns = otherInv.columns,
                items = otherInv.items
            })
        end
    end

    if targetId ~= 'player' and targetId ~= sourceId then
        local otherInv = Core.Functions.GetInventoryById(targetId)
        if otherInv then
            table.insert(responseData, {
                id = otherInv.id,
                name = otherInv.name,
                rows = otherInv.rows,
                columns = otherInv.columns,
                items = otherInv.items
            })
        end
    end

    return true, responseData
end

function Core.Functions.SplitInventoryItem(source, item, splitAmount)
    local Player = Core.Functions.GetPlayer(source)
    if not Player or not item then return false end

    --checkinv
    local inventory = item.inventoryId == 'player' and Player.Inventory or Core.Functions.GetInventoryById(item.inventoryId)
    if not inventory then return false end

    local originalItem
    local originalIndex
    for i, existingItem in ipairs(inventory.items) do
        if existingItem.id == item.id then
            originalItem = existingItem
            originalIndex = i
            break
        end
    end
    
    if not originalItem then return false end

    if not originalItem.count or originalItem.count <= 1 or originalItem.isUnique then
        print("^1Item cannot be split (unique or count <= 1)^7")
        return false
    end


    --splitting
    splitAmount = tonumber(splitAmount)
    if not splitAmount or splitAmount <= 0 then
        print("^1Invalid split amount^7")
        return false
    end

    if splitAmount >= originalItem.count then
        print("^1Split amount too large^7")
        return false
    end

    local positionMap = {}
    for _, existingItem in ipairs(inventory.items) do
        local size = existingItem.rotation == 90 
            and { width = Core.Shared.Items[existingItem.name].size.height, height = Core.Shared.Items[existingItem.name].size.width }
            or Core.Shared.Items[existingItem.name].size
            
        for y = existingItem.position.y, existingItem.position.y + size.height - 1 do
            for x = existingItem.position.x, existingItem.position.x + size.width - 1 do
                positionMap[y * inventory.columns + x] = true
            end
        end
    end
    
    local newItem = {
        id = item.id..Core.Functions.GenerateUID(),
        name = item.name,
        position = nil,
        rotation = 0,
        count = splitAmount,
        inventoryId = item.inventoryId,
    }
    
    local found = false
    for _, rotation in ipairs({0, 90}) do
        newItem.rotation = rotation
        local size = rotation == 90 
            and { width = Core.Shared.Items[item.name].size.height, height = Core.Shared.Items[item.name].size.width }
            or Core.Shared.Items[item.name].size
        
        for y = 0, inventory.rows - size.height do
            for x = 0, inventory.columns - size.width do
                local positionValid = true
                for checkY = y, y + size.height - 1 do
                    for checkX = x, x + size.width - 1 do
                        if positionMap[checkY * inventory.columns + checkX] then
                            positionValid = false
                            break
                        end
                    end
                    if not positionValid then break end
                end
                
                if positionValid then
                    newItem.position = { x = x, y = y }
                    found = true
                    break
                end
            end
            if found then break end
        end
        if found then break end
    end
    
    if not found then return false end
    
    originalItem.count = originalItem.count - splitAmount
    
    table.insert(inventory.items, newItem)
    
    if item.inventoryId == 'player' then
        Player.Functions.UpdateInventory(inventory)
    else
        GroundInventories[item.inventoryId] = inventory
        for viewerId in pairs(inventory.viewers) do
            TriggerClientEvent('kCore:refreshInventory', viewerId, {
                id = item.inventoryId,
                name = inventory.name,
                rows = inventory.rows,
                columns = inventory.columns,
                items = inventory.items
            })
        end
    end
    
    return true
end

RegisterServerEvent('kCore:useItem')
AddEventHandler('kCore:useItem', function(item, slot)
    local src = source
    local Player = Core.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local itemData = Shared.Items[item.name]
    if not itemData then
        print("^1Item does not exist^7")
        return
    end

    if not Core.UsableItems[item.name] then
        print("^1Item is not usable^7")
        return
    end
    local hasItem = false
    for _, invItem in ipairs(Player.Inventory.items) do
        if invItem.id == item.id and 
           invItem.position.x == slot.x and 
           invItem.position.y == slot.y then
            hasItem = true
            break
        end
    end

    if not hasItem then
        print("^1Player does not have this item in specified slot^7")
        return
    end

    Core.UsableItems[item.name](src, item, slot)
end)



RegisterServerEvent('kCore:updateItemMetadata')
AddEventHandler('kCore:updateItemMetadata', function(slot, metadata)
    Core.Functions.UpdateItemMetadata(source, slot, metadata)
end)


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
    if not Player then return end

    if not groundId:match('^ground_') then
        groundId = 'ground_' .. groundId
    end

    local groundInv = Core.Functions.GetInventoryById(groundId)
    groundInv.viewers[src] = true
    

    local inventoryData = {
        {
            id = 'player',
            name = 'Player Inventory',
            rows = Player.Inventory.rows,
            columns = Player.Inventory.columns,
            items = Player.Inventory.items or {}
        },
        {
            id = groundInv.id,
            name = groundInv.name,
            rows = groundInv.rows,
            columns = groundInv.columns,
            items = groundInv.items or {}
        }
    }

    TriggerClientEvent('kCore:openInventory', src, inventoryData)
end)

AddEventHandler('playerDropped', function()
    local src = source
    for _, inv in pairs(GroundInventories) do
        inv.viewers[src] = nil
    end
end)


Core.Functions.CreateUseableItem("water", function(source, item, slot)
    if Core.Functions.RemoveItem(source, item.name, 1, slot) then
        TriggerClientEvent('kCore:drink', source, item)
    end
end)
