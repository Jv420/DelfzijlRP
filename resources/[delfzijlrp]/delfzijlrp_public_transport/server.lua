local ESX = exports['es_extended']:getSharedObject()
local cooldowns = {}

local function getPlayer(source)
    return ESX.GetPlayerFromId(source)
end

local function getIdentifier(source)
    local xPlayer = getPlayer(source)
    return xPlayer and xPlayer.identifier or nil
end

local function notify(source, message, type)
    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Qbuzz Delfzijl',
        description = message,
        type = type or 'inform'
    })
end

local function isDriver(source)
    local xPlayer = getPlayer(source)
    return xPlayer and xPlayer.job and xPlayer.job.name == Config.JobName
end

local function getRoute(routeId)
    for _, route in ipairs(Config.Routes) do
        if route.id == routeId then return route end
    end
    return nil
end

local function pay(source, amount)
    local xPlayer = getPlayer(source)
    if not xPlayer then return false end
    if xPlayer.getMoney() >= amount then xPlayer.removeMoney(amount) return true end
    if xPlayer.getAccount('bank').money >= amount then xPlayer.removeAccountMoney('bank', amount) return true end
    return false
end

local function logBus(source, action, details)
    MySQL.insert.await('INSERT INTO delfzijlrp_bus_logs (identifier, action, details) VALUES (?, ?, ?)', {
        getIdentifier(source),
        action,
        details
    })
end

lib.callback.register('delfzijlrp_public_transport:server:isDriver', function(source)
    return isDriver(source)
end)

lib.callback.register('delfzijlrp_public_transport:server:getActiveRide', function(source)
    local identifier = getIdentifier(source)
    if not identifier then return nil end
    return MySQL.single.await('SELECT * FROM delfzijlrp_bus_rides WHERE driver_identifier = ? AND status = ? ORDER BY created_at DESC LIMIT 1', { identifier, 'active' })
end)

lib.callback.register('delfzijlrp_public_transport:server:getStats', function(source)
    local identifier = getIdentifier(source)
    if not identifier then return nil end
    return MySQL.single.await('SELECT COUNT(*) as rides, COALESCE(SUM(payout), 0) as earned FROM delfzijlrp_bus_rides WHERE driver_identifier = ? AND status = ?', { identifier, 'completed' })
end)

RegisterNetEvent('delfzijlrp_public_transport:server:buyTicket', function(ticketType)
    local source = source
    local identifier = getIdentifier(source)
    if not identifier then return end

    local price = ticketType == 'day' and Config.Ticket.dayPassPrice or Config.Ticket.price
    if not pay(source, price) then notify(source, Config.Text.noMoney, 'error') return end

    local expiresAt = ticketType == 'day' and os.date('%Y-%m-%d %H:%M:%S', os.time() + 86400) or os.date('%Y-%m-%d %H:%M:%S', os.time() + 3600)
    MySQL.insert.await('INSERT INTO delfzijlrp_bus_tickets (identifier, ticket_type, expires_at) VALUES (?, ?, ?)', { identifier, ticketType or 'single', expiresAt })
    exports.ox_inventory:AddItem(source, Config.Ticket.item, 1)
    logBus(source, 'buy_ticket', (ticketType or 'single') .. ':' .. price)
    notify(source, Config.Text.ticketBought, 'success')
end)

RegisterNetEvent('delfzijlrp_public_transport:server:startRoute', function(routeId)
    local source = source
    local identifier = getIdentifier(source)
    if not identifier or not isDriver(source) then notify(source, Config.Text.noAccess, 'error') return end

    if cooldowns[identifier] and cooldowns[identifier] > os.time() then notify(source, Config.Text.cooldown, 'error') return end
    if MySQL.scalar.await('SELECT id FROM delfzijlrp_bus_rides WHERE driver_identifier = ? AND status = ? LIMIT 1', { identifier, 'active' }) then
        notify(source, 'Je hebt al een actieve busroute.', 'error')
        return
    end

    local route = getRoute(routeId)
    if not route then return end
    local rideId = MySQL.insert.await('INSERT INTO delfzijlrp_bus_rides (driver_identifier, driver_name, route_id, payout) VALUES (?, ?, ?, ?)', {
        identifier,
        GetPlayerName(source),
        routeId,
        route.payout
    })
    cooldowns[identifier] = os.time() + Config.RouteCooldown
    logBus(source, 'start_route', routeId)
    notify(source, Config.Text.routeStarted, 'success')
    TriggerClientEvent('delfzijlrp_public_transport:client:setRoute', source, rideId, route)
end)

RegisterNetEvent('delfzijlrp_public_transport:server:completeStop', function(rideId)
    local source = source
    local identifier = getIdentifier(source)
    rideId = tonumber(rideId)
    if not identifier or not rideId or not isDriver(source) then return end

    MySQL.update.await('UPDATE delfzijlrp_bus_rides SET stops_done = stops_done + 1 WHERE id = ? AND driver_identifier = ? AND status = ?', { rideId, identifier, 'active' })
    logBus(source, 'complete_stop', tostring(rideId))
    notify(source, Config.Text.stopDone, 'success')
end)

RegisterNetEvent('delfzijlrp_public_transport:server:completeRoute', function(rideId)
    local source = source
    local xPlayer = getPlayer(source)
    local identifier = getIdentifier(source)
    rideId = tonumber(rideId)
    if not xPlayer or not identifier or not rideId or not isDriver(source) then return end

    local ride = MySQL.single.await('SELECT * FROM delfzijlrp_bus_rides WHERE id = ? AND driver_identifier = ? AND status = ? LIMIT 1', { rideId, identifier, 'active' })
    if not ride then return end

    xPlayer.addAccountMoney('bank', ride.payout)
    MySQL.update.await('UPDATE delfzijlrp_bus_rides SET status = ?, completed_at = NOW() WHERE id = ?', { 'completed', rideId })
    logBus(source, 'complete_route', tostring(ride.payout))
    notify(source, Config.Text.routeComplete .. ' €' .. ride.payout, 'success')
end)
