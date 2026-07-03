local meterActive = false
local meterStartCoords = nil
local meterDistance = 0.0
local meterFare = 0

local function notify(message, type)
    lib.notify({ title = 'Delfzijl RP Taxi', description = message, type = type or 'inform' })
end

local function isTaxi()
    local ok = lib.callback.await('delfzijlrp_taxi:server:isTaxi', false)
    if not ok then notify(Config.Text.noAccess, 'error') end
    return ok
end

local function isTaxiVehicle(vehicle)
    if vehicle == 0 then return false end
    local model = GetEntityModel(vehicle)
    for _, item in ipairs(Config.Vehicles) do
        if model == joaat(item.model) then return true end
    end
    return false
end

local function getTaxiVehicle()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 or not isTaxiVehicle(vehicle) then return nil end
    return vehicle
end

local function startMeter()
    if not isTaxi() then return end
    local vehicle = getTaxiVehicle()
    if not vehicle then notify(Config.Text.noVehicle, 'error') return end

    meterActive = true
    meterStartCoords = GetEntityCoords(PlayerPedId())
    meterDistance = 0.0
    meterFare = Config.Meter.startPrice
    notify(Config.Text.meterStarted, 'success')
end

local function stopMeter()
    meterActive = false
    notify(Config.Text.meterStopped, 'inform')
end

local function chargeCustomer()
    if not isTaxi() then return end
    local input = lib.inputDialog('Taxirit afrekenen', {
        { type = 'number', label = 'Speler ID klant', required = true, min = 1 },
        { type = 'number', label = 'Bedrag', default = meterFare, required = true, min = Config.Meter.minimumFare }
    })
    if not input then return end
    TriggerServerEvent('delfzijlrp_taxi:server:chargeRide', input[1], meterDistance, input[2])
end

local function spawnTaxi(model)
    if not isTaxi() then return end
    local hash = joaat(model)
    lib.requestModel(hash)
    local spawn = Config.Company.spawn
    local vehicle = CreateVehicle(hash, spawn.x, spawn.y, spawn.z, spawn.w, true, false)
    SetPedIntoVehicle(PlayerPedId(), vehicle, -1)
    SetVehicleEngineOn(vehicle, true, true, false)
    SetModelAsNoLongerNeeded(hash)
end

local function openGarage()
    local options = {}
    for _, vehicle in ipairs(Config.Vehicles) do
        options[#options + 1] = {
            title = vehicle.label,
            icon = 'taxi',
            onSelect = function() spawnTaxi(vehicle.model) end
        }
    end
    lib.registerContext({ id = 'delfzijlrp_taxi_garage', title = 'Taxi Garage', options = options })
    lib.showContext('delfzijlrp_taxi_garage')
end

local function startNpcRoute(route)
    if not isTaxi() then return end
    local vehicle = getTaxiVehicle()
    if not vehicle then notify(Config.Text.noVehicle, 'error') return end

    SetNewWaypoint(route.pickup.x, route.pickup.y)
    notify(Config.Text.routeStarted, 'success')

    local accepted = lib.alertDialog({
        header = route.label,
        content = 'Rijd eerst naar de pickup en daarna naar de bestemming. Rond de rit af zodra je bij de bestemming bent.',
        centered = true,
        cancel = true
    })

    if accepted ~= 'confirm' then return end

    SetNewWaypoint(route.dropoff.x, route.dropoff.y)
    local payout = math.random(route.payout.min, route.payout.max)
    local distance = #(route.pickup - route.dropoff) / 1000

    local finish = lib.progressCircle({
        duration = 5000,
        label = 'NPC klant afzetten...',
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = { car = true, move = true, combat = true }
    })

    if finish then
        TriggerServerEvent('delfzijlrp_taxi:server:completeNpcRide', distance, payout)
    end
end

local function openTaxiMenu()
    if not isTaxi() then return end
    local stats = lib.callback.await('delfzijlrp_taxi:server:getStats', false)
    lib.registerContext({
        id = 'delfzijlrp_taxi_menu',
        title = 'Delfzijl Taxi Centrale',
        options = {
            { title = 'Meldkamer openen', icon = 'tower-broadcast', onSelect = function() ExecuteCommand('meldkamer') end },
            { title = 'Taximeter starten', icon = 'play', onSelect = startMeter },
            { title = 'Taximeter stoppen', icon = 'stop', onSelect = stopMeter },
            { title = ('Huidige rit: €%s | %.2f km'):format(meterFare, meterDistance), icon = 'gauge', readOnly = true },
            { title = 'Klant afrekenen', icon = 'file-invoice-dollar', onSelect = chargeCustomer },
            { title = 'Taxi garage', icon = 'taxi', onSelect = openGarage },
            { title = 'Statistieken', description = stats and ('Ritten: %s | Verdiend: €%s'):format(stats.rides, stats.earned) or 'Geen data', icon = 'chart-line', readOnly = true }
        }
    })
    lib.showContext('delfzijlrp_taxi_menu')
end

local function openNpcRoutes()
    local options = {}
    for _, route in ipairs(Config.NPCRoutes) do
        options[#options + 1] = {
            title = route.label,
            description = ('Beloning: €%s - €%s'):format(route.payout.min, route.payout.max),
            icon = 'route',
            onSelect = function() startNpcRoute(route) end
        }
    end
    lib.registerContext({ id = 'delfzijlrp_taxi_routes', title = 'NPC Ritten', options = options })
    lib.showContext('delfzijlrp_taxi_routes')
end

CreateThread(function()
    while true do
        Wait(2000)
        if meterActive then
            local vehicle = getTaxiVehicle()
            if not vehicle then
                meterActive = false
            else
                local coords = GetEntityCoords(PlayerPedId())
                if meterStartCoords then
                    meterDistance = #(coords - meterStartCoords) / 1000
                    meterFare = math.max(Config.Meter.minimumFare, math.floor(Config.Meter.startPrice + (meterDistance * Config.Meter.pricePerKm)))
                end
            end
        end
    end
end)

CreateThread(function()
    Wait(1500)
    local c = Config.Company
    if c.blip then
        local blip = AddBlipForCoord(c.duty.x, c.duty.y, c.duty.z)
        SetBlipSprite(blip, c.blip.sprite)
        SetBlipColour(blip, c.blip.color)
        SetBlipScale(blip, c.blip.scale)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(c.label)
        EndTextCommandSetBlipName(blip)
    end

    exports.ox_target:addSphereZone({
        coords = c.duty,
        radius = 1.5,
        debug = Config.Debug,
        options = {{ name = 'taxi_duty', icon = 'fa-solid fa-taxi', label = Config.Text.duty, onSelect = function() TriggerServerEvent('delfzijlrp_taxi:server:toggleDuty') end }}
    })

    exports.ox_target:addSphereZone({
        coords = c.garage,
        radius = 2.0,
        debug = Config.Debug,
        options = {
            { name = 'taxi_garage', icon = 'fa-solid fa-car', label = Config.Text.garage, onSelect = openGarage },
            { name = 'taxi_routes', icon = 'fa-solid fa-route', label = 'NPC ritten openen', onSelect = openNpcRoutes }
        }
    })
end)

RegisterCommand(Config.Command, openTaxiMenu, false)
