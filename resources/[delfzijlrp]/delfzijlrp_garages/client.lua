local ESX = exports['es_extended']:getSharedObject()
local activeTrackerBlip = nil

local function notify(message, type)
    lib.notify({ title = 'Delfzijl RP Garage', description = message, type = type or 'inform' })
end

local function trimPlate(plate)
    return plate and plate:gsub('^%s*(.-)%s*$', '%1') or ''
end

local function isSpawnClear(coords)
    return not IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 3.0)
end

local function spawnVehicle(vehicleData, spawn)
    if not isSpawnClear(spawn) then
        notify(Config.Text.spawnBlocked, 'error')
        return
    end

    local props = vehicleData.vehicle
    local model = props.model
    if type(model) == 'string' then model = joaat(model) end

    lib.requestModel(model)

    local vehicle = CreateVehicle(model, spawn.x, spawn.y, spawn.z, spawn.w, true, false)
    ESX.Game.SetVehicleProperties(vehicle, props)
    SetVehicleNumberPlateText(vehicle, vehicleData.plate)
    SetVehicleNumberPlateTextIndex(vehicle, Config.DutchPlates.plateIndex or 1)
    SetPedIntoVehicle(PlayerPedId(), vehicle, -1)
    SetVehicleEngineOn(vehicle, true, true, false)
    SetModelAsNoLongerNeeded(model)

    TriggerServerEvent('delfzijlrp_garages:server:setVehicleState', vehicleData.plate, 0)
    notify(Config.Text.spawned, 'success')
end

local function storeCurrentVehicle()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)

    if vehicle == 0 then
        notify(Config.Text.noVehicle, 'error')
        return
    end

    local plate = trimPlate(GetVehicleNumberPlateText(vehicle))
    local props = ESX.Game.GetVehicleProperties(vehicle)
    local ok = lib.callback.await('delfzijlrp_garages:server:storeVehicle', false, plate, props)

    if ok then
        DeleteEntity(vehicle)
        notify(Config.Text.stored, 'success')
    else
        notify(Config.Text.notOwner, 'error')
    end
end

local function openPersonalGarage(garage)
    local vehicles = lib.callback.await('delfzijlrp_garages:server:getOwnedVehicles', false)

    if not vehicles or #vehicles == 0 then
        notify(Config.Text.noVehicles, 'error')
        return
    end

    local options = {}

    for _, vehicle in ipairs(vehicles) do
        local stateText = vehicle.stored == 1 and 'In garage' or 'Buiten'
        options[#options + 1] = {
            title = ('%s | %s'):format(vehicle.plate, stateText),
            description = vehicle.stored == 1 and 'Voertuig uitnemen' or 'Voertuig volgen via GPS',
            icon = vehicle.stored == 1 and 'car' or 'location-dot',
            onSelect = function()
                if vehicle.stored == 1 then
                    spawnVehicle(vehicle, garage.spawn)
                else
                    TriggerServerEvent('delfzijlrp_garages:server:trackVehicle', vehicle.plate)
                end
            end
        }
    end

    lib.registerContext({ id = 'delfzijlrp_personal_garage', title = garage.label, options = options })
    lib.showContext('delfzijlrp_personal_garage')
end

local function openJobGarage(jobName, garage)
    local playerData = ESX.GetPlayerData()
    if not playerData.job or playerData.job.name ~= jobName then
        notify('Je hebt geen toegang tot deze werkgarage.', 'error')
        return
    end

    local options = {}
    for _, vehicle in ipairs(garage.vehicles) do
        options[#options + 1] = {
            title = vehicle.label,
            description = ('Spawn %s'):format(vehicle.model),
            icon = 'truck-medical',
            onSelect = function()
                if not isSpawnClear(garage.spawn) then
                    notify(Config.Text.spawnBlocked, 'error')
                    return
                end

                local model = joaat(vehicle.model)
                lib.requestModel(model)
                local spawned = CreateVehicle(model, garage.spawn.x, garage.spawn.y, garage.spawn.z, garage.spawn.w, true, false)
                SetVehicleNumberPlateTextIndex(spawned, Config.DutchPlates.plateIndex or 1)
                SetPedIntoVehicle(PlayerPedId(), spawned, -1)
                SetVehicleEngineOn(spawned, true, true, false)
                SetModelAsNoLongerNeeded(model)
                notify(Config.Text.spawned, 'success')
            end
        }
    end

    lib.registerContext({ id = ('delfzijlrp_jobgarage_%s'):format(jobName), title = garage.label, options = options })
    lib.showContext(('delfzijlrp_jobgarage_%s'):format(jobName))
end

local function toggleNearestOwnedVehicleLock()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local vehicle = GetVehiclePedIsIn(ped, false)

    if vehicle == 0 then
        vehicle = ESX.Game.GetClosestVehicle(coords)
    end

    if not vehicle or vehicle == 0 or #(coords - GetEntityCoords(vehicle)) > 8.0 then
        notify(Config.Text.noVehicleNearby, 'error')
        return
    end

    local plate = trimPlate(GetVehicleNumberPlateText(vehicle))
    local owned = lib.callback.await('delfzijlrp_garages:server:isVehicleOwner', false, plate)

    if not owned then
        notify(Config.Text.notOwner, 'error')
        return
    end

    local lockStatus = GetVehicleDoorLockStatus(vehicle)
    local locked = lockStatus == 2 or lockStatus == 3

    if locked then
        SetVehicleDoorsLocked(vehicle, 1)
        SetVehicleDoorsLockedForAllPlayers(vehicle, false)
        PlayVehicleDoorOpenSound(vehicle, 0)
        notify(Config.Text.unlocked, 'success')
    else
        SetVehicleDoorsLocked(vehicle, 2)
        SetVehicleDoorsLockedForAllPlayers(vehicle, true)
        PlayVehicleDoorCloseSound(vehicle, 1)
        notify(Config.Text.locked, 'success')
    end

    SetVehicleLights(vehicle, 2)
    Wait(200)
    SetVehicleLights(vehicle, 0)
    Wait(200)
    SetVehicleLights(vehicle, 2)
    Wait(200)
    SetVehicleLights(vehicle, 0)
end

RegisterCommand(Config.LockCommand or 'voertuigslot', function()
    toggleNearestOwnedVehicleLock()
end, false)

RegisterKeyMapping(Config.LockCommand or 'voertuigslot', 'Voertuig vergrendelen/ontgrendelen', 'keyboard', Config.LockKey or 'U')

RegisterNetEvent('delfzijlrp_garages:client:setTracker', function(coords, plate)
    if activeTrackerBlip then
        RemoveBlip(activeTrackerBlip)
        activeTrackerBlip = nil
    end

    if not coords then
        notify(Config.Text.noTracker, 'error')
        return
    end

    SetNewWaypoint(coords.x, coords.y)
    activeTrackerBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(activeTrackerBlip, 225)
    SetBlipColour(activeTrackerBlip, 1)
    SetBlipScale(activeTrackerBlip, 0.85)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(('Voertuig %s'):format(plate))
    EndTextCommandSetBlipName(activeTrackerBlip)

    notify(('GPS locatie ingesteld voor %s.'):format(plate), 'success')

    SetTimeout(Config.TrackBlipDuration or 120000, function()
        if activeTrackerBlip then
            RemoveBlip(activeTrackerBlip)
            activeTrackerBlip = nil
        end
    end)
end)

CreateThread(function()
    Wait(1500)

    for _, garage in ipairs(Config.PersonalGarages) do
        if Config.UseBlips and garage.blip then
            local blip = AddBlipForCoord(garage.coords.x, garage.coords.y, garage.coords.z)
            SetBlipSprite(blip, garage.blip.sprite)
            SetBlipColour(blip, garage.blip.color)
            SetBlipScale(blip, garage.blip.scale)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(garage.label)
            EndTextCommandSetBlipName(blip)
        end

        exports.ox_target:addSphereZone({
            coords = garage.coords,
            radius = 2.0,
            debug = Config.Debug,
            options = {{ name = 'garage_' .. garage.id, icon = 'fa-solid fa-warehouse', label = Config.Text.openGarage, onSelect = function() openPersonalGarage(garage) end }}
        })

        exports.ox_target:addSphereZone({
            coords = garage.store,
            radius = 3.0,
            debug = Config.Debug,
            options = {{ name = 'store_' .. garage.id, icon = 'fa-solid fa-square-parking', label = Config.Text.storeVehicle, onSelect = storeCurrentVehicle }}
        })
    end

    for jobName, garage in pairs(Config.JobGarages) do
        exports.ox_target:addSphereZone({
            coords = garage.coords,
            radius = 2.0,
            debug = Config.Debug,
            options = {{ name = 'jobgarage_' .. jobName, icon = 'fa-solid fa-briefcase', label = Config.Text.jobGarage, onSelect = function() openJobGarage(jobName, garage) end }}
        })
    end
end)
