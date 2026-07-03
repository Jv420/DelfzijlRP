local ESX = exports['es_extended']:getSharedObject()

local function notify(source, message, type)
    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Delfzijl RP Fuel',
        description = message,
        type = type or 'inform'
    })
end

lib.callback.register('delfzijlrp_fuel:server:payFuel', function(source, price)
    local xPlayer = ESX.GetPlayerFromId(source)
    price = tonumber(price) or 0

    if not xPlayer or price <= 0 then return false end

    if xPlayer.getMoney() >= price then
        xPlayer.removeMoney(price)
        return true
    end

    if xPlayer.getAccount('bank').money >= price then
        xPlayer.removeAccountMoney('bank', price)
        return true
    end

    return false
end)

lib.callback.register('delfzijlrp_fuel:server:hasJerrycan', function(source)
    return (exports.ox_inventory:GetItemCount(source, Config.JerrycanItem) or 0) > 0
end)

RegisterNetEvent('delfzijlrp_fuel:server:buyJerrycan', function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    if xPlayer.getMoney() < Config.JerrycanPrice then
        notify(source, Config.Text.noMoney, 'error')
        return
    end

    xPlayer.removeMoney(Config.JerrycanPrice)
    exports.ox_inventory:AddItem(source, Config.JerrycanItem, 1)
    notify(source, Config.Text.boughtJerrycan, 'success')
end)
