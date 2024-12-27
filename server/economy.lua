
function Core.Functions.AddMoney(source, amount, moneytype)
    local Player = Core.Functions.GetPlayer(source)
    if not Player then 
        return false 
    end
    
    amount = tonumber(amount)
    if not amount or amount <= 0 then
        return false
    end
    
    if moneytype == 'cash' then
        Player.Money.cash = Player.Money.cash + amount
    elseif moneytype == 'bank' then
        Player.Money.bank = Player.Money.bank + amount
    else
        return false
    end
    
    Player.Functions.Save()
    
    TriggerClientEvent('kCore:updateMoney', source, {
        cash = Player.Money.cash,
        bank = Player.Money.bank
    })
    
    return true
end

function Core.Functions.RemoveMoney(source, amount, moneytype)
    local Player = Core.Functions.GetPlayer(source)
    if not Player then 
        return false 
    end
    
    amount = tonumber(amount)
    if not amount or amount <= 0 then
        return false
    end
    
    if moneytype == 'cash' then
        if Player.Money.cash >= amount then
            Player.Money.cash = Player.Money.cash - amount
        else
            return false
        end
    elseif moneytype == 'bank' then
        if Player.Money.bank >= amount then
            Player.Money.bank = Player.Money.bank - amount
        else
            return false
        end
    else
        return false
    end
    
    Player.Functions.Save()
    
    TriggerClientEvent('kCore:updateMoney', source, {
        cash = Player.Money.cash,
        bank = Player.Money.bank
    })
    
    return true
end

function Core.Functions.TransferMoney(source, target, amount)
    local sourcePlayer = Core.Functions.GetPlayer(source)
    local targetPlayer = Core.Functions.GetPlayer(target)
    
    if not sourcePlayer or not targetPlayer then
        return false
    end
    
    amount = tonumber(amount)
    if not amount or amount <= 0 then
        return false
    end
    
    if sourcePlayer.Money.bank < amount then
        TriggerClientEvent('kCore:notification', source, 'Insufficient funds')
        return false
    end
    
    if Core.Functions.RemoveMoney(source, amount, 'bank') then
        if Core.Functions.AddMoney(target, amount, 'bank') then
            TriggerClientEvent('kCore:notification', source, 'Transfer successful')
            TriggerClientEvent('kCore:notification', target, 'Received $' .. amount)
            return true
        else
            Core.Functions.AddMoney(source, amount, 'bank')
            TriggerClientEvent('kCore:notification', source, 'Transfer failed')
            return false
        end
    end
    return false
end

function Core.Functions.GetMoney(source, type)
    local sourcePlayer = Core.Functions.GetPlayer(source)
    
    if not sourcePlayer then
        print("^1Error: Invalid source player^7")
        return false
    end
    
    if type == 'cash' then
        return sourcePlayer.Money.cash
    elseif type == 'bank' then
        return sourcePlayer.Money.bank
    else
        print("^1Error: Invalid money type^7:", type)
        return false
    end
end


exports('AddMoney', function(source, amount, type)
    return Core.Functions.AddMoney(source, amount, type)
end)

exports('RemoveMoney', function(source, amount, type)
    return Core.Functions.RemoveMoney(source, amount, type)
end)

exports('GetMoney', function(source, type)
    return Core.Functions.GetMoney(source, type)
end)

exports('TransferMoney', function(source, target, amount)
    return Core.Functions.TransferMoney(source, target, amount)
end)
