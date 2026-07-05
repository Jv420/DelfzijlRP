local ESX = exports['es_extended']:getSharedObject()

local function trimPlate(plate)
    return plate and plate:gsub('^%s*(.-)%s*$', '%1'):upper() or ''
end

lib.callback.register('delfzijlrp_v2_vehiclelock:server:hasKey', function(source, plate)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end
    plate = trimPlate(plate)
    if plate == '' then return false end

    local key = MySQL.scalar.await('SELECT id FROM delfzijlrp_vehicle_keys WHERE plate = ? AND identifier = ? LIMIT 1', {
        plate,
        xPlayer.identifier
    })
    if key then return true end

    local owner = MySQL.scalar.await('SELECT owner FROM owned_vehicles WHERE plate = ? LIMIT 1', { plate })
    return owner == xPlayer.identifier
end)
