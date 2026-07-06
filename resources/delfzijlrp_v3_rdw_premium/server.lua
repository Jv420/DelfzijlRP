local ESX = exports['es_extended']:getSharedObject()

local function notify(src, text, kind)
    TriggerClientEvent('ox_lib:notify', src, { title = 'RDW Premium', description = text, type = kind or 'inform' })
end

CreateThread(function()
    MySQL.query.await([[CREATE TABLE IF NOT EXISTS delfzijlrp_rdw_premium (
        plate varchar(16) NOT NULL,
        owner_identifier varchar(64) NOT NULL,
        owner_name varchar(128) NOT NULL,
        citizen_id varchar(32) DEFAULT NULL,
        vin varchar(64) NOT NULL,
        model varchar(64) DEFAULT NULL,
        apk_until date DEFAULT NULL,
        policy varchar(32) DEFAULT 'WA',
        mileage int NOT NULL DEFAULT 0,
        status varchar(32) NOT NULL DEFAULT 'active',
        tracker tinyint NOT NULL DEFAULT 0,
        created_at timestamp NOT NULL DEFAULT current_timestamp(),
        updated_at timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
        PRIMARY KEY(plate),
        UNIQUE KEY vin (vin)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]])

    MySQL.query.await([[CREATE TABLE IF NOT EXISTS delfzijlrp_rdw_history (
        id int NOT NULL AUTO_INCREMENT,
        plate varchar(16) NOT NULL,
        action varchar(64) NOT NULL,
        details text NULL,
        created_by varchar(128) DEFAULT NULL,
        created_at timestamp NOT NULL DEFAULT current_timestamp(),
        PRIMARY KEY(id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]])
end)

local function cleanPlate(plate)
    return tostring(plate or ''):upper():gsub('%s+', '')
end

local function makeVin()
    return 'DRPVIN' .. os.time() .. math.random(1000, 9999)
end

local function addHistory(plate, action, details, by)
    MySQL.insert.await('INSERT INTO delfzijlrp_rdw_history (plate, action, details, created_by) VALUES (?, ?, ?, ?)', {
        cleanPlate(plate), action or 'note', details or '', by or 'system'
    })
end

local function getVehicle(plate)
    plate = cleanPlate(plate)
    if plate == '' then return nil end
    return MySQL.single.await('SELECT * FROM delfzijlrp_rdw_premium WHERE plate = ? LIMIT 1', { plate })
end

local function registerVehicle(src, plate, model)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return nil end
    plate = cleanPlate(plate)
    if plate == '' then notify(src, Config.Text.invalid, 'error') return nil end

    local exists = getVehicle(plate)
    if exists then return exists end

    local identity = exports['delfzijlrp_v3_identity_engine']:EnsureIdentity(src)
    local core = exports['delfzijlrp_v3_core']:EnsureProfile(src)
    local date = os.date('%Y-%m-%d', os.time() + ((Config.DefaultApkDays or 30) * 86400))
    local vin = makeVin()

    MySQL.insert.await('INSERT INTO delfzijlrp_rdw_premium (plate, owner_identifier, owner_name, citizen_id, vin, model, apk_until, policy, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)', {
        plate, xPlayer.identifier, identity and identity.display_name or GetPlayerName(src), core and core.citizen_id or nil, vin, model or 'unknown', date, Config.DefaultInsurance or 'WA', 'active'
    })

    addHistory(plate, 'register', 'Voertuig geregistreerd', GetPlayerName(src))
    exports['delfzijlrp_v3_core']:AddLog(xPlayer.identifier, GetPlayerName(src), 'rdw_register', plate)
    notify(src, Config.Text.registered, 'success')
    return getVehicle(plate)
end

lib.callback.register('delfzijlrp_v3_rdw_premium:server:searchPlate', function(source, plate)
    local vehicle = getVehicle(plate)
    if not vehicle then return nil end
    vehicle.history = MySQL.query.await('SELECT action, details, created_by, created_at FROM delfzijlrp_rdw_history WHERE plate = ? ORDER BY id DESC LIMIT 10', { vehicle.plate }) or {}
    return vehicle
end)

RegisterNetEvent('delfzijlrp_v3_rdw_premium:server:registerMine', function(plate, model)
    registerVehicle(source, plate, model)
end)

RegisterNetEvent('delfzijlrp_v3_rdw_premium:server:setApk', function(plate, days)
    local src = source
    plate = cleanPlate(plate)
    days = tonumber(days) or Config.DefaultApkDays or 30
    local date = os.date('%Y-%m-%d', os.time() + (days * 86400))
    MySQL.update.await('UPDATE delfzijlrp_rdw_premium SET apk_until = ? WHERE plate = ?', { date, plate })
    addHistory(plate, 'apk_update', 'APK tot ' .. date, GetPlayerName(src))
    notify(src, Config.Text.updated, 'success')
end)

exports('GetVehicle', function(plate) return getVehicle(plate) end)
exports('RegisterVehicle', function(source, plate, model) return registerVehicle(source, plate, model) end)
exports('AddHistory', function(plate, action, details, by) addHistory(plate, action, details, by) end)
