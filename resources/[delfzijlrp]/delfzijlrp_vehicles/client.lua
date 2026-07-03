local ESX = exports['es_extended']:getSharedObject()

local lastMileageUpdate = 0

local function notify(message, type)
    lib.notify({ title = 'Delfzijl RP RDW', description = message, type = type or 'inform' })
end

local function trimPlate(plate)
    return plate and plate:gsub('^%s*(.-)%s*$', '%1') or ''
end

local function getClosestVehiclePlate()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local vehicle = GetVehiclePedIsIn(ped, false)

    if vehicle == 0 then
        vehicle = ESX.Game.GetClosestVehicle(coords)
    end

    if not vehicle or vehicle == 0 or #(coords - GetEntityCoords(vehicle)) > 6.0 then
        notify(Config.Text.noVehicle, 'error')
        return nil
    end

    return trimPlate(GetVehicleNumberPlateText(vehicle)), vehicle
end

local function openRDWMenu(plate)
    local data = lib.callback.await('delfzijlrp_vehicles:server:getRDW', false, plate)
    if not data then
        notify(Config.Text.rdwMissing, 'error')
        return
    end

    lib.registerContext({
        id = 'delfzijlrp_rdw_menu',
        title = ('RDW | %s'):format(data.plate),
        options = {
            { title = 'VIN', description = data.vin or 'Onbekend', icon = 'barcode', readOnly = true },
            { title = 'Eigenaar-ID', description = data.owner or 'Onbekend', icon = 'user', readOnly = true },
            { title = 'Model', description = data.model or 'Onbekend', icon = 'car', readOnly = true },
            { title = 'Kilometerstand', description = tostring(data.mileage or 0) .. ' km', icon = 'gauge', readOnly = true },
            { title = 'APK geldig tot', description = data.apk_until or 'Onbekend', icon = 'screwdriver-wrench', readOnly = true },
            { title = 'Verzekering', description = ('%s tot %s'):format(data.insurance_type or 'WA', data.insurance_until or 'Onbekend'), icon = 'shield-halved', readOnly = true },
            { title = 'Gestolen status', description = tonumber(data.stolen) == 1 and 'Gesignaleerd' or 'Niet gesignaleerd', icon = 'triangle-exclamation', readOnly = true }
        }
    })

    lib.showContext('delfzijlrp_rdw_menu')
end

RegisterCommand('rdw', function(_, args)
    local plate = args[1]
    if not plate then
        plate = getClosestVehiclePlate()
    end

    if plate then
        openRDWMenu(trimPlate(plate))
    end
end, false)

RegisterCommand(Config.Keys.command, function(_, args)
    local targetId = tonumber(args[1])
    local plate = args[2]

    if not targetId then
        notify('Gebruik: /autosleutels spelerID [kenteken]', 'error')
        return
    end

    if not plate then
        plate = getClosestVehiclePlate()
    end

    if plate then
        TriggerServerEvent('delfzijlrp_vehicles:server:giveKey', targetId, trimPlate(plate))
    end
end, false)

RegisterCommand('overschrijven', function(_, args)
    local targetId = tonumber(args[1])
    local plate = args[2]

    if not targetId then
        notify('Gebruik: /overschrijven spelerID [kenteken]', 'error')
        return
    end

    if not plate then
        plate = getClosestVehiclePlate()
    end

    if plate then
        TriggerServerEvent('delfzijlrp_vehicles:server:transferVehicle', targetId, trimPlate(plate))
    end
end, false)

CreateThread(function()
    while true do
        Wait(Config.RDW.mileageTick)

        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)
        if vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == ped then
            local speed = GetEntitySpeed(vehicle) * 3.6
            if speed > 5 then
                local plate = trimPlate(GetVehicleNumberPlateText(vehicle))
                local amount = math.floor((speed / 3600) * (Config.RDW.mileageTick / 1000))
                if amount > 0 then
                    TriggerServerEvent('delfzijlrp_vehicles:server:addMileage', plate, amount)
                end
            end
        end
    end
end)
