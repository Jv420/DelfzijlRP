local ESX = exports['es_extended']:getSharedObject()

local function notify(src, text, kind)
    TriggerClientEvent('ox_lib:notify', src, { title = 'DRP Core', description = text, type = kind or 'inform' })
end

CreateThread(function()
    MySQL.query.await([[CREATE TABLE IF NOT EXISTS delfzijlrp_core_profiles (
        identifier varchar(64) NOT NULL,
        citizen_id varchar(32) NOT NULL,
        player_name varchar(128) NOT NULL,
        reputation int NOT NULL DEFAULT 0,
        trust_score int NOT NULL DEFAULT 50,
        flags longtext NULL,
        created_at timestamp NOT NULL DEFAULT current_timestamp(),
        updated_at timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
        PRIMARY KEY(identifier),
        UNIQUE KEY citizen_id (citizen_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]])

    MySQL.query.await([[CREATE TABLE IF NOT EXISTS delfzijlrp_core_logs (
        id int NOT NULL AUTO_INCREMENT,
        identifier varchar(64) DEFAULT NULL,
        player_name varchar(128) DEFAULT NULL,
        action varchar(64) NOT NULL,
        details text NULL,
        created_at timestamp NOT NULL DEFAULT current_timestamp(),
        PRIMARY KEY(id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]])
end)

local function makeCitizenId()
    return Config.Profile.citizenPrefix .. '-' .. math.random(100000, 999999)
end

local function log(identifier, name, action, details)
    MySQL.insert.await('INSERT INTO delfzijlrp_core_logs (identifier, player_name, action, details) VALUES (?, ?, ?, ?)', {
        identifier, name, action, details or ''
    })
end

local function getProfileByIdentifier(identifier)
    return MySQL.single.await('SELECT * FROM delfzijlrp_core_profiles WHERE identifier = ? LIMIT 1', { identifier })
end

local function ensureProfile(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return nil end
    local profile = getProfileByIdentifier(xPlayer.identifier)
    if profile then return profile end

    local citizenId = makeCitizenId()
    MySQL.insert.await('INSERT INTO delfzijlrp_core_profiles (identifier, citizen_id, player_name, reputation, trust_score, flags) VALUES (?, ?, ?, ?, ?, ?)', {
        xPlayer.identifier,
        citizenId,
        GetPlayerName(src),
        Config.Profile.startReputation,
        Config.Profile.startTrust,
        json.encode({})
    })
    log(xPlayer.identifier, GetPlayerName(src), 'profile_created', citizenId)
    notify(src, Config.Text.profileCreated, 'success')
    return getProfileByIdentifier(xPlayer.identifier)
end

AddEventHandler('esx:playerLoaded', function(playerId)
    ensureProfile(playerId)
end)

lib.callback.register('delfzijlrp_v3_core:server:getProfile', function(source)
    return ensureProfile(source)
end)

RegisterNetEvent('delfzijlrp_v3_core:server:ensureProfile', function()
    ensureProfile(source)
end)

exports('GetProfile', function(identifier)
    return getProfileByIdentifier(identifier)
end)

exports('EnsureProfile', function(source)
    return ensureProfile(source)
end)

exports('AddLog', function(identifier, playerName, action, details)
    log(identifier, playerName, action, details)
end)

exports('AddReputation', function(identifier, amount, reason)
    amount = tonumber(amount) or 0
    MySQL.update.await('UPDATE delfzijlrp_core_profiles SET reputation = reputation + ? WHERE identifier = ?', { amount, identifier })
    log(identifier, nil, 'reputation', tostring(amount) .. ' | ' .. tostring(reason or ''))
end)

exports('SetTrust', function(identifier, value, reason)
    value = math.max(0, math.min(100, tonumber(value) or 50))
    MySQL.update.await('UPDATE delfzijlrp_core_profiles SET trust_score = ? WHERE identifier = ?', { value, identifier })
    log(identifier, nil, 'trust_set', tostring(value) .. ' | ' .. tostring(reason or ''))
end)
