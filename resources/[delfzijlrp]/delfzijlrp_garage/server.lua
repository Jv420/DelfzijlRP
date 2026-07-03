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
        title = 'Delfzijl RP Garage',
        description = message,
        type = type or 'inform'
    })
end

local function trimPlate(plate)
    return plate and plate:gsub('^%s*(.-)%s*$', '%1') or ''
end

local function isPolice(source)
    local xPlayer = getPlayer(source)
    return xPlayer and xPlayer.job and xPlayer.job.name == 'police'
end

local function pay(source, amount)
    local xPlayer = getPlayer(source)
    if not xPlayer then return false end
    if xPlayer.getMoney() >= amount then xPlayer.removeMoney(amount) return true end
    if xPlayer.getAccount('bank').money >= amount then xPlayer.removeAccountMoney('bank', amount) return true end
    return false
end

local function ensureState(plate, owner, garageId, props)
    MySQL.insert.await([[INSERT INTO delfzijlrp_garage_states (plate, owner, garage_id, stored, impounded, vehicle_props)
        VALUES (?, ?, ?, 1, 0, ?)
        ON DUPLICATE KEY UPDATE owner = VALUES(owner)]], { plate, owner, garageId, props })
end

lib.callback.register('delfzijlrp_garage:server:getVehicles', function(source, garageId, impoundOnly)
    local identifier = getIdentifier(source)
    if not identifier then return {} end

    local owned = MySQL.query.await('SELECT * FROM owned_vehicles WHERE owner = ?', { identifier }) or {}
    for _, row in ipairs(owned) do
        local plate = trimPlate(row.plate)
        ensureState(plate, identifier, garageId, row.vehicle)
    end

    if impoundOnly then
        return MySQL.query.await([[SELECT s.*, r.model, r.brand, r.vin
            FROM delfzijlrp_garage_states s
            LEFT JOIN delfzijlrp_vehicle_registry r ON r.plate = s.plate
            WHERE s.owner = ? AND s.impounded = 1
            ORDER BY s.updated_at DESC]], { identifier }) or {}
    end

    return MySQL.query.await([[SELECT s.*, r.model, r.brand, r.vin
        FROM delfzijlrp_garage_states s
        LEFT JOIN delfzijlrp_vehicle_registry r ON r.plate = s.plate
        WHERE s.owner = ? AND s.impounded = 0
        ORDER BY s.updated_at DESC]], { identifier }) or {}
end)

lib.callback.register('delfzijlrp_garage:server:takeOut', function(source, plate, impound)
    local identifier = getIdentifier(source)
    if not identifier then return false, Config.Text.notOwner end

    plate = trimPlate(plate)
    local state = MySQL.single.await('SELECT * FROM delfzijlrp_garage_states WHERE plate = ? AND owner = ? LIMIT 1', { plate, identifier })
    if not state then return false, Config.Text.notOwner end
    if state.stored == 0 and state.impounded == 0 then return false, Config.Text.alreadyOut end

    if impound and state.impounded == 1 then
        if not pay(source, Config.Impound.price) then
            return false, Config.Text.noMoney
        end
    end

    MySQL.update.await('UPDATE delfzijlrp_garage_states SET stored = 0, impounded = 0 WHERE plate = ?', { plate })
    MySQL.update.await('UPDATE delfzijlrp_vehicle_registry SET impounded = 0 WHERE plate = ?', { plate })
    return true, state.vehicle_props
end)

RegisterNetEvent('delfzijlrp_garage:server:storeVehicle', function(plate, garageId, props)
    local source = source
    local identifier = getIdentifier(source)
    if not identifier then return end

    plate = trimPlate(plate)
    local owner = MySQL.scalar.await('SELECT owner FROM owned_vehicles WHERE plate = ? LIMIT 1', { plate })
    if owner ~= identifier then
        notify(source, Config.Text.notOwner, 'error')
        return
    end

    local encoded = type(props) == 'table' and json.encode(props) or props
    MySQL.insert.await([[INSERT INTO delfzijlrp_garage_states (plate, owner, garage_id, stored, impounded, vehicle_props)
        VALUES (?, ?, ?, 1, 0, ?)
        ON DUPLICATE KEY UPDATE garage_id = VALUES(garage_id), stored = 1, impounded = 0, vehicle_props = VALUES(vehicle_props)]], {
        plate,
        identifier,
        garageId,
        encoded
    })

    MySQL.update.await('UPDATE owned_vehicles SET vehicle = ? WHERE plate = ? AND owner = ?', { encoded, plate, identifier })
    notify(source, Config.Text.stored, 'success')
end)

RegisterNetEvent('delfzijlrp_garage:server:impoundVehicle', function(plate, props)
    local source = source
    if not isPolice(source) then return end

    plate = trimPlate(plate)
    local owner = MySQL.scalar.await('SELECT owner FROM owned_vehicles WHERE plate = ? LIMIT 1', { plate })
    if not owner then
        notify(source, Config.Text.notOwner, 'error')
        return
    end

    local encoded = type(props) == 'table' and json.encode(props) or props
    MySQL.insert.await([[INSERT INTO delfzijlrp_garage_states (plate, owner, garage_id, stored, impounded, vehicle_props)
        VALUES (?, ?, ?, 1, 1, ?)
        ON DUPLICATE KEY UPDATE stored = 1, impounded = 1, vehicle_props = VALUES(vehicle_props)]], {
        plate,
        owner,
        'impound',
        encoded
    })
    MySQL.update.await('UPDATE delfzijlrp_vehicle_registry SET impounded = 1 WHERE plate = ?', { plate })
    notify(source, Config.Text.impounded, 'success')
end)
