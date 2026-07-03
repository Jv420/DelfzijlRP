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
        title = 'Delfzijl RP Politie',
        description = message,
        type = type or 'inform'
    })
end

local function isPolice(source)
    local xPlayer = getPlayer(source)
    return xPlayer and xPlayer.job and xPlayer.job.name == Config.JobName
end

local function logAction(source, action, target, details)
    local xPlayer = getPlayer(source)
    MySQL.insert.await('INSERT INTO delfzijlrp_police_logs (officer_identifier, officer_name, action, target, details) VALUES (?, ?, ?, ?, ?)', {
        xPlayer and xPlayer.identifier or nil,
        GetPlayerName(source),
        action,
        target,
        details
    })
end

lib.callback.register('delfzijlrp_police:server:isPolice', function(source)
    return isPolice(source)
end)

lib.callback.register('delfzijlrp_police:server:getVehicleInfo', function(source, plate)
    if not isPolice(source) then return nil end
    plate = plate and plate:gsub('^%s*(.-)%s*$', '%1') or ''

    return MySQL.single.await([[SELECT r.*, i.firstname, i.lastname, i.delfzijl_id
        FROM delfzijlrp_vehicle_registry r
        LEFT JOIN delfzijlrp_identities i ON i.identifier = r.owner
        WHERE r.plate = ? LIMIT 1]], { plate })
end)

RegisterNetEvent('delfzijlrp_police:server:toggleDuty', function()
    local source = source
    local identifier = getIdentifier(source)
    if not identifier or not isPolice(source) then return end

    local current = MySQL.scalar.await('SELECT on_duty FROM delfzijlrp_police_duty WHERE identifier = ? LIMIT 1', { identifier })
    local newState = current == 1 and 0 or 1

    MySQL.insert.await([[INSERT INTO delfzijlrp_police_duty (identifier, on_duty) VALUES (?, ?)
        ON DUPLICATE KEY UPDATE on_duty = VALUES(on_duty)]], { identifier, newState })

    notify(source, newState == 1 and 'Je bent in dienst.' or 'Je bent uit dienst.', 'success')
    logAction(source, 'toggle_duty', nil, tostring(newState))
end)

RegisterNetEvent('delfzijlrp_police:server:createFine', function(targetId, category, reason, amount)
    local source = source
    if not isPolice(source) then return end

    local target = getPlayer(tonumber(targetId))
    amount = tonumber(amount) or 0
    if not target or amount <= 0 or not reason then
        notify(source, Config.Text.invalidInput, 'error')
        return
    end

    local identity = MySQL.single.await('SELECT firstname, lastname FROM delfzijlrp_identities WHERE identifier = ? LIMIT 1', { target.identifier })
    local targetName = identity and (identity.firstname .. ' ' .. identity.lastname) or GetPlayerName(target.source)

    TriggerEvent('delfzijlrp_mdt:server:createFine', target.identifier, targetName, category or 'other', reason, amount)
    logAction(source, 'create_fine', target.identifier, ('%s:%s'):format(reason, amount))
    notify(source, Config.Text.fineSent, 'success')
end)

RegisterNetEvent('delfzijlrp_police:server:setVehicleStolen', function(plate, state)
    local source = source
    if not isPolice(source) then return end
    plate = plate and plate:gsub('^%s*(.-)%s*$', '%1') or ''

    MySQL.update.await('UPDATE delfzijlrp_vehicle_registry SET stolen = ? WHERE plate = ?', { state and 1 or 0, plate })
    logAction(source, 'vehicle_stolen_status', plate, tostring(state))
    notify(source, Config.Text.statusUpdated, 'success')
end)

RegisterNetEvent('delfzijlrp_police:server:setVehicleImpounded', function(plate, state)
    local source = source
    if not isPolice(source) then return end
    plate = plate and plate:gsub('^%s*(.-)%s*$', '%1') or ''

    MySQL.update.await('UPDATE delfzijlrp_vehicle_registry SET impounded = ? WHERE plate = ?', { state and 1 or 0, plate })
    logAction(source, 'vehicle_impound_status', plate, tostring(state))
    notify(source, Config.Text.statusUpdated, 'success')
end)

RegisterNetEvent('delfzijlrp_police:server:openEvidence', function(stationId)
    local source = source
    if not isPolice(source) then return end
    local stashId = ('police_evidence_%s'):format(stationId or 'main')
    exports.ox_inventory:RegisterStash(stashId, 'Politie Bewijskluis', 100, 250000)
    TriggerClientEvent('delfzijlrp_police:client:openStash', source, stashId)
end)

RegisterNetEvent('delfzijlrp_police:server:openArmory', function()
    local source = source
    if not isPolice(source) then return end
    local stashId = 'police_armory'
    exports.ox_inventory:RegisterStash(stashId, 'Politie Uitrusting', 50, 100000)
    TriggerClientEvent('delfzijlrp_police:client:openStash', source, stashId)
end)
