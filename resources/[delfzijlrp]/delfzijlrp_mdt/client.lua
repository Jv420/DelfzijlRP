local function notify(message, type)
    lib.notify({ title = 'Delfzijl RP MDT', description = message, type = type or 'inform' })
end

local function openNotes(targetType, targetValue)
    local notes = lib.callback.await('delfzijlrp_mdt:server:getNotes', false, targetType, targetValue) or {}
    local options = {}

    for _, note in ipairs(notes) do
        options[#options + 1] = {
            title = note.title,
            description = ('%s | %s'):format(note.author_job, note.created_at),
            icon = 'note-sticky',
            metadata = {
                { label = 'Doel', value = note.target_value },
                { label = 'Notitie', value = note.body }
            }
        }
    end

    if #options == 0 then
        options[#options + 1] = { title = 'Geen notities gevonden', icon = 'circle-info', readOnly = true }
    end

    lib.registerContext({ id = 'delfzijlrp_mdt_notes', title = 'Notities', options = options })
    lib.showContext('delfzijlrp_mdt_notes')
end

local function createNoteDialog(targetType, targetValue)
    local input = lib.inputDialog('Notitie toevoegen', {
        { type = 'input', label = 'Titel', required = true, min = 3, max = 128 },
        { type = 'textarea', label = 'Notitie', required = true, min = 5, max = 1000 }
    })

    if not input then return end
    TriggerServerEvent('delfzijlrp_mdt:server:createNote', targetType, targetValue, input[1], input[2])
end

local function createFineDialog(person)
    local input = lib.inputDialog('Boete registreren', {
        { type = 'select', label = 'Categorie', required = true, options = {
            { value = 'traffic', label = 'Verkeer' },
            { value = 'public_order', label = 'Openbare orde' },
            { value = 'other', label = 'Overig' }
        }},
        { type = 'input', label = 'Reden', required = true, min = 3, max = 255 },
        { type = 'number', label = 'Bedrag', required = true, min = 1, max = 100000 }
    })

    if not input then return end
    local name = ('%s %s'):format(person.firstname, person.lastname)
    TriggerServerEvent('delfzijlrp_mdt:server:createFine', person.identifier, name, input[1], input[2], input[3])
end

local function openPersonResult(person)
    local name = ('%s %s'):format(person.firstname, person.lastname)

    lib.registerContext({
        id = 'delfzijlrp_mdt_person_result',
        title = name,
        options = {
            { title = 'Delfzijl ID', description = person.delfzijl_id, icon = 'id-card', readOnly = true },
            { title = 'Geboortedatum', description = person.dateofbirth, icon = 'cake-candles', readOnly = true },
            { title = 'Nationaliteit', description = person.nationality or 'Onbekend', icon = 'flag', readOnly = true },
            { title = 'Notities bekijken', icon = 'note-sticky', onSelect = function() openNotes('person', person.identifier) end },
            { title = 'Notitie toevoegen', icon = 'pen-to-square', onSelect = function() createNoteDialog('person', person.identifier) end },
            { title = 'Boete registreren', icon = 'file-invoice-dollar', onSelect = function() createFineDialog(person) end }
        }
    })

    lib.showContext('delfzijlrp_mdt_person_result')
end

local function searchPerson()
    local input = lib.inputDialog('Persoon zoeken', {
        { type = 'input', label = 'Naam of Delfzijl ID', required = true, min = 2 }
    })

    if not input then return end
    local results = lib.callback.await('delfzijlrp_mdt:server:searchPerson', false, input[1])

    if not results or #results == 0 then
        notify(Config.Text.noResults, 'error')
        return
    end

    local options = {}
    for _, person in ipairs(results) do
        options[#options + 1] = {
            title = ('%s %s'):format(person.firstname, person.lastname),
            description = person.delfzijl_id,
            icon = 'user',
            onSelect = function() openPersonResult(person) end
        }
    end

    lib.registerContext({ id = 'delfzijlrp_mdt_people_results', title = 'Persoon resultaten', options = options })
    lib.showContext('delfzijlrp_mdt_people_results')
end

local function openVehicleResult(vehicle)
    local ownerName = vehicle.firstname and (vehicle.firstname .. ' ' .. vehicle.lastname) or 'Onbekend'

    lib.registerContext({
        id = 'delfzijlrp_mdt_vehicle_result',
        title = ('Kenteken %s'):format(vehicle.plate),
        options = {
            { title = 'Eigenaar', description = ownerName, icon = 'user', readOnly = true },
            { title = 'VIN', description = vehicle.vin or 'Onbekend', icon = 'barcode', readOnly = true },
            { title = 'Kilometerstand', description = tostring(vehicle.mileage or 0) .. ' km', icon = 'gauge', readOnly = true },
            { title = 'APK', description = vehicle.apk_until or 'Onbekend', icon = 'screwdriver-wrench', readOnly = true },
            { title = 'Verzekering', description = ('%s tot %s'):format(vehicle.insurance_type or 'WA', vehicle.insurance_until or 'Onbekend'), icon = 'shield-halved', readOnly = true },
            { title = 'Gestolen-status', description = tonumber(vehicle.stolen) == 1 and 'Gesignaleerd' or 'Niet gesignaleerd', icon = 'triangle-exclamation', readOnly = true },
            { title = 'Notities bekijken', icon = 'note-sticky', onSelect = function() openNotes('vehicle', vehicle.plate) end },
            { title = 'Notitie toevoegen', icon = 'pen-to-square', onSelect = function() createNoteDialog('vehicle', vehicle.plate) end },
            { title = 'Als gestolen markeren', icon = 'triangle-exclamation', onSelect = function() TriggerServerEvent('delfzijlrp_mdt:server:setVehicleStolen', vehicle.plate, true) end },
            { title = 'Gestolen-status verwijderen', icon = 'circle-check', onSelect = function() TriggerServerEvent('delfzijlrp_mdt:server:setVehicleStolen', vehicle.plate, false) end }
        }
    })

    lib.showContext('delfzijlrp_mdt_vehicle_result')
end

local function searchVehicle()
    local input = lib.inputDialog('Kenteken zoeken', {
        { type = 'input', label = 'Kenteken', required = true, min = 2 }
    })

    if not input then return end
    local vehicle = lib.callback.await('delfzijlrp_mdt:server:searchVehicle', false, input[1])

    if not vehicle then
        notify(Config.Text.noResults, 'error')
        return
    end

    openVehicleResult(vehicle)
end

local function openMDT()
    local access, job = lib.callback.await('delfzijlrp_mdt:server:hasAccess', false)
    if not access then
        notify(Config.Text.noAccess, 'error')
        return
    end

    lib.registerContext({
        id = 'delfzijlrp_mdt_main',
        title = ('MDT | %s'):format(Config.JobLabels[job] or job),
        options = {
            { title = 'Persoon zoeken', icon = 'user-magnifying-glass', onSelect = searchPerson },
            { title = 'Kenteken zoeken', icon = 'car', onSelect = searchVehicle }
        }
    })

    lib.showContext('delfzijlrp_mdt_main')
end

RegisterCommand(Config.Command, openMDT, false)
