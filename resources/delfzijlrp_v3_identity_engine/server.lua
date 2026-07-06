local ESX = exports['es_extended']:getSharedObject()

local function notify(src, text, kind)
    TriggerClientEvent('ox_lib:notify', src, { title = 'Identity Engine', description = text, type = kind or 'inform' })
end

CreateThread(function()
    MySQL.query.await([[CREATE TABLE IF NOT EXISTS delfzijlrp_identity_profiles (
        identifier varchar(64) NOT NULL,
        citizen_id varchar(32) DEFAULT NULL,
        display_name varchar(128) NOT NULL,
        phone_number varchar(32) DEFAULT NULL,
        address varchar(128) DEFAULT NULL,
        photo_url text NULL,
        driving_categories longtext NULL,
        document_history longtext NULL,
        created_at timestamp NOT NULL DEFAULT current_timestamp(),
        updated_at timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
        PRIMARY KEY(identifier)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]])
end)

local function makePhone()
    return Config.PhonePrefix .. math.random(10000000, 99999999)
end

local function ensureIdentity(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return nil end

    local row = MySQL.single.await('SELECT * FROM delfzijlrp_identity_profiles WHERE identifier = ? LIMIT 1', { xPlayer.identifier })
    if row then return row end

    local core = exports['delfzijlrp_v3_core']:EnsureProfile(src)
    local citizenId = core and core.citizen_id or nil

    MySQL.insert.await('INSERT INTO delfzijlrp_identity_profiles (identifier, citizen_id, display_name, phone_number, address, driving_categories, document_history) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        xPlayer.identifier,
        citizenId,
        GetPlayerName(src),
        makePhone(),
        Config.DefaultAddress,
        json.encode({ B = false, A = false, C = false, D = false }),
        json.encode({})
    })

    exports['delfzijlrp_v3_core']:AddLog(xPlayer.identifier, GetPlayerName(src), 'identity_created', citizenId or '')
    notify(src, Config.Text.created, 'success')
    return MySQL.single.await('SELECT * FROM delfzijlrp_identity_profiles WHERE identifier = ? LIMIT 1', { xPlayer.identifier })
end

AddEventHandler('esx:playerLoaded', function(playerId)
    ensureIdentity(playerId)
end)

lib.callback.register('delfzijlrp_v3_identity_engine:server:getMine', function(source)
    return ensureIdentity(source)
end)

RegisterNetEvent('delfzijlrp_v3_identity_engine:server:ensure', function()
    ensureIdentity(source)
end)

RegisterNetEvent('delfzijlrp_v3_identity_engine:server:setAddress', function(address)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    address = tostring(address or '')
    if address == '' then notify(src, Config.Text.invalid, 'error') return end
    ensureIdentity(src)
    MySQL.update.await('UPDATE delfzijlrp_identity_profiles SET address = ? WHERE identifier = ?', { address, xPlayer.identifier })
    exports['delfzijlrp_v3_core']:AddLog(xPlayer.identifier, GetPlayerName(src), 'identity_address', address)
    notify(src, Config.Text.updated, 'success')
end)

exports('EnsureIdentity', function(source)
    return ensureIdentity(source)
end)

exports('GetIdentity', function(identifier)
    return MySQL.single.await('SELECT * FROM delfzijlrp_identity_profiles WHERE identifier = ? LIMIT 1', { identifier })
end)

exports('SetDrivingCategory', function(identifier, category, value)
    local row = MySQL.single.await('SELECT driving_categories FROM delfzijlrp_identity_profiles WHERE identifier = ? LIMIT 1', { identifier })
    if not row then return false end
    local data = json.decode(row.driving_categories or '{}') or {}
    data[category] = value == true
    MySQL.update.await('UPDATE delfzijlrp_identity_profiles SET driving_categories = ? WHERE identifier = ?', { json.encode(data), identifier })
    return true
end)

exports('AddDocumentHistory', function(identifier, docType, docNumber)
    local row = MySQL.single.await('SELECT document_history FROM delfzijlrp_identity_profiles WHERE identifier = ? LIMIT 1', { identifier })
    if not row then return false end
    local data = json.decode(row.document_history or '[]') or {}
    data[#data + 1] = { type = docType, number = docNumber, date = os.date('%Y-%m-%d') }
    MySQL.update.await('UPDATE delfzijlrp_identity_profiles SET document_history = ? WHERE identifier = ?', { json.encode(data), identifier })
    return true
end)
