local saveMessageColor, errorMessageColor = "^2", "^1"
local debug = true
local os_date = os.date
local string_rep = string.rep
local string_format = string.format
local table_insert = table.insert
local pairs = pairs
local tostring = tostring
local pcall = pcall
local print = print

local function GetTimestamp()
    return os_date("%Y-%m-%d %H:%M:%S")
end

local function FormatNumber(number)
    local formatted = tostring(number)
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

CreateThread(function()
    local saveInterval = Config.SaveInterval
    local dashLine = string_rep("-", 70)

    while true do
        Wait(saveInterval)

        local playerCount, totalCash, totalBank, failedSaves = 0, 0, 0, 0
        local failedPlayers = {}
        local saveTime = GetTimestamp()

        if not Core.Players then goto continue end

        for source, playerData in pairs(Core.Players) do
            if playerData and playerData.Functions and playerData.Functions.Save then
                local success, error = pcall(playerData.Functions.Save)

                if success then
                    playerCount = playerCount + 1
                    totalCash = totalCash + (playerData.Money and playerData.Money.cash or 0)
                    totalBank = totalBank + (playerData.Money and playerData.Money.bank or 0)
                else
                    failedSaves = failedSaves + 1
                    failedPlayers[#failedPlayers + 1] = {source = source, error = error}
                    print(errorMessageColor .. "Error saving player: " .. source .. " - " .. tostring(error) .. "^7")
                end
            end
        end

        if playerCount > 0 or failedSaves > 0 then
            local report = {
                dashLine,
                saveMessageColor .. "Auto-Save Report - " .. saveTime .. "^7",
                dashLine
            }

            if playerCount > 0 then
                report[#report + 1] = saveMessageColor .. "Successfully saved data for " .. playerCount .. " player(s)^7"

                if debug then
                    report[#report + 1] = "Total Cash in kCore: $" .. FormatNumber(totalCash)
                    report[#report + 1] = "Total Bank in kCore: $" .. FormatNumber(totalBank)
                    report[#report + 1] = "Total Money in kCore: $" .. FormatNumber(totalCash + totalBank)
                end
            end

            if failedSaves > 0 then
                report[#report + 1] = errorMessageColor .. "Failed to save data for " .. failedSaves .. " player(s)^7"
                if debug then
                    for _, failedPlayer in ipairs(failedPlayers) do
                        local identifier = GetPlayerIdentifier(failedPlayer.source)
                        report[#report + 1] = string_format("%sFailed player: %s (ID: %s) - Error: %s^7",
                            errorMessageColor, failedPlayer.source, identifier or "unknown", tostring(failedPlayer.error))
                    end
                end
            end

            report[#report + 1] = dashLine
            print(table.concat(report, "\n"))
        end

        ::continue::
    end
end)