local ESX = exports['es_extended']:getSharedObject()

CreateThread(function()
    MySQL.query.await([[CREATE TABLE IF NOT EXISTS delfzijlrp_vehicle_ecosystem (
        plate varchar(16) NOT NULL,
        value int NOT NULL DEFAULT 15000,
        condition_score int NOT NULL DEFAULT 100,
        service_score int NOT NULL DEFAULT 100,
        tracker_enabled tinyint NOT NULL DEFAULT 0,
        keys_enabled tinyint NOT NULL DEFAULT 1,
        last_garage varchar(64) DEFAULT NULL,
        last_location longtext NULL,
        damage_json longtext NULL,
        notes text NULL,
        created_at timestamp NOT NULL DEFAULT current_timestamp(),
        updated_at timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
        PRIMARY KEY(plate)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]])

    MySQL.query.await([[CREATE TABLE IF NOT EXISTS delfzijlrp_vehicle_eco_history (
        id int NOT NULL AUTO_INCREMENT,
        plate varchar(16) NOT NULL,
        action varchar(64) NOT NULL,
        details text NULL,
        created_by varchar(128) DEFAULT NULL,
        created_at timestamp NOT NULL DEFAULT current_timestamp(),
        PRIMARY KEY(id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]])
end)

local function clean(plate)
    return tostring(plate or ''):upper():gsub('%s+', '')
end

local function addHistory(plate, action, details, by)
    MySQL.insert.await('INSERT INTO delfzijlrp_vehicle_eco_history (plate, action, details, created_by) VALUES (?, ?, ?, ?)', {
        clean(plate), action or 'note', details or '', by or 'system'
    })
end

local function getProfile(plate)
    plate = clean(plate)
    if plate == '' then return nil end
    return MySQL.single.await('SELECT * FROM delfzijlrp_vehicle_ecosystem WHERE plate = ? LIMIT 1', { plate })
end

local function ensureProfile(plate, by)
    plate = clean(plate)
    if plate == '' then return nil end
    local profile = getProfile(plate)
    if profile then return profile end
    MySQL.insert.await('INSERT INTO delfzijlrp_vehicle_ecosystem (plate, value, condition_score, service_score, damage_json) VALUES (?, ?, ?, ?, ?)', {
        plate, Config.DefaultValue, Config.DefaultCondition, Config.DefaultService, json.encode({})
    })
    addHistory(plate, 'created', 'Eco profiel aangemaakt', by or 'system')
    return getProfile(plate)
end

lib.callback.register('delfzijlrp_v3_veh_eco:server:get', function(source, plate)
    local profile = ensureProfile(plate, GetPlayerName(source))
    if not profile then return nil end
    profile.rdw = exports['delfzijlrp_v3_rdw_premium']:GetVehicle(profile.plate)
    profile.history = MySQL.query.await('SELECT action, details, created_by, created_at FROM delfzijlrp_vehicle_eco_history WHERE plate = ? ORDER BY id DESC LIMIT 10', { profile.plate }) or {}
    return profile
end)

RegisterNetEvent('delfzijlrp_v3_veh_eco:server:updateScores', function(plate, condition, service)
    local src = source
    plate = clean(plate)
    condition = math.max(0, math.min(100, tonumber(condition) or Config.DefaultCondition))
    service = math.max(0, math.min(100, tonumber(service) or Config.DefaultService))
    ensureProfile(plate, GetPlayerName(src))
    MySQL.update.await('UPDATE delfzijlrp_vehicle_ecosystem SET condition_score = ?, service_score = ? WHERE plate = ?', { condition, service, plate })
    addHistory(plate, 'scores', 'Conditie ' .. condition .. ' service ' .. service, GetPlayerName(src))
    TriggerClientEvent('ox_lib:notify', src, { title = 'Vehicle Ecosystem', description = Config.Text.updated, type = 'success' })
end)

RegisterNetEvent('delfzijlrp_v3_veh_eco:server:setTracker', function(plate, enabled)
    local src = source
    plate = clean(plate)
    ensureProfile(plate, GetPlayerName(src))
    MySQL.update.await('UPDATE delfzijlrp_vehicle_ecosystem SET tracker_enabled = ? WHERE plate = ?', { enabled and 1 or 0, plate })
    addHistory(plate, 'tracker', enabled and 'aan' or 'uit', GetPlayerName(src))
end)

exports('EnsureProfile', function(plate, by) return ensureProfile(plate, by) end)
exports('GetProfile', function(plate) return getProfile(plate) end)
exports('AddHistory', function(plate, action, details, by) addHistory(plate, action, details, by) end)
