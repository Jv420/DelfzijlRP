local function notify(message, type)
    lib.notify({ title = 'Delfzijl RP ANWB', description = message, type = type or 'inform' })
end

local function isMechanic()
    local ok = lib.callback.await('delfzijlrp_anwb:server:isMechanic', false)
    if not ok then notify(Config.Text.noAccess, 'error') end
    return ok
end

local function getClosestVehicle()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle == 0 then
        vehicle = ESX.Game.GetClosestVehicle(coords)
    end
    if not vehicle or vehicle == 0 or #(coords - GetEntityCoords(vehicle)) > 7.0 then return nil end
    return vehicle
end

local function getPlate(vehicle)
    return GetVehicleNumberPlateText(vehicle):gsub('^%s*(.-)%s*$', '%1')
end

local function targetDialog(title)
    local input = lib.inputDialog(title, {
        { type = 'number', label = 'Speler ID klant', required = true, min = 1 }
    })
    return input and tonumber(input[1]) or nil
end

local function repairVehicle()
    if not isMechanic() then return end
    local vehicle = getClosestVehicle()
    if not vehicle then notify(Config.Text.noVehicle, 'error') return end

    local success = lib.progressCircle({
        duration = Config.Repair.duration,
        label = 'Voertuig repareren...',
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = { car = true, move = true, combat = true },
        anim = { dict = 'mini@repair', clip = 'fixing_a_ped' }
    })

    if success then
        SetVehicleFixed(vehicle)
        SetVehicleDeformationFixed(vehicle)
        SetVehicleEngineHealth(vehicle, 1000.0)
        notify(Config.Text.repaired, 'success')
    end
end

local function cleanVehicle()
    if not isMechanic() then return end
    local vehicle = getClosestVehicle()
    if not vehicle then notify(Config.Text.noVehicle, 'error') return end
    SetVehicleDirtLevel(vehicle, 0.0)
    notify(Config.Text.cleaned, 'success')
end

local function diagnoseVehicle()
    if not isMechanic() then return end
    local vehicle = getClosestVehicle()
    if not vehicle then notify(Config.Text.noVehicle, 'error') return end

    local plate = getPlate(vehicle)
    local data = lib.callback.await('delfzijlrp_anwb:server:getVehicleInfo', false, plate)
    local engine = math.floor(GetVehicleEngineHealth(vehicle))
    local body = math.floor(GetVehicleBodyHealth(vehicle))
    local fuel = math.floor(Entity(vehicle).state.fuel or GetVehicleFuelLevel(vehicle) or 0)

    lib.registerContext({
        id = 'delfzijlrp_anwb_diagnose',
        title = ('Diagnose %s'):format(plate),
        options = {
            { title = 'Motorconditie', description = tostring(engine), icon = 'gauge', readOnly = true },
            { title = 'Carrosserie', description = tostring(body), icon = 'car-burst', readOnly = true },
            { title = 'Brandstof', description = fuel .. '%', icon = 'gas-pump', readOnly = true },
            { title = 'APK geldig tot', description = data and data.apk_until or 'Onbekend', icon = 'screwdriver-wrench', readOnly = true },
            { title = 'Verzekering', description = data and ((data.insurance_type or 'WA') .. ' tot ' .. (data.insurance_until or 'Onbekend')) or 'Onbekend', icon = 'shield-halved', readOnly = true }
        }
    })
    lib.showContext('delfzijlrp_anwb_diagnose')
end

local function chargeService(actionType)
    if not isMechanic() then return end
    local vehicle = getClosestVehicle()
    local plate = vehicle and getPlate(vehicle) or 'ONBEKEND'
    local targetId = targetDialog('Service afrekenen')
    if targetId then
        TriggerServerEvent('delfzijlrp_anwb:server:chargeService', targetId, plate, actionType)
    end
end

local function renewApk()
    if not isMechanic() then return end
    local vehicle = getClosestVehicle()
    if not vehicle then notify(Config.Text.noVehicle, 'error') return end
    local plate = getPlate(vehicle)
    TriggerServerEvent('delfzijlrp_anwb:server:renewApk', plate)
end

local function openAnwbMenu()
    if not isMechanic() then return end
    lib.registerContext({
        id = 'delfzijlrp_anwb_menu',
        title = 'ANWB Delfzijl',
        options = {
            { title = 'Meldkamer openen', icon = 'tower-broadcast', onSelect = function() ExecuteCommand('meldkamer') end },
            { title = 'Voertuigdiagnose', icon = 'magnifying-glass-chart', onSelect = diagnoseVehicle },
            { title = 'Voertuig repareren', icon = 'screwdriver-wrench', onSelect = repairVehicle },
            { title = 'Voertuig schoonmaken', icon = 'soap', onSelect = cleanVehicle },
            { title = 'APK vernieuwen', icon = 'clipboard-check', onSelect = renewApk },
            { title = 'Service afrekenen: reparatie', icon = 'file-invoice-dollar', onSelect = function() chargeService('repair') end },
            { title = 'Service afrekenen: APK', icon = 'file-invoice-dollar', onSelect = function() chargeService('apk') end },
            { title = 'ANWB oproep maken', icon = 'tower-broadcast', onSelect = function()
                local coords = GetEntityCoords(PlayerPedId())
                TriggerServerEvent('delfzijlrp_dispatch:server:createReport', 'roadside', 'ANWB assistentie gevraagd door medewerker.', { x = coords.x, y = coords.y, z = coords.z })
            end }
        }
    })
    lib.showContext('delfzijlrp_anwb_menu')
end

CreateThread(function()
    Wait(1500)
    for _, station in ipairs(Config.Stations) do
        if station.blip then
            local blip = AddBlipForCoord(station.duty.x, station.duty.y, station.duty.z)
            SetBlipSprite(blip, station.blip.sprite)
            SetBlipColour(blip, station.blip.color)
            SetBlipScale(blip, station.blip.scale)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(station.label)
            EndTextCommandSetBlipName(blip)
        end

        exports.ox_target:addSphereZone({
            coords = station.duty,
            radius = 1.5,
            debug = Config.Debug,
            options = {{ name = 'anwb_duty_' .. station.id, icon = 'fa-solid fa-user-gear', label = Config.Text.duty, onSelect = function() TriggerServerEvent('delfzijlrp_anwb:server:toggleDuty') end }}
        })

        exports.ox_target:addSphereZone({
            coords = station.storage,
            radius = 1.5,
            debug = Config.Debug,
            options = {{ name = 'anwb_storage_' .. station.id, icon = 'fa-solid fa-box-archive', label = Config.Text.storage, onSelect = function() TriggerServerEvent('delfzijlrp_anwb:server:openStorage', station.id) end }}
        })

        exports.ox_target:addSphereZone({
            coords = station.service,
            radius = 2.5,
            debug = Config.Debug,
            options = {{ name = 'anwb_service_' .. station.id, icon = 'fa-solid fa-screwdriver-wrench', label = Config.Text.service, onSelect = openAnwbMenu }}
        })
    end
end)

RegisterCommand(Config.Command, openAnwbMenu, false)
RegisterNetEvent('delfzijlrp_anwb:client:openStash', function(stashId)
    exports.ox_inventory:openInventory('stash', stashId)
end)
