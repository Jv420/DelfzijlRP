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
        title = 'Brandweer Delfzijl',
        description = message,
        type = type or 'inform'
    })
end

local function isFire(source)
    local xPlayer = getPlayer(source)
    return xPlayer and xPlayer.job and xPlayer.job.name == Config.JobName
end

local function getIncidentConfig(incidentType)
    return Config.Incidents[incidentType]
end

local function logFire(incidentId, source, action, details)
    MySQL.insert.await('INSERT INTO delfzijlrp_fire_logs (incident_id, identifier, action, details) VALUES (?, ?, ?, ?)', {
        incidentId,
        getIdentifier(source),
        action,
        details
    })
end

lib.callback.register('delfzijlrp_fire_rescue:server:isFire', function(source)
    return isFire(source)
end)

lib.callback.register('delfzijlrp_fire_rescue:server:getActiveIncident', function(source)
    local identifier = getIdentifier(source)
    if not identifier then return nil end
    return MySQL.single.await('SELECT * FROM delfzijlrp_fire_incidents WHERE identifier = ? AND status = ? ORDER BY created_at DESC LIMIT 1', {
        identifier,
        'active'
    })
end)

lib.callback.register('delfzijlrp_fire_rescue:server:getStats', function(source)
    local identifier = getIdentifier(source)
    if not identifier then return nil end
    return MySQL.single.await([[SELECT COUNT(*) as incidents, COALESCE(SUM(payout), 0) as earned
        FROM delfzijlrp_fire_incidents WHERE identifier = ? AND status = ?]], { identifier, 'completed' })
end)

RegisterNetEvent('delfzijlrp_fire_rescue:server:toggleDuty', function()
    local source = source
    local identifier = getIdentifier(source)
    if not identifier or not isFire(source) then return end

    local current = MySQL.scalar.await('SELECT on_duty FROM delfzijlrp_fire_duty WHERE identifier = ? LIMIT 1', { identifier })
    local newState = current == 1 and 0 or 1

    MySQL.insert.await([[INSERT INTO delfzijlrp_fire_duty (identifier, on_duty) VALUES (?, ?)
        ON DUPLICATE KEY UPDATE on_duty = VALUES(on_duty)]], { identifier, newState })

    notify(source, newState == 1 and Config.Text.dutyOn or Config.Text.dutyOff, 'success')
end)

RegisterNetEvent('delfzijlrp_fire_rescue:server:startIncident', function(incidentType, locationId, coords)
    local source = source
    local identifier = getIdentifier(source)
    local incident = getIncidentConfig(incidentType)
    if not identifier or not isFire(source) or not incident then return end

    local active = MySQL.scalar.await('SELECT id FROM delfzijlrp_fire_incidents WHERE identifier = ? AND status = ? LIMIT 1', { identifier, 'active' })
    if active then
        notify(source, Config.Text.alreadyActive, 'error')
        return
    end

    local payout = math.random(incident.payout.min, incident.payout.max)
    local incidentId = MySQL.insert.await('INSERT INTO delfzijlrp_fire_incidents (identifier, incident_type, location_id, payout) VALUES (?, ?, ?, ?)', {
        identifier,
        incidentType,
        locationId,
        payout
    })

    logFire(incidentId, source, 'start_incident', incidentType .. ':' .. locationId)
    notify(source, Config.Text.incidentStarted, 'success')
    TriggerEvent('delfzijlrp_dispatch:server:createReport', 'emergency', ('Brandweerincident: %s'):format(incident.label), coords or {})
end)

RegisterNetEvent('delfzijlrp_fire_rescue:server:completeIncident', function(incidentId)
    local source = source
    local xPlayer = getPlayer(source)
    local identifier = getIdentifier(source)
    incidentId = tonumber(incidentId)
    if not xPlayer or not identifier or not isFire(source) or not incidentId then return end

    local incident = MySQL.single.await('SELECT * FROM delfzijlrp_fire_incidents WHERE id = ? AND identifier = ? AND status = ? LIMIT 1', {
        incidentId,
        identifier,
        'active'
    })
    if not incident then
        notify(source, Config.Text.noIncident, 'error')
        return
    end

    MySQL.update.await('UPDATE delfzijlrp_fire_incidents SET status = ?, completed_at = NOW() WHERE id = ?', { 'completed', incidentId })
    xPlayer.addAccountMoney('bank', incident.payout)
    logFire(incidentId, source, 'complete_incident', tostring(incident.payout))
    notify(source, Config.Text.incidentDone .. ' €' .. incident.payout, 'success')
end)

RegisterNetEvent('delfzijlrp_fire_rescue:server:openStorage', function(stationId)
    local source = source
    if not isFire(source) then return end
    local stashId = ('fire_storage_%s'):format(stationId or 'main')
    exports.ox_inventory:RegisterStash(stashId, 'Brandweer Opslag', 80, 180000)
    TriggerClientEvent('delfzijlrp_fire_rescue:client:openStash', source, stashId)
end)
