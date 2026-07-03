local ESX = exports['es_extended']:getSharedObject()
local trackedVehicles = {}

local function trimPlate(plate)
    return plate and plate:gsub('^%s*(.-)%s*$', '%1') or ''
end

local function getIdentifier(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    return xPlayer and xPlayer.identifier or nil
end

lib.callback.register('delfzijlrp_garages:server:getOwnedVehicles', function(source)
    local identifier = getIdentifier(source)
    if not identifier then return {} end

    local result = MySQL.query.await('SELECT plate, vehicle, stored FROM owned_vehicles WHERE owner = ?', { identifier }) or {}
    local vehicles = {}

    for _, row in ipairs(result) do
        vehicles[#vehicles + 1] = {
            plate = trimPlate(row.plate),
            vehicle = json.decode(row.vehicle),
            stored = tonumber(row.stored) or 0
        }
    end

    return vehicles
end)

lib.callback.register('delfzijlrp_garages:server:isVehicleOwner', function(source, plate)
    local identifier = getIdentifier(source)
    if not identifier then return false end

    plate = trimPlate(plate)
    local owner = MySQL.scalar.await('SELECT owner FROM owned_vehicles WHERE plate = ? LIMIT 1', { plate })
    return owner == identifier
end)

lib.callback.register('delfzijlrp_garages:server:storeVehicle', function(source, plate, props)
    local identifier = getIdentifier(source)
    if not identifier then return false end

    plate = trimPlate(plate)
    local owner = MySQL.scalar.await('SELECT owner FROM owned_vehicles WHERE plate = ? LIMIT 1', { plate })
    if owner ~= identifier then return false end

    MySQL.update.await('UPDATE owned_vehicles SET vehicle = ?, stored = 1 WHERE plate = ? AND owner = ?', {
        json.encode(props),
        plate,
        identifier
    })

    trackedVehicles[plate] = nil
    return true
end)

RegisterNetEvent('delfzijlrp_garages:server:setVehicleState', function(plate, state)
    local source = source
    local identifier = getIdentifier(source)
    if not identifier then return end

    plate = trimPlate(plate)
    MySQL.update.await('UPDATE owned_vehicles SET stored = ? WHERE plate = ? AND owner = ?', {
        tonumber(state) or 0,
        plate,
        identifier
    })
end)

RegisterNetEvent('delfzijlrp_garages:server:trackVehicle', function(plate)
    local source = source
    local identifier = getIdentifier(source)
    if not identifier then return end

    plate = trimPlate(plate)
    local owner = MySQL.scalar.await('SELECT owner FROM owned_vehicles WHERE plate = ? LIMIT 1', { plate })
    if owner ~= identifier then return end

    local coords = trackedVehicles[plate]
    TriggerClientEvent('delfzijlrp_garages:client:setTracker', source, coords, plate)
end)

RegisterNetEvent('delfzijlrp_garages:server:updateVehicleLocation', function(plate, coords)
    local source = source
    local identifier = getIdentifier(source)
    if not identifier then return end

    plate = trimPlate(plate)
    local owner = MySQL.scalar.await('SELECT owner FROM owned_vehicles WHERE plate = ? LIMIT 1', { plate })
    if owner ~= identifier then return end

    trackedVehicles[plate] = coords
end)
