local ESX = exports['es_extended']:getSharedObject()

local function notify(src, text, kind)
    TriggerClientEvent('ox_lib:notify', src, { title = 'De2Kolommer', description = text, type = kind or 'inform' })
end

local function clean(plate)
    return tostring(plate or ''):upper():gsub('%s+', '')
end

local function charge(src, amount)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return false end
    if xPlayer.getMoney() >= amount then xPlayer.removeMoney(amount) return true end
    local bank = xPlayer.getAccount('bank')
    if bank and bank.money >= amount then xPlayer.removeAccountMoney('bank', amount) return true end
    return false
end

local function income(action, amount, details, by)
    MySQL.update.await('UPDATE delfzijlrp_businesses SET balance = balance + ?, turnover = turnover + ? WHERE id = ?', { amount, amount, Config.BusinessId })
    exports['delfzijlrp_v3_business_core']:AddLog(Config.BusinessId, action, amount, details, by)
end

RegisterNetEvent('delfzijlrp_v3_de2kolommer:server:apk', function(plate)
    local src = source
    plate = clean(plate)
    if plate == '' then notify(src, Config.Text.invalid, 'error') return end
    if not charge(src, Config.Prices.apk) then notify(src, Config.Text.noMoney, 'error') return end
    TriggerEvent('delfzijlrp_v3_rdw_premium:server:setApk', plate, 30)
    exports['delfzijlrp_v3_veh_eco']:AddHistory(plate, 'apk', 'APK uitgevoerd door De2Kolommer', GetPlayerName(src))
    income('apk', Config.Prices.apk, plate, GetPlayerName(src))
    notify(src, Config.Text.done, 'success')
end)

RegisterNetEvent('delfzijlrp_v3_de2kolommer:server:repair', function(plate)
    local src = source
    plate = clean(plate)
    if plate == '' then notify(src, Config.Text.invalid, 'error') return end
    if not charge(src, Config.Prices.repair) then notify(src, Config.Text.noMoney, 'error') return end
    exports['delfzijlrp_v3_veh_eco']:EnsureProfile(plate, GetPlayerName(src))
    TriggerEvent('delfzijlrp_v3_veh_eco:server:updateScores', plate, 100, 100)
    income('repair', Config.Prices.repair, plate, GetPlayerName(src))
    notify(src, Config.Text.done, 'success')
end)

RegisterNetEvent('delfzijlrp_v3_de2kolommer:server:service', function(plate)
    local src = source
    plate = clean(plate)
    if plate == '' then notify(src, Config.Text.invalid, 'error') return end
    if not charge(src, Config.Prices.service) then notify(src, Config.Text.noMoney, 'error') return end
    exports['delfzijlrp_v3_veh_eco']:EnsureProfile(plate, GetPlayerName(src))
    TriggerEvent('delfzijlrp_v3_veh_eco:server:updateScores', plate, 90, 100)
    income('service', Config.Prices.service, plate, GetPlayerName(src))
    notify(src, Config.Text.done, 'success')
end)

RegisterNetEvent('delfzijlrp_v3_de2kolommer:server:tracker', function(plate)
    local src = source
    plate = clean(plate)
    if plate == '' then notify(src, Config.Text.invalid, 'error') return end
    if not charge(src, Config.Prices.tracker) then notify(src, Config.Text.noMoney, 'error') return end
    TriggerEvent('delfzijlrp_v3_veh_eco:server:setTracker', plate, true)
    income('tracker', Config.Prices.tracker, plate, GetPlayerName(src))
    notify(src, Config.Text.done, 'success')
end)
