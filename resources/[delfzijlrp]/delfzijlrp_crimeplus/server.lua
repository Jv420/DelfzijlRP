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
        title = 'Delfzijl RP CrimePlus',
        description = message,
        type = type or 'inform'
    })
end

local function countPolice()
    local count = 0
    local players = ESX.GetExtendedPlayers('job', 'police')
    for _, _ in pairs(players) do count += 1 end
    return count
end

local function getIncidentConfig(incidentType)
    return Config.Incidents[incidentType]
end

local function getCooldown(locationId)
    local expires = MySQL.scalar.await('SELECT expires_at FROM delfzijlrp_crimeplus_cooldowns WHERE location_id = ? LIMIT 1', { locationId })
    return tonumber(expires) or 0
end

local function setCooldown(locationId, seconds)
    local expires = os.time() + seconds
    MySQL.insert.await([[INSERT INTO delfzijlrp_crimeplus_cooldowns (location_id, expires_at)
        VALUES (?, ?)
        ON DUPLICATE KEY UPDATE expires_at = VALUES(expires_at)]], { locationId, expires })
end

local function sendDispatch(source, incident, coords)
    if math.random(1, 100) > Config.DispatchChance then return end
    local message = ('%s gemeld in de omgeving.'):format(incident.label)
    TriggerEvent('delfzijlrp_dispatch:server:createReport', incident.dispatchType or 'emergency', message, coords)
end

lib.callback.register('delfzijlrp_crimeplus:server:canStart', function(source, incidentType, locationId)
    local incident = getIncidentConfig(incidentType)
    if not incident then return false, Config.Text.failed end

    if countPolice() < Config.RequiredPolice then
        return false, Config.Text.notEnoughPolice
    end

    local hasTool = (exports.ox_inventory:GetItemCount(source, incident.requiredTool) or 0) > 0
    if not hasTool then
        return false, Config.Text.noTool
    end

    local expires = getCooldown(locationId)
    if expires > os.time() then
        return false, Config.Text.cooldown
    end

    return true, nil
end)

RegisterNetEvent('delfzijlrp_crimeplus:server:completeIncident', function(incidentType, locationId, coords)
    local source = source
    local xPlayer = getPlayer(source)
    local identifier = getIdentifier(source)
    local incident = getIncidentConfig(incidentType)
    if not xPlayer or not incident or not locationId then return end

    local canStart, reason = lib.callback.await('delfzijlrp_crimeplus:server:canStart', source, incidentType, locationId)
    if not canStart then
        notify(source, reason or Config.Text.failed, 'error')
        return
    end

    setCooldown(locationId, incident.cooldown or Config.GlobalCooldown)
    sendDispatch(source, incident, coords)

    local rewardText = ''
    if incident.reward then
        local amount = math.random(incident.reward.min, incident.reward.max)
        xPlayer.addAccountMoney(incident.reward.account or 'black_money', amount)
        rewardText = ('%s:%s'):format(incident.reward.account or 'black_money', amount)
    end

    if incident.rewardItems then
        local rewards = {}
        for _, reward in ipairs(incident.rewardItems) do
            local amount = math.random(reward.min, reward.max)
            exports.ox_inventory:AddItem(source, reward.item, amount)
            rewards[#rewards + 1] = reward.item .. ':' .. amount
        end
        rewardText = table.concat(rewards, ',')
    end

    MySQL.insert.await('INSERT INTO delfzijlrp_crimeplus_logs (identifier, incident_type, location_id, reward, coords) VALUES (?, ?, ?, ?, ?)', {
        identifier,
        incidentType,
        locationId,
        rewardText,
        json.encode(coords)
    })

    notify(source, Config.Text.success, 'success')
end)
