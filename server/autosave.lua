local saveMessageColor = "^2"
local errorMessageColor = "^1"
local debug = true

local saveStats = {
    attempts = 0,
    successes = 0,
    failures = 0,
    lastError = nil
}

local function GetTimestamp()
    return os.date("%Y-%m-%d %H:%M:%S")
end

local function FormatNumber(number)
    local formatted = tostring(number)
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then
            break
        end
    end
    return formatted
end



CreateThread(function()
    while true do
        Wait(Config.SaveInterval)

        local playerCount = 0
        local totalCash = 0
        local totalBank = 0
        local failedSaves = 0
        local failedPlayers = {}
        local saveTime = GetTimestamp()

        if not Core.Players then
            goto continue
        end

        for source, playerData in pairs(Core.Players) do
            if not playerData or not playerData.Functions or not playerData.Functions.Save then
                goto continue_player
            end

            local success, error = pcall(function()
                return playerData.Functions.Save()
            end)

            if success then
                playerCount = playerCount + 1
                totalCash = totalCash + (playerData.Money and playerData.Money.cash or 0)
                totalBank = totalBank + (playerData.Money and playerData.Money.bank or 0)
            else
                failedSaves = failedSaves + 1
                table.insert(failedPlayers, {
                    source = source,
                    error = error
                })
                print("^1Error saving player^7:", source, error)
            end

            ::continue_player::
        end

        if playerCount > 0 or failedSaves > 0 then
            print(string.rep("-", 70))
            print(saveMessageColor .. "Auto-Save Report - " .. saveTime .. "^7")
            print(string.rep("-", 70))

            if playerCount > 0 then
                print(saveMessageColor .. "Successfully saved data for " .. playerCount .. " player(s)^7")

                if debug then
                    print("Total Cash in kCore: $" .. FormatNumber(totalCash))
                    print("Total Bank in kCore: $" .. FormatNumber(totalBank))
                    print("Total Money in kCore: $" .. FormatNumber(totalCash + totalBank))
                end
            end

            if failedSaves > 0 then
                print(errorMessageColor .. "Failed to save data for " .. failedSaves .. " player(s)^7")
                if debug then
                    for _, failedPlayer in ipairs(failedPlayers) do
                        local identifier = GetPlayerIdentifier(failedPlayer.source)
                        print(errorMessageColor .. "Failed player: " .. failedPlayer.source .. " (ID: " ..
                                  (identifier or "unknown") .. ") - Error: " .. tostring(failedPlayer.error) .. "^7")
                    end
                end
            end

            print(string.rep("-", 70))
        end

        ::continue::
    end
end)


