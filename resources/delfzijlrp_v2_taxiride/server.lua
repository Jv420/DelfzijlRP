local ESX = exports['es_extended']:getSharedObject()

local function pay(xPlayer, amount)
    if xPlayer.getMoney() >= amount then xPlayer.removeMoney(amount) return true end
    local bank = xPlayer.getAccount('bank')
    if bank and bank.money >= amount then xPlayer.removeAccountMoney('bank', amount) return true end
    return false
end

lib.callback.register('delfzijlrp_v2_taxiride:server:pay', function(source, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end
    return pay(xPlayer, tonumber(amount) or 0)
end)
