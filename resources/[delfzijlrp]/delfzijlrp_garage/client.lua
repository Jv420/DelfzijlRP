local function notify(message, type)
    lib.notify({ title = 'Delfzijl RP Garage', description = message, type = type or 'inform' })
end

local function trimPlate(plate)
    return plate and plate:gsub('^%s*(.-)%s*$', '%1') or ''
end

local function decodeProps(props)
    if type(props) == 'table' then return props end
    if type(props) == 'string' then
        local ok, decoded = pcall(json.decode, props)
        if ok then return decoded end
    end
    return nil
end

local function spawnVehicle(props, spawn)
    props = decodeProps(props)
    if not props or not props.model then
        notify('Voertuigdata ontbreekt.', 'error')
        return
    end

    local model = props.model
    if type(model) == 'string' then model = joaat(model) end
    lib.requestModel(model)

    local vehicle = CreateVehicle(model, spawn.x, spawn.y, spawn.z, spawn.w, true, false)
    ESX.Game.SetVehicleProperties(vehicle, props)
    SetVehicleOnGroundProperly(vehicle)
    SetVehicleEngineOn(vehicle, true, true, false)
    SetPedIntoVehicle(PlayerPedId(), vehicle, -1)
    SetModelAsNoLongerNeeded(model)
    notify(Config.Text.spawned, 'success')
end

local function openGarage(garage)
    local vehicles = lib.callback.await('delfzijlrp_garage:server:getVehicles', false, garage.id, false) or {}
    if #vehicles == 0 then notify(Config.Text.noVehicles, 'inform') return end

    local options = {}
    for _, vehicle in ipairs(vehicles) do
        local status = vehicle.stored == 1 and 'Gestald' or 'Buiten'
        options[#options + 1] = {
            title = ('%s | %s'):format(vehicle.plate, vehicle.model or 'Voertuig'),
            description = status,
            icon = 'car',
            onSelect = function()
                local ok, propsOrReason = lib.callback.await('delfzijlrp_garage:server:takeOut', false, vehicle.plate, false)
                if not ok then notify(propsOrReason or 'Niet gelukt.', 'error') return end
                spawnVehicle(propsOrReason, garage.spawn)
            end
        }
    end

    lib.registerContext({ id = 'delfzijlrp_garage_menu', title = garage.label, options = options })
    lib.showContext('delfzijlrp_garage_menu')
end

local function storeVehicle(garage)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle == 0 then
        vehicle = ESX.Game.GetClosestVehicle(GetEntityCoords(ped))
    end

    if not vehicle or vehicle == 0 then notify(Config.Text.noVehicle, 'error') return end

    local plate = trimPlate(GetVehicleNumberPlateText(vehicle))
    local props = ESX.Game.GetVehicleProperties(vehicle)
    TriggerServerEvent('delfzijlrp_garage:server:storeVehicle', plate, garage.id, props)
    DeleteEntity(vehicle)
end

local function openImpound(impound)
    local vehicles = lib.callback.await('delfzijlrp_garage:server:getVehicles', false, impound.id, true) or {}
    if #vehicles == 0 then notify(Config.Text.noVehicles, 'inform') return end

    local options = {}
    for _, vehicle in ipairs(vehicles) do
        options[#options + 1] = {
            title = ('%s | %s'):format(vehicle.plate, vehicle.model or 'Voertuig'),
            description = ('Vrijhalen: €%s'):format(Config.Impound.price),
            icon = 'warehouse',
            onSelect = function()
                local ok, propsOrReason = lib.callback.await('delfzijlrp_garage:server:takeOut', false, vehicle.plate, true)
                if not ok then notify(propsOrReason or 'Niet gelukt.', 'error') return end
                spawnVehicle(propsOrReason, impound.spawn)
            end
        }
    end

    lib.registerContext({ id = 'delfzijlrp_impound_menu', title = impound.label, options = options })
    lib.showContext('delfzijlrp_impound_menu')
end

local function policeImpoundClosest()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle == 0 then vehicle = ESX.Game.GetClosestVehicle(GetEntityCoords(ped)) end
    if not vehicle or vehicle == 0 then notify(Config.Text.noVehicle, 'error') return end
    local plate = trimPlate(GetVehicleNumberPlateText(vehicle))
    local props = ESX.Game.GetVehicleProperties(vehicle)
    TriggerServerEvent('delfzijlrp_garage:server:impoundVehicle', plate, props)
    DeleteEntity(vehicle)
end

CreateThread(function()
    Wait(1500)

    for _, garage in ipairs(Config.Garages) do
        if garage.blip then
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
            options = {{ name = 'garage_open_' .. garage.id, icon = 'fa-solid fa-car', label = Config.Text.openGarage, onSelect = function() openGarage(garage) end }}
        })

        exports.ox_target:addSphereZone({
            coords = garage.store,
            radius = 3.0,
            debug = Config.Debug,
            options = {{ name = 'garage_store_' .. garage.id, icon = 'fa-solid fa-square-parking', label = Config.Text.storeVehicle, onSelect = function() storeVehicle(garage) end }}
        })
    end

    for _, impound in ipairs(Config.Impounds) do
        if impound.blip then
            local blip = AddBlipForCoord(impound.coords.x, impound.coords.y, impound.coords.z)
            SetBlipSprite(blip, impound.blip.sprite)
            SetBlipColour(blip, impound.blip.color)
            SetBlipScale(blip, impound.blip.scale)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(impound.label)
            EndTextCommandSetBlipName(blip)
        end

        exports.ox_target:addSphereZone({
            coords = impound.coords,
            radius = 2.0,
            debug = Config.Debug,
            options = {{ name = 'impound_open_' .. impound.id, icon = 'fa-solid fa-warehouse', label = Config.Text.openImpound, onSelect = function() openImpound(impound) end }}
        })
    end
end)

RegisterCommand(Config.Command, function()
    openGarage(Config.Garages[1])
end, false)

RegisterCommand(Config.ImpoundCommand, policeImpoundClosest, false)
