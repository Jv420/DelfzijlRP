local ESX = exports['es_extended']:getSharedObject()

local function notify(source, message, type)
    TriggerClientEvent('delfzijlrp_banking:client:notify', source, message, type or 'inform')
end

local function validAmount(amount, maxAmount)
    amount = tonumber(amount)
    if not amount then return false end
    if amount < Config.Limits.minAmount then return false end
    if maxAmount and amount > maxAmount then return false end
    return math.floor(amount)
end

lib.callback.register('delfzijlrp_banking:server:getBalance', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return nil end

    return {
        cash = xPlayer.getMoney(),
        bank = xPlayer.getAccount('bank').money
    }
end)

RegisterNetEvent('delfzijlrp_banking:server:deposit', function(amount)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    amount = validAmount(amount, Config.Limits.maxDeposit)
    if not amount then
        notify(source, Config.Text.invalidAmount, 'error')
        return
    end

    if xPlayer.getMoney() < amount then
        notify(source, Config.Text.notEnoughCash, 'error')
        return
    end

    xPlayer.removeMoney(amount)
    xPlayer.addAccountMoney('bank', amount)
    notify(source, Config.Text.depositSuccess, 'success')
end)

RegisterNetEvent('delfzijlrp_banking:server:withdraw', function(amount)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    amount = validAmount(amount, Config.Limits.maxWithdraw)
    if not amount then
        notify(source, Config.Text.invalidAmount, 'error')
        return
    end

    if xPlayer.getAccount('bank').money < amount then
        notify(source, Config.Text.notEnoughBank, 'error')
        return
    end

    xPlayer.removeAccountMoney('bank', amount)
    xPlayer.addMoney(amount)
    notify(source, Config.Text.withdrawSuccess, 'success')
end)

RegisterNetEvent('delfzijlrp_banking:server:transfer', function(targetId, amount)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local targetPlayer = ESX.GetPlayerFromId(tonumber(targetId))

    if not xPlayer then return end

    amount = validAmount(amount, Config.Limits.maxTransfer)
    if not amount then
        notify(source, Config.Text.invalidAmount, 'error')
        return
    end

    if tonumber(targetId) == source then
        notify(source, Config.Text.samePlayer, 'error')
        return
    end

    if not targetPlayer then
        notify(source, Config.Text.playerNotFound, 'error')
        return
    end

    if xPlayer.getAccount('bank').money < amount then
        notify(source, Config.Text.notEnoughBank, 'error')
        return
    end

    xPlayer.removeAccountMoney('bank', amount)
    targetPlayer.addAccountMoney('bank', amount)

    notify(source, Config.Text.transferSuccess, 'success')
    notify(targetPlayer.source, Config.Text.receivedTransfer, 'success')
end)
