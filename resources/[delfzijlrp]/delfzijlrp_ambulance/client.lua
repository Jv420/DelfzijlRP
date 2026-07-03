local function notify(message, type)
    lib.notify({ title = 'Delfzijl RP Ambulance', description = message, type = type or 'inform' })
end

local function isAmbulance()
    local ok = lib.callback.await('delfzijlrp_ambulance:server:isAmbulance', false)
    if not ok then notify(Config.Text.noAccess, 'error') end
    return ok
end

local function getTargetDialog(title)
    local input = lib.inputDialog(title, {
        { type = 'number', label = 'Speler ID', required = true, min = 1 }
    })
    return input and tonumber(input[1]) or nil
end

local function openRecords()
    if not isAmbulance() then return end
    local targetId = getTargetDialog('Medisch dossier bekijken')
    if not targetId then return end

    local records = lib.callback.await('delfzijlrp_ambulance:server:getRecords', false, targetId) or {}
    local options = {}

    for _, record in ipairs(records) do
        options[#options + 1] = {
            title = record.record_type,
            description = record.created_at,
            icon = 'file-medical',
            metadata = {
                { label = 'Patiënt', value = record.patient_name or 'Onbekend' },
                { label = 'Medic', value = record.medic_name or 'Onbekend' },
                { label = 'Notitie', value = record.notes or '' }
            }
        }
    end

    if #options == 0 then
        options[#options + 1] = { title = 'Geen medische records', icon = 'circle-info', readOnly = true }
    end

    lib.registerContext({ id = 'delfzijlrp_ambulance_records', title = 'Medisch dossier', options = options })
    lib.showContext('delfzijlrp_ambulance_records')
end

local function addRecordDialog()
    if not isAmbulance() then return end
    local input = lib.inputDialog('Medisch record toevoegen', {
        { type = 'number', label = 'Speler ID', required = true, min = 1 },
        { type = 'input', label = 'Type', default = 'note', required = true, min = 2, max = 64 },
        { type = 'textarea', label = 'Notitie', required = true, min = 3, max = 1000 }
    })
    if not input then return end
    TriggerServerEvent('delfzijlrp_ambulance:server:addRecord', input[1], input[2], input[3])
end

local function openAmbulanceMenu()
    if not isAmbulance() then return end

    lib.registerContext({
        id = 'delfzijlrp_ambulance_menu',
        title = 'Ambulance Groningen',
        options = {
            { title = 'Meldkamer openen', icon = 'tower-broadcast', onSelect = function() ExecuteCommand('meldkamer') end },
            { title = 'MDT openen', icon = 'tablet-screen-button', onSelect = function() ExecuteCommand('mdt') end },
            { title = 'Patiënt reanimeren', icon = 'heart-pulse', onSelect = function()
                local targetId = getTargetDialog('Patiënt reanimeren')
                if targetId then TriggerServerEvent('delfzijlrp_ambulance:server:revivePlayer', targetId) end
            end },
            { title = 'Patiënt behandelen', icon = 'kit-medical', onSelect = function()
                local targetId = getTargetDialog('Patiënt behandelen')
                if targetId then TriggerServerEvent('delfzijlrp_ambulance:server:healPlayer', targetId) end
            end },
            { title = 'Medisch dossier bekijken', icon = 'file-medical', onSelect = openRecords },
            { title = 'Medisch record toevoegen', icon = 'file-circle-plus', onSelect = addRecordDialog },
            { title = 'Paniekknop', icon = 'triangle-exclamation', onSelect = function() ExecuteCommand('panic') end }
        }
    })

    lib.showContext('delfzijlrp_ambulance_menu')
end

CreateThread(function()
    Wait(1500)

    for _, hospital in ipairs(Config.Hospitals) do
        if hospital.blip then
            local blip = AddBlipForCoord(hospital.duty.x, hospital.duty.y, hospital.duty.z)
            SetBlipSprite(blip, hospital.blip.sprite)
            SetBlipColour(blip, hospital.blip.color)
            SetBlipScale(blip, hospital.blip.scale)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(hospital.label)
            EndTextCommandSetBlipName(blip)
        end

        exports.ox_target:addSphereZone({
            coords = hospital.duty,
            radius = 1.5,
            debug = Config.Debug,
            options = {{ name = 'ambulance_duty_' .. hospital.id, icon = 'fa-solid fa-user-doctor', label = Config.Text.duty, onSelect = function() TriggerServerEvent('delfzijlrp_ambulance:server:toggleDuty') end }}
        })

        exports.ox_target:addSphereZone({
            coords = hospital.storage,
            radius = 1.5,
            debug = Config.Debug,
            options = {{ name = 'ambulance_storage_' .. hospital.id, icon = 'fa-solid fa-box-medical', label = Config.Text.storage, onSelect = function() TriggerServerEvent('delfzijlrp_ambulance:server:openStorage', hospital.id) end }}
        })

        exports.ox_target:addSphereZone({
            coords = hospital.checkin,
            radius = 1.5,
            debug = Config.Debug,
            options = {{ name = 'ambulance_checkin_' .. hospital.id, icon = 'fa-solid fa-hospital', label = Config.Text.checkin, onSelect = function() TriggerServerEvent('delfzijlrp_ambulance:server:checkIn') end }}
        })
    end
end)

RegisterCommand(Config.Command, openAmbulanceMenu, false)

RegisterNetEvent('delfzijlrp_ambulance:client:heal', function()
    local ped = PlayerPedId()
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    ClearPedBloodDamage(ped)
end)

RegisterNetEvent('delfzijlrp_ambulance:client:hospitalHeal', function(duration)
    local success = lib.progressCircle({
        duration = duration or 10000,
        label = 'Behandeling in ziekenhuis...',
        position = 'bottom',
        useWhileDead = true,
        canCancel = false,
        disable = { car = true, move = true, combat = true }
    })
    if success then
        TriggerEvent('delfzijlrp_ambulance:client:heal')
        notify('Je bent behandeld in het ziekenhuis.', 'success')
    end
end)

RegisterNetEvent('delfzijlrp_ambulance:client:openStash', function(stashId)
    exports.ox_inventory:openInventory('stash', stashId)
end)
