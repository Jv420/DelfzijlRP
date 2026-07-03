local ESX = exports['es_extended']:getSharedObject()
local frozenPlayers = {}

local function getPlayer(source)
    return ESX.GetPlayerFromId(source)
end

local function getIdentifier(source)
    local xPlayer = getPlayer(source)
    return xPlayer and xPlayer.identifier or nil
end

local function notify(source, message, type)
    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Delfzijl RP Staff',
        description = message,
        type = type or 'inform'
    })
end

local function isStaff(source)
    local xPlayer = getPlayer(source)
    if not xPlayer then return false end
    local group = xPlayer.getGroup and xPlayer.getGroup() or 'user'
    return Config.Groups[group] == true
end

local function logAction(source, action, target, details)
    local xPlayer = getPlayer(source)
    MySQL.insert.await('INSERT INTO delfzijlrp_admin_logs (staff_identifier, staff_name, action, target, details) VALUES (?, ?, ?, ?, ?)', {
        xPlayer and xPlayer.identifier or nil,
        GetPlayerName(source),
        action,
        target,
        details
    })
end

local function notifyStaff(message)
    local players = ESX.GetExtendedPlayers()
    for _, xPlayer in pairs(players) do
        if isStaff(xPlayer.source) then
            notify(xPlayer.source, message, 'inform')
        end
    end
end

lib.callback.register('delfzijlrp_admin:server:isStaff', function(source)
    return isStaff(source)
end)

lib.callback.register('delfzijlrp_admin:server:getPlayers', function(source)
    if not isStaff(source) then return {} end

    local list = {}
    for _, playerId in ipairs(GetPlayers()) do
        local id = tonumber(playerId)
        local xPlayer = getPlayer(id)
        list[#list + 1] = {
            id = id,
            name = GetPlayerName(id),
            identifier = xPlayer and xPlayer.identifier or 'unknown',
            group = xPlayer and xPlayer.getGroup and xPlayer.getGroup() or 'user'
        }
    end
    return list
end)

lib.callback.register('delfzijlrp_admin:server:getReports', function(source)
    if not isStaff(source) then return {} end
    return MySQL.query.await('SELECT * FROM delfzijlrp_admin_reports WHERE status = ? ORDER BY created_at DESC LIMIT 50', { 'open' }) or {}
end)

RegisterNetEvent('delfzijlrp_admin:server:createReport', function(message)
    local source = source
    local identifier = getIdentifier(source)
    if not message or #message < 3 then
        notify(source, Config.Text.invalidInput, 'error')
        return
    end

    MySQL.insert.await('INSERT INTO delfzijlrp_admin_reports (identifier, player_name, message) VALUES (?, ?, ?)', {
        identifier,
        GetPlayerName(source),
        message
    })

    notify(source, Config.Text.reportSent, 'success')
    notifyStaff(('Nieuwe report van %s: %s'):format(GetPlayerName(source), message))
end)

RegisterNetEvent('delfzijlrp_admin:server:closeReport', function(reportId)
    local source = source
    if not isStaff(source) then return end

    reportId = tonumber(reportId)
    if not reportId then return end

    MySQL.update.await('UPDATE delfzijlrp_admin_reports SET status = ?, handled_by = ? WHERE id = ?', {
        'closed',
        getIdentifier(source),
        reportId
    })
    logAction(source, 'close_report', tostring(reportId), nil)
    notify(source, Config.Text.reportClosed, 'success')
end)

RegisterNetEvent('delfzijlrp_admin:server:teleportToPlayer', function(targetId)
    local source = source
    if not isStaff(source) then return end
    targetId = tonumber(targetId)
    if not targetId or not GetPlayerName(targetId) then
        notify(source, Config.Text.playerNotFound, 'error')
        return
    end
    local coords = GetEntityCoords(GetPlayerPed(targetId))
    TriggerClientEvent('delfzijlrp_admin:client:teleport', source, coords)
    logAction(source, 'teleport_to_player', tostring(targetId), nil)
end)

RegisterNetEvent('delfzijlrp_admin:server:bringPlayer', function(targetId)
    local source = source
    if not isStaff(source) then return end
    targetId = tonumber(targetId)
    if not targetId or not GetPlayerName(targetId) then
        notify(source, Config.Text.playerNotFound, 'error')
        return
    end
    local coords = GetEntityCoords(GetPlayerPed(source))
    TriggerClientEvent('delfzijlrp_admin:client:teleport', targetId, coords)
    logAction(source, 'bring_player', tostring(targetId), nil)
end)

RegisterNetEvent('delfzijlrp_admin:server:healPlayer', function(targetId)
    local source = source
    if not isStaff(source) then return end
    targetId = tonumber(targetId)
    if not targetId or not GetPlayerName(targetId) then return end
    TriggerClientEvent('delfzijlrp_admin:client:heal', targetId)
    logAction(source, 'heal_player', tostring(targetId), nil)
end)

RegisterNetEvent('delfzijlrp_admin:server:revivePlayer', function(targetId)
    local source = source
    if not isStaff(source) then return end
    targetId = tonumber(targetId)
    if not targetId or not GetPlayerName(targetId) then return end
    TriggerClientEvent('esx_ambulancejob:revive', targetId)
    logAction(source, 'revive_player', tostring(targetId), nil)
end)

RegisterNetEvent('delfzijlrp_admin:server:freezePlayer', function(targetId)
    local source = source
    if not isStaff(source) then return end
    targetId = tonumber(targetId)
    if not targetId or not GetPlayerName(targetId) then return end
    frozenPlayers[targetId] = not frozenPlayers[targetId]
    TriggerClientEvent('delfzijlrp_admin:client:setFrozen', targetId, frozenPlayers[targetId])
    logAction(source, 'freeze_player_toggle', tostring(targetId), tostring(frozenPlayers[targetId]))
    notify(source, Config.Text.frozen, 'success')
end)
