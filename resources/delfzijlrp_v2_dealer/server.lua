local ESX = exports['es_extended']:getSharedObject()

local function getVehicle(model)
    for _, vehicle in ipairs(Config.Vehicles) do
        if vehicle.model == model then return vehicle end
    end
    return nil
end

local function pay(xPlayer, amount)
    if xPlayer.getMoney() >= amount then
        xPlayer.removeMoney(amount)
        return true
    end
    local bank = xPlayer.getAccount('bank')
    if bank and bank.money >= amount then
        xPlayer.removeAccountMoney('bank', amount)
        return true
    end
    return false
end

local function notify(source, message, type)
    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Delfzijl Dealer',
        description = message,
        type = type or 'inform'
    })
end

local function registerOwnership(source, xPlayer, plate, model, label, props)
    local vin = ('DRP%s%s'):format(os.time(), math.random(1000, 9999))
    local encoded = json.encode(props)

    MySQL.insert.await('INSERT INTO owned_vehicles (owner, plate, vehicle, type, stored) VALUES (?, ?, ?, ?, ?)', {
        xPlayer.identifier, plate, encoded, 'car', 0
    })

    MySQL.insert.await('INSERT INTO delfzijlrp_garage_states (plate, owner, garage_id, stored, impounded, vehicle_props) VALUES (?, ?, ?, ?, ?, ?)', {
        plate, xPlayer.identifier, 'centrum', 0, 0, encoded
    })

    MySQL.insert.await('INSERT INTO delfzijlrp_rdw_registry (plate, owner, owner_name, vin, model, vehicle_props, insurance_type, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
        plate, xPlayer.identifier, GetPlayerName(source), vin, label, encoded, 'none', 'active'
    })

    MySQL.insert.await('INSERT INTO delfzijlrp_vehicle_registry (plate, owner, vin, model, brand, color, insurance_type, stolen, impounded) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)', {
        plate, xPlayer.identifier, vin, model, 'Delfzijl Dealer', 'unknown', 'WA', 0, 0
    })

    MySQL.insert.await('INSERT INTO delfzijlrp_vehicle_keys (plate, identifier, key_type) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE key_type = VALUES(key_type)', {
        plate, xPlayer.identifier, 'owner'
    })
end

lib.callback.register('delfzijlrp_v2_dealer:server:getVehicles', function()
    return Config.Vehicles
end)

lib.callback.register('delfzijlrp_v2_dealer:server:buyVehicle', function(source, model, props)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false, Config.Text.invalid end

    local vehicle = getVehicle(model)
    if not vehicle then return false, Config.Text.invalid end
    if not pay(xPlayer, vehicle.price) then return false, Config.Text.noMoney end

    local plate = exports['delfzijlrp_rdw']:GeneratePlate()
    props = props or {}
    props.model = joaat(model)
    props.plate = plate

    registerOwnership(source, xPlayer, plate, model, vehicle.label, props)

    notify(source, Config.Text.bought .. ' Kenteken: ' .. plate .. ' | Sleutels ontvangen.', 'success')
    return true, { plate = plate, props = props, label = vehicle.label }
end)
