local function notify(message, type)
    lib.notify({ title = 'Delfzijl RP MDT v2', description = message, type = type or 'inform' })
end

local function hasAccess()
    local ok = lib.callback.await('delfzijlrp_mdt_v2:server:hasAccess', false)
    if not ok then notify(Config.Text.noAccess, 'error') end
    return ok
end

local function noteDialog(targetType, targetValue)
    local input = lib.inputDialog('Notitie toevoegen', {
        { type = 'input', label = 'Type', default = 'note', required = true, min = 2, max = 64 },
        { type = 'textarea', label = 'Notitie', required = true, min = 3, max = 1500 }
    })
    if input then
        TriggerServerEvent('delfzijlrp_mdt_v2:server:addNote', targetType, targetValue, input[1], input[2])
    end
end

local function fineDialog(identifier)
    local options = {}
    for value, label in pairs(Config.FineCategories) do
        options[#options + 1] = { value = value, label = label }
    end
    local input = lib.inputDialog('Boete registreren', {
        { type = 'select', label = 'Categorie', required = true, options = options },
        { type = 'input', label = 'Reden', required = true, min = 3, max = 255 },
        { type = 'number', label = 'Bedrag', required = true, min = 1, max = 1000000 }
    })
    if input then
        TriggerServerEvent('delfzijlrp_mdt_v2:server:createFine', identifier, input[1], input[2], input[3])
    end
end

local function openPerson(identifier)
    local data = lib.callback.await('delfzijlrp_mdt_v2:server:getPerson', false, identifier)
    if not data then notify(Config.Text.notFound, 'error') return end
    local p = data.identity
    local options = {
        { title = p.firstname .. ' ' .. p.lastname, description = p.delfzijl_id or p.identifier, icon = 'id-card', readOnly = true },
        { title = 'Geboortedatum', description = p.dateofbirth or 'Onbekend', icon = 'cake-candles', readOnly = true },
        { title = 'Notitie toevoegen', icon = 'note-sticky', onSelect = function() noteDialog('person', p.identifier) end },
        { title = 'Boete registreren', icon = 'file-invoice-dollar', onSelect = function() fineDialog(p.identifier) end }
    }

    for _, vehicle in ipairs(data.vehicles or {}) do
        options[#options + 1] = { title = 'Voertuig: ' .. vehicle.plate, description = vehicle.model or vehicle.vin or '', icon = 'car', readOnly = true }
    end
    for _, fine in ipairs(data.fines or {}) do
        options[#options + 1] = { title = 'Boete: €' .. fine.amount, description = fine.reason .. ' | ' .. fine.status, icon = 'receipt', readOnly = true }
    end
    for _, note in ipairs(data.notes or {}) do
        options[#options + 1] = { title = 'Notitie: ' .. note.note_type, description = note.note, icon = 'note-sticky', readOnly = true }
    end
    for _, record in ipairs(data.medical or {}) do
        options[#options + 1] = { title = 'Medisch: ' .. record.record_type, description = record.notes or '', icon = 'kit-medical', readOnly = true }
    end
    for _, case in ipairs(data.court or {}) do
        options[#options + 1] = { title = 'Rechtbank: ' .. case.case_number, description = case.title .. ' | ' .. case.status, icon = 'scale-balanced', readOnly = true }
    end

    lib.registerContext({ id = 'delfzijlrp_mdt_person', title = 'Persoonsdossier', options = options })
    lib.showContext('delfzijlrp_mdt_person')
end

local function searchPeople()
    if not hasAccess() then return end
    local input = lib.inputDialog('Persoon zoeken', {
        { type = 'input', label = 'Naam of Delfzijl ID', required = true, min = 2, max = 64 }
    })
    if not input then return end
    local results = lib.callback.await('delfzijlrp_mdt_v2:server:searchPeople', false, input[1]) or {}
    if #results == 0 then notify(Config.Text.notFound, 'inform') return end

    local options = {}
    for _, person in ipairs(results) do
        options[#options + 1] = {
            title = person.firstname .. ' ' .. person.lastname,
            description = person.delfzijl_id or person.identifier,
            icon = 'user',
            onSelect = function() openPerson(person.identifier) end
        }
    end
    lib.registerContext({ id = 'delfzijlrp_mdt_people_results', title = 'Personen', options = options })
    lib.showContext('delfzijlrp_mdt_people_results')
end

local function openVehicle(plate)
    local data = lib.callback.await('delfzijlrp_mdt_v2:server:getVehicle', false, plate)
    if not data then notify(Config.Text.notFound, 'error') return end
    local v = data.vehicle
    local owner = v.firstname and (v.firstname .. ' ' .. v.lastname) or 'Onbekend'
    local options = {
        { title = v.plate, description = v.model or v.vin or 'Voertuig', icon = 'car', readOnly = true },
        { title = 'Eigenaar', description = owner, icon = 'user', readOnly = true },
        { title = 'APK', description = v.apk_until or 'Onbekend', icon = 'screwdriver-wrench', readOnly = true },
        { title = 'Verzekering', description = (v.insurance_type or 'WA') .. ' tot ' .. (v.insurance_until or 'Onbekend'), icon = 'shield-halved', readOnly = true },
        { title = 'Gestolen', description = tonumber(v.stolen) == 1 and 'Ja' or 'Nee', icon = 'triangle-exclamation', readOnly = true },
        { title = 'In beslag', description = tonumber(v.impounded) == 1 and 'Ja' or 'Nee', icon = 'warehouse', readOnly = true },
        { title = 'Voertuignotitie toevoegen', icon = 'note-sticky', onSelect = function() noteDialog('vehicle', v.plate) end }
    }
    for _, note in ipairs(data.notes or {}) do
        options[#options + 1] = { title = 'Notitie: ' .. note.note_type, description = note.note, icon = 'note-sticky', readOnly = true }
    end
    lib.registerContext({ id = 'delfzijlrp_mdt_vehicle', title = 'Voertuigdossier', options = options })
    lib.showContext('delfzijlrp_mdt_vehicle')
end

local function searchVehicles()
    if not hasAccess() then return end
    local input = lib.inputDialog('Voertuig zoeken', {
        { type = 'input', label = 'Kenteken, VIN of model', required = true, min = 2, max = 64 }
    })
    if not input then return end
    local results = lib.callback.await('delfzijlrp_mdt_v2:server:searchVehicles', false, input[1]) or {}
    if #results == 0 then notify(Config.Text.notFound, 'inform') return end
    local options = {}
    for _, vehicle in ipairs(results) do
        local owner = vehicle.firstname and (vehicle.firstname .. ' ' .. vehicle.lastname) or 'Onbekend'
        options[#options + 1] = { title = vehicle.plate, description = owner .. ' | ' .. (vehicle.model or ''), icon = 'car', onSelect = function() openVehicle(vehicle.plate) end }
    end
    lib.registerContext({ id = 'delfzijlrp_mdt_vehicle_results', title = 'Voertuigen', options = options })
    lib.showContext('delfzijlrp_mdt_vehicle_results')
end

local function openDispatch()
    if not hasAccess() then return end
    local reports = lib.callback.await('delfzijlrp_mdt_v2:server:getDispatch', false) or {}
    local options = {}
    for _, report in ipairs(reports) do
        options[#options + 1] = { title = '#' .. report.id .. ' | ' .. report.service, description = report.message .. ' | ' .. report.status, icon = 'tower-broadcast', readOnly = true }
    end
    if #options == 0 then options[#options + 1] = { title = 'Geen open meldingen', icon = 'circle-info', readOnly = true } end
    lib.registerContext({ id = 'delfzijlrp_mdt_dispatch', title = 'Dispatch meldingen', options = options })
    lib.showContext('delfzijlrp_mdt_dispatch')
end

local function openCourtCases()
    if not hasAccess() then return end
    local cases = lib.callback.await('delfzijlrp_mdt_v2:server:getCourtCases', false) or {}
    local options = {}
    for _, case in ipairs(cases) do
        options[#options + 1] = { title = case.case_number, description = case.title .. ' | ' .. case.status, icon = 'scale-balanced', readOnly = true }
    end
    if #options == 0 then options[#options + 1] = { title = 'Geen rechtbankdossiers', icon = 'circle-info', readOnly = true } end
    lib.registerContext({ id = 'delfzijlrp_mdt_court', title = 'Rechtbankdossiers', options = options })
    lib.showContext('delfzijlrp_mdt_court')
end

local function openMdt()
    if not hasAccess() then return end
    lib.registerContext({
        id = 'delfzijlrp_mdt_v2_main',
        title = 'Delfzijl RP MDT v2',
        options = {
            { title = 'Persoon zoeken', icon = 'user-magnifying-glass', onSelect = searchPeople },
            { title = 'Voertuig/RDW zoeken', icon = 'car', onSelect = searchVehicles },
            { title = 'Dispatch meldingen', icon = 'tower-broadcast', onSelect = openDispatch },
            { title = 'Rechtbankdossiers', icon = 'scale-balanced', onSelect = openCourtCases },
            { title = 'Oude MDT openen', description = '/mdt als je deze command wijzigt', icon = 'tablet-screen-button', onSelect = function() ExecuteCommand('mdt') end }
        }
    })
    lib.showContext('delfzijlrp_mdt_v2_main')
end

RegisterCommand(Config.Command, openMdt, false)
RegisterCommand(Config.LegacyCommand, openMdt, false)
