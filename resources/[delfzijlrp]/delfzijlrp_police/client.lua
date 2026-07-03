local function notify(message, type)
    lib.notify({ title = 'Delfzijl RP Politie', description = message, type = type or 'inform' })
end

local function getClosestPlate()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle == 0 then
        vehicle = ESX.Game.GetClosestVehicle(coords)
    end
    if not vehicle or vehicle == 0 or #(coords - GetEntityCoords(vehicle)) > 7.0 then return nil end
    return GetVehicleNumberPlateText(vehicle):gsub('^%s*(.-)%s*$', '%1')
end

local function checkPoliceAccess()
    local ok = lib.callback.await('delfzijlrp_police:server:isPolice', false)
    if not ok then notify(Config.Text.noAccess, 'error') end
    return ok
end

local function openVehicleCheck()
    if not checkPoliceAccess() then return end
    local plate = getClosestPlate()
    if not plate then
        local input = lib.inputDialog('Kenteken controleren', {
            { type = 'input', label = 'Kenteken', required = true, min = 2 }
        })
        if not input then return end
        plate = input[1]
    end

    local data = lib.callback.await('delfzijlrp_police:server:getVehicleInfo', false, plate)
    if not data then
        notify('Geen RDW-record gevonden.', 'error')
        return
    end

    local owner = data.firstname and (data.firstname .. ' ' .. data.lastname) or 'Onbekend'
    lib.registerContext({
        id = 'delfzijlrp_police_vehicle',
        title = ('Voertuig %s'):format(data.plate),
        options = {
            { title = 'Eigenaar', description = owner, icon = 'user', readOnly = true },
            { title = 'VIN', description = data.vin or 'Onbekend', icon = 'barcode', readOnly = true },
            { title = 'APK', description = data.apk_until or 'Onbekend', icon = 'screwdriver-wrench', readOnly = true },
            { title = 'Verzekering', description = ('%s tot %s'):format(data.insurance_type or 'WA', data.insurance_until or 'Onbekend'), icon = 'shield-halved', readOnly = true },
            { title = 'Gestolen', description = tonumber(data.stolen) == 1 and 'Ja' or 'Nee', icon = 'triangle-exclamation', readOnly = true },
            { title = 'In beslag', description = tonumber(data.impounded) == 1 and 'Ja' or 'Nee', icon = 'warehouse', readOnly = true },
            { title = 'Markeer gestolen', icon = 'triangle-exclamation', onSelect = function() TriggerServerEvent('delfzijlrp_police:server:setVehicleStolen', data.plate, true) end },
            { title = 'Verwijder gestolen-status', icon = 'circle-check', onSelect = function() TriggerServerEvent('delfzijlrp_police:server:setVehicleStolen', data.plate, false) end },
            { title = 'Markeer in beslag', icon = 'warehouse', onSelect = function() TriggerServerEvent('delfzijlrp_police:server:setVehicleImpounded', data.plate, true) end },
            { title = 'Vrijgeven uit beslag', icon = 'unlock', onSelect = function() TriggerServerEvent('delfzijlrp_police:server:setVehicleImpounded', data.plate, false) end }
        }
    })
    lib.showContext('delfzijlrp_police_vehicle')
end

local function openFineMenu()
    if not checkPoliceAccess() then return end
    local fineOptions = {}
    for category, fines in pairs(Config.Fines) do
        for _, fine in ipairs(fines) do
            fineOptions[#fineOptions + 1] = { value = category .. '|' .. fine.label .. '|' .. fine.amount, label = ('%s - €%s'):format(fine.label, fine.amount) }
        end
    end

    local input = lib.inputDialog('Boete uitschrijven', {
        { type = 'number', label = 'Speler ID', required = true, min = 1 },
        { type = 'select', label = 'Boete', required = true, options = fineOptions }
    })
    if not input then return end

    local category, reason, amount = input[2]:match('([^|]+)|([^|]+)|([^|]+)')
    TriggerServerEvent('delfzijlrp_police:server:createFine', input[1], category, reason, tonumber(amount))
end

local function openPoliceMenu()
    if not checkPoliceAccess() then return end
    lib.registerContext({
        id = 'delfzijlrp_police_menu',
        title = 'Politie Noord-Nederland',
        options = {
            { title = 'MDT openen', icon = 'tablet-screen-button', onSelect = function() ExecuteCommand('mdt') end },
            { title = 'Meldkamer openen', icon = 'tower-broadcast', onSelect = function() ExecuteCommand('meldkamer') end },
            { title = 'Kenteken/RDW controleren', icon = 'car', onSelect = openVehicleCheck },
            { title = 'Boete uitschrijven', icon = 'file-invoice-dollar', onSelect = openFineMenu },
            { title = 'Paniekknop', icon = 'triangle-exclamation', onSelect = function() ExecuteCommand('panic') end }
        }
    })
    lib.showContext('delfzijlrp_police_menu')
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
            options = {{ name = 'police_duty_' .. station.id, icon = 'fa-solid fa-user-shield', label = Config.Text.duty, onSelect = function() TriggerServerEvent('delfzijlrp_police:server:toggleDuty') end }}
        })

        exports.ox_target:addSphereZone({
            coords = station.evidence,
            radius = 1.5,
            debug = Config.Debug,
            options = {{ name = 'police_evidence_' .. station.id, icon = 'fa-solid fa-box-archive', label = Config.Text.evidence, onSelect = function() TriggerServerEvent('delfzijlrp_police:server:openEvidence', station.id) end }}
        })

        exports.ox_target:addSphereZone({
            coords = station.armory,
            radius = 1.5,
            debug = Config.Debug,
            options = {{ name = 'police_armory_' .. station.id, icon = 'fa-solid fa-vest', label = Config.Text.armory, onSelect = function() TriggerServerEvent('delfzijlrp_police:server:openArmory') end }}
        })
    end
end)

RegisterCommand(Config.Command, openPoliceMenu, false)
RegisterNetEvent('delfzijlrp_police:client:openStash', function(stashId)
    exports.ox_inventory:openInventory('stash', stashId)
end)
