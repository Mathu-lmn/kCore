function Core.Functions.HasPermission(source, permission)
    if not source or not permission then return false end
    
    source = tonumber(source)
    if not source then return false end

    if not Core.Players[source] then return false end

    if IsPlayerAceAllowed(source, permission) then
        return true
    end

    return false
end
exports('HasPermission', Core.Functions.HasPermission)