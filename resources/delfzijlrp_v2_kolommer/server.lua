local ESX = exports['es_extended']:getSharedObject()

local function notify(src, msg, kind)
    TriggerClientEvent('ox_lib:notify', src, { title = 'De2Kolommer', description = msg, type = kind or 'inform' })
end

local function isMechanic(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    return xPlayer and xPlayer.job and xPlayer.job.name == Config.JobName
end

local function pay(src, amount)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return false end
    if xPlayer.getMoney() >= amount then xPlayer.removeMoney(amount) return true end
    local bank = xPlayer.getAccount('bank')
    if bank and bank.money >= amount then xPlayer.removeAccountMoney('bank', amount) return true end
    return false
end

lib.callback.register('delfzijlrp_v2_kolommer:server:pay', function(source, amount)
    return pay(source, tonumber(amount) or 0)
end)

lib.callback.register('delfzijlrp_v2_kolommer:server:isMechanic', function(source)
    return isMechanic(source)
end)

RegisterNetEvent('delfzijlrp_v2_kolommer:server:renewApk', function(plate)
    local src = source
    if not isMechanic(src) then notify(src, Config.Text.noAccess, 'error') return end
    plate = plate and plate:gsub('^%s*(.-)%s*$', '%1'):upper() or ''
    if plate == '' then notify(src, Config.Text.invalid, 'error') return end
    TriggerEvent('delfzijlrp_rdw:server:renewApk', plate)
end)

RegisterNetEvent('delfzijlrp_v2_kolommer:server:openStorage', function()
    local src = source
    if not isMechanic(src) then notify(src, Config.Text.noAccess, 'error') return end
    exports.ox_inventory:RegisterStash('de2kolommer_storage', 'De2Kolommer Opslag', 80, 160000)
    TriggerClientEvent('delfzijlrp_v2_kolommer:client:openStorage', src)
end)
