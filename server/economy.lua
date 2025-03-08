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


    if Player.Functions.UpdateMoney(Player.Money) then

        TriggerClientEvent('kCore:updateMoney', source, {
            cash = Player.Money.cash,
            bank = Player.Money.bank
        }, moneytype)
        TriggerEvent('kCore:updateMoney', source, {
            cash = Player.Money.cash,
            bank = Player.Money.bank
        }, moneytype)

        return true
    else
        return false
    end
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

    if moneytype == 'cash' or moneytype == 'money' then
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

    if Player.Functions.UpdateMoney(Player.Money) then
        TriggerClientEvent('kCore:updateMoney', source, {
            cash = Player.Money.cash,
            bank = Player.Money.bank
        }, moneytype)
        TriggerEvent('kCore:updateMoney', source, {
            cash = Player.Money.cash,
            bank = Player.Money.bank
        }, moneytype)
        return true
    else
        return false
    end
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

    if type == 'cash' or type == 'money' then
        return sourcePlayer.Money.cash
    elseif type == 'bank' then
        return sourcePlayer.Money.bank
    else
        print("^1Error: Invalid money type^7:", type)
        return false
    end
end

exports('AddMoney', Core.Functions.AddMoney)

exports('RemoveMoney', Core.Functions.RemoveMoney)

exports('GetMoney', Core.Functions.GetMoney)

exports('TransferMoney', Core.Functions.TransferMoney)

-- paychecks
CreateThread(function()
    if not Config.PaycheckInterval then
        return
    end
    while true do
        Wait(Config.PaycheckInterval)
        for k, v in pairs(GetPlayers()) do
            local Player = Core.Functions.GetPlayer(v)
            if Player then
                Core.Functions.AddMoney(v, v.Job.salary, 'bank')
            end
        end
    end
end)

---- company funds
function Core.Functions.GetAccountMoney(account)
    if not account then
        return false
    end
    local rs = MySQL.query.await('SELECT balance FROM bank_accounts WHERE owner = ? LIMIT 1', {account})
    if rs[1] then
        return rs[1].balance
    end
end

exports('GetAccountMoney', Core.Functions.GetAccountMoney)

function Core.Functions.AddAccountMoney(account, amount)
    if not account then
        return false
    end

    amount = tonumber(amount)
    if not amount or amount <= 0 then
        return false
    end

    local rs = MySQL.query.await('SELECT balance FROM bank_accounts WHERE owner = ? LIMIT 1', {account})
    if rs[1] then
        local newBalance = rs[1].balance + amount
        MySQL.query.await('UPDATE bank_accounts SET balance = ? WHERE owner = ?', {newBalance, account})
        TriggerEvent('kCore:updateAccountMoney', account, newBalance, rs[1].balance)
        return newBalance
    end
    return false
end

exports('AddAccountMoney', Core.Functions.AddAccountMoney)

function Core.Functions.RemoveAccountMoney(account, amount)
    if not account then
        return false
    end

    amount = tonumber(amount)
    if not amount or amount <= 0 then
        return false
    end

    local rs = MySQL.query.await('SELECT balance FROM bank_accounts WHERE owner = ? LIMIT 1', {account})
    if rs[1] then
        local newBalance = rs[1].balance - amount
        if newBalance < 0 then
            return false
        end
        MySQL.query.await('UPDATE bank_accounts SET balance = ? WHERE owner = ?', {newBalance, account})
        TriggerEvent('kCore:updateAccountMoney', account, newBalance, rs[1].balance)
        return newBalance
    end
    return false
end

exports('RemoveAccountMoney', Core.Functions.RemoveAccountMoney)
