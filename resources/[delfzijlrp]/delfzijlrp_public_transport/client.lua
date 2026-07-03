local activeRoute = nil
local activeRideId = nil
local currentStop = 1

local function notify(message, type)
    lib.notify({ title = 'Qbuzz Delfzijl', description = message, type = type or 'inform' })
end

local function isDriver()
    local ok = lib.callback.await('delfzijlrp_public_transport:server:isDriver', false)
    if not ok then notify(Config.Text.noAccess, 'error') end
    return ok
end

local function spawnBus()
    if not isDriver() then return end
    local hash = joaat(Config.Vehicle.model)
    lib.requestModel(hash)
    local s = Config.Depot.spawn
    local vehicle = CreateVehicle(hash, s.x, s.y, s.z, s.w, true, false)
    SetVehicleNumberPlateText(vehicle, Config.Vehicle.platePrefix .. math.random(100, 999))
    SetPedIntoVehicle(PlayerPedId(), vehicle, -1)
    SetVehicleEngineOn(vehicle, true, true, false)
    SetModelAsNoLongerNeeded(hash)
end

local function buyTicketMenu()
    lib.registerContext({
        id = 'delfzijlrp_bus_tickets',
        title = 'Bustickets',
        options = {
            { title = 'Enkele reis', description = '€' .. Config.Ticket.price, icon = 'ticket', onSelect = function() TriggerServerEvent('delfzijlrp_public_transport:server:buyTicket', 'single') end },
            { title = 'Dagkaart', description = '€' .. Config.Ticket.dayPassPrice, icon = 'ticket-simple', onSelect = function() TriggerServerEvent('delfzijlrp_public_transport:server:buyTicket', 'day') end }
        }
    })
    lib.showContext('delfzijlrp_bus_tickets')
end

local function routeOptions()
    local options = {}
    for _, route in ipairs(Config.Routes) do
        options[#options + 1] = {
            title = route.label,
            description = ('Haltes: %s | Beloning: €%s'):format(#route.stops, route.payout),
            icon = 'route',
            onSelect = function() TriggerServerEvent('delfzijlrp_public_transport:server:startRoute', route.id) end
        }
    end
    return options
end

local function openDepot()
    if not isDriver() then return end
    local stats = lib.callback.await('delfzijlrp_public_transport:server:getStats', false)
    lib.registerContext({
        id = 'delfzijlrp_bus_depot',
        title = Config.Depot.label,
        options = {
            { title = 'Bus pakken', icon = 'bus', onSelect = spawnBus },
            { title = 'Route starten', icon = 'route', onSelect = function()
                lib.registerContext({ id = 'delfzijlrp_bus_routes', title = 'Buslijnen', options = routeOptions() })
                lib.showContext('delfzijlrp_bus_routes')
            end },
            { title = 'Actieve route', icon = 'location-dot', onSelect = function()
                if activeRoute and activeRoute.stops[currentStop] then
                    local stop = activeRoute.stops[currentStop]
                    SetNewWaypoint(stop.coords.x, stop.coords.y)
                    notify(Config.Text.nextStop, 'inform')
                else
                    notify(Config.Text.noRoute, 'error')
                end
            end },
            { title = 'Statistieken', description = stats and ('Ritten: %s | Verdiend: €%s'):format(stats.rides, stats.earned) or 'Geen data', icon = 'chart-line', readOnly = true }
        }
    })
    lib.showContext('delfzijlrp_bus_depot')
end

local function handleStop(routeId, stopIndex)
    if not activeRoute or activeRoute.id ~= routeId or currentStop ~= stopIndex then
        notify(Config.Text.noRoute, 'error')
        return
    end

    local success = lib.progressCircle({
        duration = Config.StopDuration,
        label = 'Passagiers laten in- en uitstappen...',
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = { car = true, move = true, combat = true }
    })

    if not success then return end
    TriggerServerEvent('delfzijlrp_public_transport:server:completeStop', activeRideId)
    currentStop = currentStop + 1

    if currentStop > #activeRoute.stops then
        TriggerServerEvent('delfzijlrp_public_transport:server:completeRoute', activeRideId)
        activeRoute = nil
        activeRideId = nil
        currentStop = 1
    else
        local nextStop = activeRoute.stops[currentStop]
        SetNewWaypoint(nextStop.coords.x, nextStop.coords.y)
        notify('Volgende halte: ' .. nextStop.label, 'inform')
    end
end

CreateThread(function()
    Wait(1500)

    if Config.Depot.blip then
        local blip = AddBlipForCoord(Config.Depot.coords.x, Config.Depot.coords.y, Config.Depot.coords.z)
        SetBlipSprite(blip, Config.Depot.blip.sprite)
        SetBlipColour(blip, Config.Depot.blip.color)
        SetBlipScale(blip, Config.Depot.blip.scale)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(Config.Depot.label)
        EndTextCommandSetBlipName(blip)
    end

    exports.ox_target:addSphereZone({
        coords = Config.Depot.coords,
        radius = Config.Depot.radius,
        debug = Config.Debug,
        options = {{ name = 'bus_depot', icon = 'fa-solid fa-bus', label = Config.Text.openDepot, onSelect = openDepot }}
    })

    for _, route in ipairs(Config.Routes) do
        for index, stop in ipairs(route.stops) do
            exports.ox_target:addSphereZone({
                coords = stop.coords,
                radius = 2.5,
                debug = Config.Debug,
                options = {
                    { name = 'bus_ticket_' .. route.id .. '_' .. stop.id, icon = 'fa-solid fa-ticket', label = 'Busticket kopen', onSelect = buyTicketMenu },
                    { name = 'bus_stop_' .. route.id .. '_' .. stop.id, icon = 'fa-solid fa-bus-simple', label = stop.label .. ' bedienen', onSelect = function() handleStop(route.id, index) end }
                }
            })
        end
    end
end)

RegisterCommand(Config.Command, buyTicketMenu, false)
RegisterCommand(Config.DriverCommand, openDepot, false)

RegisterNetEvent('delfzijlrp_public_transport:client:setRoute', function(rideId, route)
    activeRideId = rideId
    activeRoute = route
    currentStop = 1
    if route and route.stops and route.stops[1] then
        SetNewWaypoint(route.stops[1].coords.x, route.stops[1].coords.y)
        notify(Config.Text.routeStarted .. ' Eerste halte: ' .. route.stops[1].label, 'success')
    end
end)
