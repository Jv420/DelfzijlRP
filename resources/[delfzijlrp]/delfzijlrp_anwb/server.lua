local ESX = exports['es_extended']:getSharedObject()

local function getPlayer(source)
    return ESX.GetPlayerFromId(source)
end

local function getIdentifier(source)
    local xPlayer = getPlayer(source)
    return xPlayer and xPlayer.identifier or nil
end

local function notify(source, message, type)
    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Delfzijl RP ANWB',
        description = message,
        type = type or 'inform'
    })
end

local function isMechanic(source)
    local xPlayer = getPlayer(source)
    return xPlayer and xPlayer.job and xPlayer.job.name == Config.JobName
end

local function payClient(targetId, amount)
    local xPlayer = getPlayer(targetId)
    if not xPlayer then return false end

    if xPlayer.getMoney() >= amount then
        xPlayer.removeMoney(amount)
        return true
    end

    if xPlayer.getAccount('bank').money >= amount then
        xPlayer.removeAccountMoney('bank', amount)
        return true
    end

    return false
end

local function logAction(source, plate, action, details)
    local xPlayer = getPlayer(source)
    MySQL.insert.await('INSERT INTO delfzijlrp_anwb_logs (mechanic_identifier, mechanic_name, plate, action, details) VALUES (?, ?, ?, ?, ?)', {
        xPlayer and xPlayer.identifier or nil,
        GetPlayerName(source),
        plate,
        action,
        details
    })
end

lib.callback.register('delfzijlrp_anwb:server:isMechanic', function(source)
    return isMechanic(source)
end)

lib.callback.register('delfzijlrp_anwb:server:getVehicleInfo', function(source, plate)
    if not isMechanic(source) then return nil end
    plate = plate and plate:gsub('^%s*(.-)%s*$', '%1') or ''

    return MySQL.single.await('SELECT * FROM delfzijlrp_vehicle_registry WHERE plate = ? LIMIT 1', { plate })
end)

RegisterNetEvent('delfzijlrp_anwb:server:toggleDuty', function()
    local source = source
    local identifier = getIdentifier(source)
    if not identifier or not isMechanic(source) then return end

    local current = MySQL.scalar.await('SELECT on_duty FROM delfzijlrp_anwb_duty WHERE identifier = ? LIMIT 1', { identifier })
    local newState = current == 1 and 0 or 1

    MySQL.insert.await([[INSERT INTO delfzijlrp_anwb_duty (identifier, on_duty) VALUES (?, ?)
        ON DUPLICATE KEY UPDATE on_duty = VALUES(on_duty)]], { identifier, newState })

    notify(source, newState == 1 and Config.Text.dutyOn or Config.Text.dutyOff, 'success')
end)

RegisterNetEvent('delfzijlrp_anwb:server:chargeService', function(targetId, plate, actionType)
    local source = source
    if not isMechanic(source) then return end

    targetId = tonumber(targetId)
    if not targetId or not GetPlayerName(targetId) then
        notify(source, Config.Text.playerNotFound, 'error')
        return
    end

    local price = Config.Prices[actionType]
    if not price then
        notify(source, Config.Text.invalidInput, 'error')
        return
    end

    if not payClient(targetId, price) then
        notify(source, Config.Text.noMoney, 'error')
        return
    end

    logAction(source, plate, actionType, ('Klant:%s Prijs:%s'):format(targetId, price))
    notify(source, 'Factuur betaald en service geregistreerd.', 'success')
    notify(targetId, ('ANWB service betaald: €%s'):format(price), 'success')
end)

RegisterNetEvent('delfzijlrp_anwb:server:renewApk', function(plate)
    local source = source
    if not isMechanic(source) then return end
    plate = plate and plate:gsub('^%s*(.-)%s*$', '%1') or ''

    TriggerEvent('delfzijlrp_vehicles:server:renewApk', plate)
    local apkUntil = os.date('%Y-%m-%d %H:%M:%S', os.time() + (365 * 86400))
    MySQL.update.await('UPDATE delfzijlrp_vehicle_registry SET apk_until = ? WHERE plate = ?', { apkUntil, plate })
    logAction(source, plate, 'apk', 'APK vernieuwd via ANWB')
    notify(source, Config.Text.apkRenewed, 'success')
end)

RegisterNetEvent('delfzijlrp_anwb:server:openStorage', function(stationId)
    local source = source
    if not isMechanic(source) then return end
    local stashId = ('anwb_storage_%s'):format(stationId or 'main')
    exports.ox_inventory:RegisterStash(stashId, 'ANWB Opslag', 80, 180000)
    TriggerClientEvent('delfzijlrp_anwb:client:openStash', source, stashId)
end)
