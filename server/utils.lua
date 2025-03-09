math.randomseed(os.time())

---@return string uid
function Core.Functions.GenerateUID()
    local template = "KC%d%d%d%d%d%d"

    local uid

    while true do
        local nums = ""
        for i = 1, 6 do
            nums = nums .. tostring(math.random(0, 9))
        end

        uid = string.format(template, nums:match("(%d)(%d)(%d)(%d)(%d)(%d)"))

        local rs = MySQL.query.await('SELECT citizenid FROM characters WHERE citizenid = ? LIMIT 1', {uid})

        if not rs[1] then
            break
        end
    end

    return uid
end

AddEventHandler('playerJoining', function()
    Wait(0) -- wait 1 frame until the player indices are updated
    GlobalState.numberPlayer = GetNumPlayerIndices()
end)

AddEventHandler('playerDropped', function()
	GlobalState.numberPlayer = GetNumPlayerIndices()
end)

GlobalState.maxClients = GetConvar('sv_maxclients', 0)