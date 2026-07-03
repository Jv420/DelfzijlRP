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
        title = 'Delfzijl RP Taxi',
        description = message,
        type = type or 'inform'
    })
end

local function isTaxi(source)
    local xPlayer = getPlayer(source)
    return xPlayer and xPlayer.job and xPlayer.job.name == Config.JobName
end

local function payCustomer(targetId, amount)
    local xPlayer = getPlayer(targetId)
    if not xPlayer then return false end

    if xPlayer.getMoney() >= amount then
        xPlayer.removeMoney(amount)
        return true
    end

    if xPlayer.getAccount('bank').money >= amount then
        xPlayer.removeAccountMoney('bank', amount)
        return true
    end

    return false
end

local function addRide(driverSource, customerSource, rideType, distanceKm, fare)
    local driver = getPlayer(driverSource)
    local customer = customerSource and getPlayer(customerSource) or nil

    MySQL.insert.await([[INSERT INTO delfzijlrp_taxi_rides
        (driver_identifier, driver_name, customer_identifier, customer_name, ride_type, distance_km, fare)
        VALUES (?, ?, ?, ?, ?, ?, ?)]], {
        driver and driver.identifier or nil,
        GetPlayerName(driverSource),
        customer and customer.identifier or nil,
        customerSource and GetPlayerName(customerSource) or 'NPC klant',
        rideType,
        distanceKm or 0,
        fare or 0
    })
end

lib.callback.register('delfzijlrp_taxi:server:isTaxi', function(source)
    return isTaxi(source)
end)

lib.callback.register('delfzijlrp_taxi:server:getStats', function(source)
    local identifier = getIdentifier(source)
    if not identifier then return nil end

    return MySQL.single.await([[SELECT COUNT(*) as rides, COALESCE(SUM(fare), 0) as earned
        FROM delfzijlrp_taxi_rides WHERE driver_identifier = ?]], { identifier })
end)

RegisterNetEvent('delfzijlrp_taxi:server:toggleDuty', function()
    local source = source
    local identifier = getIdentifier(source)
    if not identifier or not isTaxi(source) then return end

    local current = MySQL.scalar.await('SELECT on_duty FROM delfzijlrp_taxi_duty WHERE identifier = ? LIMIT 1', { identifier })
    local newState = current == 1 and 0 or 1

    MySQL.insert.await([[INSERT INTO delfzijlrp_taxi_duty (identifier, on_duty) VALUES (?, ?)
        ON DUPLICATE KEY UPDATE on_duty = VALUES(on_duty)]], { identifier, newState })

    notify(source, newState == 1 and Config.Text.dutyOn or Config.Text.dutyOff, 'success')
end)

RegisterNetEvent('delfzijlrp_taxi:server:chargeRide', function(targetId, distanceKm, fare)
    local source = source
    if not isTaxi(source) then return end

    targetId = tonumber(targetId)
    distanceKm = tonumber(distanceKm) or 0
    fare = tonumber(fare) or 0

    if not targetId or not GetPlayerName(targetId) or fare <= 0 then
        notify(source, Config.Text.invalidInput, 'error')
        return
    end

    if not payCustomer(targetId, fare) then
        notify(source, 'Klant heeft niet genoeg geld.', 'error')
        return
    end

    local xPlayer = getPlayer(source)
    if xPlayer then
        xPlayer.addAccountMoney('bank', fare)
    end

    addRide(source, targetId, 'player', distanceKm, fare)
    notify(source, Config.Text.fareCharged, 'success')
    notify(targetId, ('Taxirit betaald: €%s'):format(fare), 'success')
end)

RegisterNetEvent('delfzijlrp_taxi:server:completeNpcRide', function(distanceKm, payout)
    local source = source
    if not isTaxi(source) then return end
    payout = tonumber(payout) or 0
    distanceKm = tonumber(distanceKm) or 0
    if payout <= 0 then return end

    local xPlayer = getPlayer(source)
    if xPlayer then
        xPlayer.addAccountMoney('bank', payout)
    end

    addRide(source, nil, 'npc', distanceKm, payout)
    notify(source, Config.Text.routeCompleted, 'success')
end)
