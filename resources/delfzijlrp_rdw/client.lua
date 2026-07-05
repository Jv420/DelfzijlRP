local ESX = exports['es_extended']:getSharedObject()

local function notify(message, type)
    lib.notify({ title = 'RDW Delfzijl', description = message, type = type or 'inform' })
end

local function trimPlate(plate)
    return plate and plate:gsub('^%s*(.-)%s*$', '%1'):upper() or ''
end

local function getVehicle()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle == 0 then vehicle = ESX.Game.GetClosestVehicle(GetEntityCoords(ped)) end
    if not vehicle or vehicle == 0 then return nil end
    return vehicle
end

local function getVehicleData()
    local vehicle = getVehicle()
    if not vehicle then notify(Config.Text.noVehicle, 'error') return nil end
    local props = ESX.Game.GetVehicleProperties(vehicle)
    local plate = trimPlate(GetVehicleNumberPlateText(vehicle))
    local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
    return vehicle, plate, model, props
end

local function registerCurrentVehicle()
    local vehicle, plate, model, props = getVehicleData()
    if not vehicle then return end
    TriggerServerEvent('delfzijlrp_rdw:server:registerVehicle', plate, model, props)
end

local function customPlateDialog()
    local vehicle, plate, model, props = getVehicleData()
    if not vehicle then return end
    local input = lib.inputDialog('Persoonlijk kenteken', {
        { type = 'input', label = 'Nieuw kenteken', description = '3-8 tekens, letters/cijfers/streepjes', required = true, min = 3, max = 8 }
    })
    if not input then return end
    TriggerServerEvent('delfzijlrp_rdw:server:setCustomPlate', plate, input[1], props)
end

local function insuranceMenu(plate)
    lib.registerContext({
        id = 'delfzijlrp_rdw_insurance',
        title = 'Verzekering ' .. plate,
        options = {
            { title = 'WA', description = '€' .. Config.Prices.insuranceWA, icon = 'shield', onSelect = function() TriggerServerEvent('delfzijlrp_rdw:server:buyInsurance', plate, 'wa') end },
            { title = 'WA+', description = '€' .. Config.Prices.insuranceWAPLUS, icon = 'shield-halved', onSelect = function() TriggerServerEvent('delfzijlrp_rdw:server:buyInsurance', plate, 'waplus') end },
            { title = 'All Risk', description = '€' .. Config.Prices.insuranceAllRisk, icon = 'shield-heart', onSelect = function() TriggerServerEvent('delfzijlrp_rdw:server:buyInsurance', plate, 'allrisk') end }
        }
    })
    lib.showContext('delfzijlrp_rdw_insurance')
end

local function myVehiclesMenu()
    local vehicles = lib.callback.await('delfzijlrp_rdw:server:getMyVehicles', false) or {}
    local options = {}
    for _, v in ipairs(vehicles) do
        options[#options + 1] = {
            title = v.plate .. ' | ' .. (v.model or 'Voertuig'),
            description = ('APK: %s | Verzekering: %s'):format(v.apk_until or 'onbekend', v.insurance_type or 'none'),
            icon = 'car',
            onSelect = function()
                lib.registerContext({
                    id = 'delfzijlrp_rdw_vehicle_detail',
                    title = v.plate,
                    options = {
                        { title = 'Verzekering afsluiten', icon = 'shield', onSelect = function() insuranceMenu(v.plate) end },
                        { title = 'Overschrijven', icon = 'right-left', onSelect = function()
                            local input = lib.inputDialog('Voertuig overschrijven', {
                                { type = 'number', label = 'Speler ID koper', required = true, min = 1 }
                            })
                            if input then TriggerServerEvent('delfzijlrp_rdw:server:transferVehicle', v.plate, input[1]) end
                        end },
                        { title = 'VIN', description = v.vin or 'Onbekend', icon = 'barcode', readOnly = true },
                        { title = 'Eigenaar', description = v.owner_name or 'Onbekend', icon = 'user', readOnly = true }
                    }
                })
                lib.showContext('delfzijlrp_rdw_vehicle_detail')
            end
        }
    end
    if #options == 0 then options[#options + 1] = { title = 'Geen RDW voertuigen gevonden', icon = 'circle-info', readOnly = true } end
    lib.registerContext({ id = 'delfzijlrp_rdw_myvehicles', title = 'Mijn RDW voertuigen', options = options })
    lib.showContext('delfzijlrp_rdw_myvehicles')
end

local function lookupDialog()
    local input = lib.inputDialog('Kenteken zoeken', {
        { type = 'input', label = 'Kenteken', required = true, min = 2, max = 16 }
    })
    if not input then return end
    local row = lib.callback.await('delfzijlrp_rdw:server:lookupPlate', false, input[1])
    if not row then notify(Config.Text.notFound, 'error') return end
    lib.registerContext({
        id = 'delfzijlrp_rdw_lookup_result',
        title = row.plate,
        options = {
            { title = 'Eigenaar', description = row.owner_name or row.owner, icon = 'user', readOnly = true },
            { title = 'Model', description = row.model or 'Onbekend', icon = 'car', readOnly = true },
            { title = 'APK', description = row.apk_until or 'Onbekend', icon = 'screwdriver-wrench', readOnly = true },
            { title = 'Verzekering', description = (row.insurance_type or 'none') .. ' tot ' .. (row.insurance_until or 'onbekend'), icon = 'shield', readOnly = true },
            { title = 'Status', description = row.status or 'active', icon = 'circle-info', readOnly = true }
        }
    })
    lib.showContext('delfzijlrp_rdw_lookup_result')
end

local function apkCurrentVehicle()
    local vehicle, plate = getVehicleData()
    if not vehicle then return end
    TriggerServerEvent('delfzijlrp_rdw:server:renewApk', plate)
end

local function openMenu()
    lib.registerContext({
        id = 'delfzijlrp_rdw_main',
        title = Config.RDWOffice.label,
        options = {
            { title = 'Huidig voertuig registreren', description = 'Kosten: €' .. Config.Prices.register, icon = 'car-side', onSelect = registerCurrentVehicle },
            { title = 'Mijn voertuigen', icon = 'list', onSelect = myVehiclesMenu },
            { title = 'Persoonlijk kenteken', description = 'Kosten: €' .. Config.Prices.customPlate, icon = 'rectangle-list', onSelect = customPlateDialog },
            { title = 'Kenteken zoeken', icon = 'magnifying-glass', onSelect = lookupDialog },
            { title = 'APK huidige auto uitvoeren', description = 'Voor overheid/ANWB/politie', icon = 'screwdriver-wrench', onSelect = apkCurrentVehicle }
        }
    })
    lib.showContext('delfzijlrp_rdw_main')
end

CreateThread(function()
    Wait(1500)
    if Config.RDWOffice.blip then
        local blip = AddBlipForCoord(Config.RDWOffice.coords.x, Config.RDWOffice.coords.y, Config.RDWOffice.coords.z)
        SetBlipSprite(blip, Config.RDWOffice.blip.sprite)
        SetBlipColour(blip, Config.RDWOffice.blip.color)
        SetBlipScale(blip, Config.RDWOffice.blip.scale)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(Config.RDWOffice.label)
        EndTextCommandSetBlipName(blip)
    end

    exports.ox_target:addSphereZone({
        coords = Config.RDWOffice.coords,
        radius = Config.RDWOffice.radius,
        debug = Config.Debug,
        options = {{ name = 'rdw_open', icon = 'fa-solid fa-car', label = Config.Text.open, onSelect = openMenu }}
    })
end)

RegisterCommand(Config.Command, openMenu, false)
RegisterCommand(Config.AdminCommand, lookupDialog, false)

RegisterNetEvent('delfzijlrp_rdw:client:setPlateOnVehicle', function(plate)
    local vehicle = getVehicle()
    if not vehicle then return end
    SetVehicleNumberPlateText(vehicle, trimPlate(plate))
end)
