local ESX = exports['es_extended']:getSharedObject()
local currentVehicle = nil

local function notify(message, type)
    lib.notify({ title = 'Delfzijl RP Fuel', description = message, type = type or 'inform' })
end

local function getClosestVehicle()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local vehicle = GetVehiclePedIsIn(ped, false)

    if vehicle == 0 then
        vehicle = ESX.Game.GetClosestVehicle(coords)
    end

    if not vehicle or vehicle == 0 or #(coords - GetEntityCoords(vehicle)) > 5.0 then
        return nil
    end

    return vehicle
end

local function getFuel(vehicle)
    return Entity(vehicle).state.fuel or GetVehicleFuelLevel(vehicle) or Config.DefaultFuel
end

local function setFuel(vehicle, amount)
    amount = math.max(0.0, math.min(100.0, amount))
    SetVehicleFuelLevel(vehicle, amount)
    Entity(vehicle).state:set('fuel', amount, true)
end

local function refuelVehicle(useJerrycan)
    local vehicle = getClosestVehicle()
    if not vehicle then
        notify(Config.Text.noVehicle, 'error')
        return
    end

    local fuel = getFuel(vehicle)
    if fuel >= 99.0 then
        notify(Config.Text.fullTank, 'error')
        return
    end

    if useJerrycan then
        local hasJerrycan = lib.callback.await('delfzijlrp_fuel:server:hasJerrycan', false)
        if not hasJerrycan then
            notify(Config.Text.noJerrycan, 'error')
            return
        end
    end

    local litersNeeded = math.ceil(100 - fuel)
    local price = useJerrycan and 0 or litersNeeded * Config.PricePerLiter

    local allowed = true
    if not useJerrycan then
        allowed = lib.callback.await('delfzijlrp_fuel:server:payFuel', false, price)
    end

    if not allowed then
        notify(Config.Text.noMoney, 'error')
        return
    end

    local success = lib.progressCircle({
        duration = math.floor(litersNeeded / Config.RefuelSpeed) * 350,
        label = 'Tanken...',
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = { car = true, move = true, combat = true },
        anim = { dict = 'timetable@gardener@filling_can', clip = 'gar_ig_5_filling_can' }
    })

    if not success then return end

    setFuel(vehicle, 100.0)
    notify(Config.Text.refueled, 'success')
end

CreateThread(function()
    Wait(1500)

    for _, coords in ipairs(Config.Stations) do
        if Config.UseBlips then
            local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
            SetBlipSprite(blip, 361)
            SetBlipColour(blip, 5)
            SetBlipScale(blip, 0.65)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString('Tankstation')
            EndTextCommandSetBlipName(blip)
        end
    end

    exports.ox_target:addModel(Config.PumpModels, {
        {
            name = 'delfzijlrp_fuel_refuel',
            icon = 'fa-solid fa-gas-pump',
            label = Config.Text.refuel,
            distance = 2.0,
            onSelect = function() refuelVehicle(false) end
        },
        {
            name = 'delfzijlrp_fuel_jerrycan',
            icon = 'fa-solid fa-fill-drip',
            label = Config.Text.buyJerrycan,
            distance = 2.0,
            onSelect = function()
                TriggerServerEvent('delfzijlrp_fuel:server:buyJerrycan')
            end
        }
    })
end)

CreateThread(function()
    while true do
        Wait(Config.ConsumptionTick)

        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)

        if vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == ped then
            currentVehicle = vehicle
            local class = GetVehicleClass(vehicle)
            local multiplier = Config.Consumption[class] or 1.0
            local rpm = GetVehicleCurrentRpm(vehicle)
            local fuel = getFuel(vehicle)
            local usage = rpm * multiplier

            if fuel > 0 then
                setFuel(vehicle, fuel - usage)
            else
                SetVehicleEngineOn(vehicle, false, true, true)
            end

            local plate = GetVehicleNumberPlateText(vehicle)
            if plate then
                TriggerServerEvent('delfzijlrp_garages:server:updateVehicleLocation', plate, GetEntityCoords(vehicle))
            end
        end
    end
end)

RegisterCommand('jerrycan', function()
    refuelVehicle(true)
end, false)
