local ESX = exports['es_extended']:getSharedObject()

local function trimPlate(plate)
    return plate and plate:gsub('^%s*(.-)%s*$', '%1') or ''
end

local function getIdentifier(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    return xPlayer and xPlayer.identifier or nil
end

local function notify(source, message, type)
    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Delfzijl RP RDW',
        description = message,
        type = type or 'inform'
    })
end

local function createVin()
    local stamp = os.time()
    local random = math.random(100000, 999999)
    return ('%s%s%s'):format(Config.RDW.vinPrefix, stamp, random)
end

local function dateAddDays(days)
    return os.date('%Y-%m-%d %H:%M:%S', os.time() + (days * 86400))
end

local function hasServiceAccess(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or not xPlayer.job then return false end
    return Config.Keys.allowedServiceJobs[xPlayer.job.name] == true
end

exports('CreateRDWRecord', function(source, plate, vehicleData)
    local identifier = getIdentifier(source)
    if not identifier then return false end

    plate = trimPlate(plate)
    local existing = MySQL.scalar.await('SELECT plate FROM delfzijlrp_vehicle_registry WHERE plate = ? LIMIT 1', { plate })
    if existing then return true end

    local vin = createVin()
    MySQL.insert.await([[INSERT INTO delfzijlrp_vehicle_registry
        (plate, owner, vin, model, brand, color, mileage, apk_until, insurance_until, insurance_type)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)]], {
        plate,
        identifier,
        vin,
        vehicleData and vehicleData.model or nil,
        vehicleData and vehicleData.brand or nil,
        vehicleData and vehicleData.color or nil,
        0,
        dateAddDays(Config.RDW.defaultApkDays),
        dateAddDays(Config.RDW.defaultInsuranceDays),
        Config.RDW.defaultInsuranceType
    })

    MySQL.insert.await('INSERT IGNORE INTO delfzijlrp_vehicle_keys (plate, identifier, key_type) VALUES (?, ?, ?)', {
        plate,
        identifier,
        'owner'
    })

    return true
end)

exports('HasVehicleKey', function(source, plate)
    local identifier = getIdentifier(source)
    if not identifier then return false end
    plate = trimPlate(plate)

    if hasServiceAccess(source) then return true end

    local found = MySQL.scalar.await('SELECT id FROM delfzijlrp_vehicle_keys WHERE plate = ? AND identifier = ? LIMIT 1', { plate, identifier })
    return found ~= nil
end)

lib.callback.register('delfzijlrp_vehicles:server:getRDW', function(source, plate)
    plate = trimPlate(plate)
    return MySQL.single.await('SELECT * FROM delfzijlrp_vehicle_registry WHERE plate = ? LIMIT 1', { plate })
end)

lib.callback.register('delfzijlrp_vehicles:server:hasKey', function(source, plate)
    return exports[GetCurrentResourceName()]:HasVehicleKey(source, plate)
end)

RegisterNetEvent('delfzijlrp_vehicles:server:giveKey', function(targetId, plate)
    local source = source
    local identifier = getIdentifier(source)
    local target = ESX.GetPlayerFromId(tonumber(targetId))
    if not identifier or not target then
        notify(source, Config.Text.playerNotFound, 'error')
        return
    end

    plate = trimPlate(plate)
    local hasKey = exports[GetCurrentResourceName()]:HasVehicleKey(source, plate)
    if not hasKey then
        notify(source, Config.Text.noKeys, 'error')
        return
    end

    MySQL.insert.await('INSERT IGNORE INTO delfzijlrp_vehicle_keys (plate, identifier, key_type) VALUES (?, ?, ?)', {
        plate,
        target.identifier,
        'shared'
    })

    notify(source, Config.Text.keysGiven, 'success')
    notify(target.source, Config.Text.keysReceived, 'success')
end)

RegisterNetEvent('delfzijlrp_vehicles:server:transferVehicle', function(targetId, plate)
    local source = source
    local owner = getIdentifier(source)
    local target = ESX.GetPlayerFromId(tonumber(targetId))
    if not owner or not target then
        notify(source, Config.Text.playerNotFound, 'error')
        return
    end

    plate = trimPlate(plate)
    local currentOwner = MySQL.scalar.await('SELECT owner FROM delfzijlrp_vehicle_registry WHERE plate = ? LIMIT 1', { plate })
    if currentOwner ~= owner then
        notify(source, Config.Text.notOwner, 'error')
        return
    end

    MySQL.update.await('UPDATE owned_vehicles SET owner = ? WHERE plate = ? AND owner = ?', { target.identifier, plate, owner })
    MySQL.update.await('UPDATE delfzijlrp_vehicle_registry SET owner = ? WHERE plate = ?', { target.identifier, plate })
    MySQL.update.await('DELETE FROM delfzijlrp_vehicle_keys WHERE plate = ?', { plate })
    MySQL.insert.await('INSERT INTO delfzijlrp_vehicle_keys (plate, identifier, key_type) VALUES (?, ?, ?)', { plate, target.identifier, 'owner' })

    notify(source, Config.Text.transferred, 'success')
    notify(target.source, Config.Text.transferred, 'success')
end)

RegisterNetEvent('delfzijlrp_vehicles:server:renewApk', function(plate)
    local source = source
    if not hasServiceAccess(source) then return end
    plate = trimPlate(plate)

    MySQL.update.await('UPDATE delfzijlrp_vehicle_registry SET apk_until = ? WHERE plate = ?', {
        dateAddDays(Config.RDW.defaultApkDays),
        plate
    })
    notify(source, Config.Text.apkRenewed, 'success')
end)

RegisterNetEvent('delfzijlrp_vehicles:server:renewInsurance', function(plate, insuranceType)
    local source = source
    local identifier = getIdentifier(source)
    if not identifier then return end

    insuranceType = insuranceType or Config.RDW.defaultInsuranceType
    if not Config.InsuranceTypes[insuranceType] then insuranceType = Config.RDW.defaultInsuranceType end

    plate = trimPlate(plate)
    local owner = MySQL.scalar.await('SELECT owner FROM delfzijlrp_vehicle_registry WHERE plate = ? LIMIT 1', { plate })
    if owner ~= identifier then
        notify(source, Config.Text.notOwner, 'error')
        return
    end

    MySQL.update.await('UPDATE delfzijlrp_vehicle_registry SET insurance_until = ?, insurance_type = ? WHERE plate = ?', {
        dateAddDays(Config.RDW.defaultInsuranceDays),
        insuranceType,
        plate
    })
    notify(source, Config.Text.insuranceRenewed, 'success')
end)

RegisterNetEvent('delfzijlrp_vehicles:server:setStolen', function(plate, state)
    local source = source
    if not hasServiceAccess(source) then return end
    plate = trimPlate(plate)
    MySQL.update.await('UPDATE delfzijlrp_vehicle_registry SET stolen = ? WHERE plate = ?', { state and 1 or 0, plate })
    notify(source, Config.Text.stolenMarked, 'success')
end)

RegisterNetEvent('delfzijlrp_vehicles:server:addMileage', function(plate, amount)
    plate = trimPlate(plate)
    amount = tonumber(amount) or 0
    if amount <= 0 then return end
    MySQL.update.await('UPDATE delfzijlrp_vehicle_registry SET mileage = mileage + ? WHERE plate = ?', { math.floor(amount), plate })
end)
