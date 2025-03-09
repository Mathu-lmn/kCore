Config = require("config.server") -- global it for now

Core = {
    Functions = {},
    Players = {},
    Stats = {},
    Shared = Shared
}

---@return table Core entire fucking core
exports('GetCore', function()
    return Core
end) -- kekw

-- WE CAN DO  Core = exports["kCore"]:GetCore() but it's not recommended, use the exports for functions when possible.
-- exports["kCore"]:GetPlayer(source) is better than Core.Functions.GetPlayer(source) when in external resources (while in same resource we can use Core. stuff.)

---@param identifier string
---@param cb fun(data: table)
function Core.Functions.GetCharacterSlots(identifier, cb)
    MySQL.Async.fetchAll(
        'SELECT id, char_slot, citizenid, first_name, last_name, money, job, position, stats, appearance FROM characters WHERE identifier = @identifier',
        {
            ['@identifier'] = identifier
        }, function(results)
            local slots = {}

            for _, char in ipairs(results) do
                slots[char.char_slot] = {
                    id = char.id,
                    citizenid = char.citizenid,
                    slot = char.char_slot,
                    Name = {
                        first_name = char.first_name,
                        last_name = char.last_name
                    },
                    Stats = json.decode(char.stats),
                    Appearance = json.decode(char.appearance),
                    Money = json.decode(char.money),
                    Job = json.decode(char.job),
                    position = json.decode(char.position)
                }
            end

            cb({
                characters = slots,
                maxSlots = Config.MaxCharacterSlots,
                autoload = Config.AutoloadChar
            })
        end
    )
end
exports('GetCharacterSlots', Core.Functions.GetCharacterSlots)

---@param identifier string
---@param slot integer
---@param data table
---@param source integer
---@param cb fun(success: boolean, citizenid: string?)
function Core.Functions.CreateCharacter(identifier, slot, data, source, cb)
    local citizenid = Core.Functions.GenerateUID()
    local defaultAppearance = {
        model = data.sex == 'male' and "mp_m_freemode_01" or "mp_f_freemode_01",
        clothing = {},
        genetics = {
            mother = 21,
            father = 0,
            shapeMix = 0.5,
            skinMix = 0.5
        },
        faceFeatures = {},
        headOverlays = {}
    }

    local defaultInventory = {
        maxWeight = 100,
        rows = 10,
        columns = 10,
        items = {}
    }

    local defaultJob = {
        name = "unemployed",
        label = "Unemployed",
        grade = 0,
        grade_label = "Unemployed",
        salary = 0
    }

    MySQL.Async.execute([[
        INSERT INTO characters 
        (identifier, char_slot, citizenid, first_name, last_name, money, job, appearance, inventory) 
        VALUES (@identifier, @slot, @citizenid, @firstName, @lastName, @money, @job, @appearance, @inventory)
    ]], {
        ['@identifier'] = identifier,
        ['@slot'] = slot,
        ['@citizenid'] = citizenid,
        ['@firstName'] = data.firstName,
        ['@lastName'] = data.lastName,
        ['@money'] = json.encode({
            cash = Config.StartingMoney,
            bank = Config.StartingBank
        }),
        ['@job'] = json.encode(defaultJob),
        ['@appearance'] = json.encode(defaultAppearance),
        ['@inventory'] = json.encode(defaultInventory)
    }, function(rowsChanged)
        if rowsChanged > 0 then
            Core.Functions.LoadCharacter(source, citizenid, true)
            cb(true, citizenid)
        else
            cb(false)
        end
    end)
end
exports('CreateCharacter', Core.Functions.CreateCharacter)

---@param source integer?
---@return table? player
function Core.Functions.GetPlayer(source)
    if not source then
        return nil
    end

    source = tonumber(source)
    if not source then
        return nil
    end

    local player = Core.Players[source]
    return player
end

exports('GetPlayer', Core.Functions.GetPlayer)

---@param citizenid string
---@return table? player
function Core.Functions.GetPlayerByCitizenId(citizenid)
    if not citizenid then
        return nil
    end

    for _, player in pairs(Core.Players) do
        if player.PlayerData.citizenid == citizenid then
            return player
        end
    end

    return nil
end

exports('GetPlayerByCitizenId', Core.Functions.GetPlayerByCitizenId)

---@return table players all players
function Core.Functions.GetPlayers()
    return Core.Players
end

exports('GetPlayers', Core.Functions.GetPlayers)

---@param source integer?
---@param citizenid string
---@param isNewCharacter boolean
---@return boolean success
function Core.Functions.LoadCharacter(source, citizenid, isNewCharacter)
    if not source or not citizenid then
        print("^1Error: Invalid source or citizenid in LoadCharacter^7")
        return false
    end

    source = tonumber(source)
    if not source then
        print("^1Error: Invalid source type in LoadCharacter^7")
        return false
    end

    MySQL.Async.fetchAll('SELECT * FROM characters WHERE citizenid = @citizenid LIMIT 1', {
        ['@citizenid'] = citizenid
    }, function(result)
        if result and result[1] then
            local char = result[1]
            local self = {}

            print('[debug] loading character money ' .. char.money)
            self.source = source
            self.citizenid = citizenid
            self.Money = json.decode(char.money) or {
                cash = 0,
                bank = 0
            }
            self.Job = json.decode(char.job) or { -- fallback
                name = "unemployed",
                label = "Unemployed",
                grade = 0,
                grade_label = "Unemployed",
                salary = 0
            }
            if isNewCharacter then
                self.position = Config.StartingPosition
            else
                self.position = json.decode(char.position) or Config.StartingPosition
            end
            self.Name = {
                first_name = char.first_name,
                last_name = char.last_name
            }
            self.Stats = json.decode(char.stats) or {
                hunger = 100,
                thirst = 100
            }
            self.Appearance = json.decode(char.appearance) or { -- fallback
                model = "mp_m_freemode_01",
                clothing = {},
                genetics = {},
                faceFeatures = {},
                headOverlays = {}
            }
            self.Inventory = json.decode(char.inventory) or { -- fallback
                maxWeight = 100, -- set to config later
                rows = 10, -- set to config later
                columns = 10, -- set to config later
                items = {}
            }

            self.Functions = {
                Save = function()
                    if SavePlayerData(self.source) then
                        print("^2Saved player data^7")
                        TriggerClientEvent('kCore:updateData', self.source, self)
                    end
                end,

                UpdateJob = function(job, grade)
                    if not Shared.Jobs[job] then
                        print("^1Error: Job does not exist: " .. job .. "^7")
                        return false
                    elseif not Shared.Jobs[job][grade] then
                        print("^1Error: Grade " .. grade .. " does not exist for job: " .. job .. "^7")
                    end

                    self.Meta.Job.name = job
                    self.Meta.Job.grade = grade
                    self.Meta.Job.salary = Shared.Jobs[job][grade].salary
                    self.Meta.Job.grade_label = Shared.Jobs[job][grade].label
                    self.Functions.Save()

                    return true
                end,

                UpdateAppearance = function(AppearanceData)
                    local safeAppearance = {
                        model = AppearanceData.model or self.Appearance.model,
                        clothing = AppearanceData.clothing or self.Appearance.clothing,
                        genetics = AppearanceData.genetics or self.Appearance.genetics,
                        faceFeatures = AppearanceData.faceFeatures or self.Appearance.faceFeatures,
                        headOverlays = AppearanceData.headOverlays or self.Appearance.headOverlays
                    }
                    self.Appearance = safeAppearance
                    self.Functions.Save()
                    return true
                end,

                GetAppearance = function()
                    return self.Appearance
                end,

                UpdateInventory = function(inventory) -- rework eventually
                    print('[' .. self.citizenid .. '] Updating inventory', inventory)

                    self.Inventory = inventory
                    MySQL.Async.execute([[
                        UPDATE characters 
                        SET inventory = @inventory
                        WHERE citizenid = @citizenid
                    ]], {
                        ['@inventory'] = json.encode(inventory),
                        ['@citizenid'] = self.citizenid
                    }, function(rowsChanged)
                        if rowsChanged == 0 then
                            print("^1Failed to update inventory for player " .. self.citizenid .. "^7")
                        else
                            print("^2Successfully saved inventory to database^7")
                        end
                    end)
                    print(self.source)
                    TriggerClientEvent('kCore:refreshInventory', self.source, {
                        id = 'player',
                        name = 'Player Inventory',
                        rows = self.Inventory.rows,
                        columns = self.Inventory.columns,
                        items = self.Inventory.items
                    })
                    return true
                end,

                UpdateMoney = function(moneyData) -- seperate function for updating money, do this for most other things
                    if MySQL.query.await('UPDATE characters SET money = ? WHERE citizenid = ?', {json.encode(moneyData), self.citizenid}) then
                        return true
                    else
                        return false
                    end
                end
            }

            Core.Players[source] = self

            print("^2Loaded character^7")
            print("Source:", self.source)
            print("CitizenID:", self.citizenid)
            SetPlayerRoutingBucket(source, 0)
            TriggerClientEvent('kCore:loadPlayer', source, self, isNewCharacter)
            TriggerEvent('kCore:loadPlayer', source, self, isNewCharacter)
            return true
        else
            print('^1Error: No character found for citizenid: ' .. citizenid .. '^7')
            return false
        end
    end)
    return true
end

---@param source integer
---@return boolean success
function SavePlayerData(source) -- rework eventually 
    local Player = Core.Functions.GetPlayer(source)
    if Player then
        local ped = GetPlayerPed(source)
        print(GetEntityCoords(ped), ped)
        local pos = GetEntityCoords(ped)
        local heading = GetEntityHeading(ped)

        local position = { -- fallback incase something goes weird
            x = pos.x or Config.StartingPosition.x,
            y = pos.y or Config.StartingPosition.y,
            z = pos.z or Config.StartingPosition.z,
            heading = heading or Config.StartingPosition.heading
        }

        local saveData = {
            money = json.encode(Player.Money),
            position = json.encode(position),
            stats = json.encode(Player.Stats),
            inventory = json.encode(Player.Inventory),
            job = json.encode(Player.Job),
            citizenid = Player.citizenid
        }

        MySQL.Async.execute([[
            UPDATE characters 
            SET money = @money, 
                position = @position, 
                stats = @stats,
                job = @job,
                inventory = @inventory,
                last_updated = CURRENT_TIMESTAMP 
            WHERE citizenid = @citizenid
        ]], saveData, function(rowsChanged)
            if rowsChanged == 0 then
                print("^1Failed to update database for player " .. source .. " (CitizenID: " .. Player.citizenid ..")^7")
            else
                print("^2Successfully saved player data to database^7")
            end
        end)
        return true
    end
    return false
end

exports('SavePlayerData', Core.Functions.SavePlayerData)

---@param id integer
---@param slot integer
---@param source integer
---@param cb function
function Core.Functions.SelectCharacter(id, slot, source, cb)
    local identifier = GetPlayerIdentifier(source)

    if not identifier then
        print("^1Error: No identifier found for source: " .. source .. "^7")
        return
    end

    print("^2Processing character selection^7")
    print("Source:", source)
    print("Identifier:", identifier)
    print("Slot:", slot)

    MySQL.Async.fetchAll('SELECT citizenid FROM characters WHERE identifier = @identifier AND char_slot = @slot', {
        ['@identifier'] = identifier,
        ['@slot'] = slot
    }, function(result)
        if result and result[1] then
            print("^2Loading existing character^7")
            Core.Functions.LoadCharacter(source, result[1].citizenid, false)
        end
    end)
end

exports('SelectCharacter', Core.Functions.SelectCharacter)

---@param source integer
---@param AppearanceData table
---@return boolean success
function Core.Functions.UpdatePlayerAppearance(source, AppearanceData)
    local Player = Core.Functions.GetPlayer(source)
    if Player then
        return Player.Functions.UpdateAppearance(AppearanceData)
    end
    return false
end
exports('UpdatePlayerAppearance', Core.Functions.UpdatePlayerAppearance)

---@param citizenid string
---@param src integer
---@param cb fun(success: boolean, err: string?)
function Core.Functions.DeleteCharacter(citizenid, src, cb) -- can delete by EITHER cid OR source
    if not citizenid and not src then
        print("^1Error: No citizenid or source provided for deletion^7")
        if cb then cb(false, "No citizenid or source provided") end
        return
    end

    local player
    if citizenid then
        player = Core.Functions.GetPlayerByCitizenId(citizenid)
        if player then
            src = player.source
        end
    else
        player = Core.Functions.GetPlayer(src)
        if player then
            citizenid = player.citizenid
            if not citizenid then
                print("^1Error: Unable to find char by source^7")
                if cb then cb(false, "Unable to find char by source") end
                return
            end
        end
    end

    -- drop player before deleting the character if online
    if player then
        local p = promise.new()
        DropPlayer(src, "Character Deleted")

        CreateThread(function() -- async thread with a little wait to make sure all resources handled the drop before deleting data
            Wait(100)
            p:resolve()
        end)

        Await(p)
    end

    MySQL.Async.execute('DELETE FROM characters WHERE citizenid = @cid', {
        ['@cid'] = citizenid,
    }, function(rowsChanged)
        if rowsChanged > 0 then
            print("^2Character deleted for citizenid:^7", citizenid)
            if cb then cb(true) end
        else
            print("^1Failed to delete character for citizenid:^7", citizenid)
            if cb then cb(false, "Failed to delete character") end
        end
    end)
end

exports('DeleteCharacter', Core.Functions.DeleteCharacter)





AddEventHandler('playerDropped', function()
    local source = source
    if Core.Players[source] then
        Core.Players[source].Functions.Save()
        Core.Players[source] = nil
    end
end)

---@param source integer
---@return boolean IsInitialized
function Core.Functions.IsPlayerInitialized(source)
    return Core.Players[source] ~= nil
end

exports('IsPlayerInitialized', Core.Functions.IsPlayerInitialized)

