local ESX = exports['es_extended']:getSharedObject()

local function getPlayer(source)
    return ESX.GetPlayerFromId(source)
end

local function getIdentifier(source)
    local xPlayer = getPlayer(source)
    return xPlayer and xPlayer.identifier or nil
end

local function notify(source, message, type)
    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Delfzijl RP MDT v2',
        description = message,
        type = type or 'inform'
    })
end

local function getAccess(source)
    local xPlayer = getPlayer(source)
    if not xPlayer or not xPlayer.job then return nil end
    return Config.AccessJobs[xPlayer.job.name], xPlayer.job.name
end

local function hasAccess(source)
    return getAccess(source) ~= nil
end

local function audit(source, action, query)
    MySQL.insert.await('INSERT INTO delfzijlrp_mdt_audit (identifier, player_name, action, query) VALUES (?, ?, ?, ?)', {
        getIdentifier(source),
        GetPlayerName(source),
        action,
        query
    })
end

local function identityName(identifier, fallback)
    local row = MySQL.single.await('SELECT firstname, lastname FROM delfzijlrp_identities WHERE identifier = ? LIMIT 1', { identifier })
    if row then return row.firstname .. ' ' .. row.lastname end
    return fallback
end

lib.callback.register('delfzijlrp_mdt_v2:server:hasAccess', function(source)
    local access, job = getAccess(source)
    return access ~= nil, access, job
end)

lib.callback.register('delfzijlrp_mdt_v2:server:searchPeople', function(source, query)
    if not hasAccess(source) then return {} end
    query = tostring(query or '')
    if #query < 2 then return {} end
    audit(source, 'search_people', query)

    local like = '%' .. query .. '%'
    return MySQL.query.await([[SELECT identifier, delfzijl_id, firstname, lastname, dateofbirth, nationality, birthplace
        FROM delfzijlrp_identities
        WHERE firstname LIKE ? OR lastname LIKE ? OR delfzijl_id LIKE ?
        ORDER BY lastname ASC LIMIT ?]], { like, like, like, Config.SearchLimits.people }) or {}
end)

lib.callback.register('delfzijlrp_mdt_v2:server:getPerson', function(source, identifier)
    if not hasAccess(source) then return nil end
    audit(source, 'get_person', identifier)

    local identity = MySQL.single.await('SELECT * FROM delfzijlrp_identities WHERE identifier = ? LIMIT 1', { identifier })
    if not identity then return nil end

    local vehicles = MySQL.query.await('SELECT * FROM delfzijlrp_vehicle_registry WHERE owner = ? ORDER BY created_at DESC LIMIT 30', { identifier }) or {}
    local notes = MySQL.query.await('SELECT * FROM delfzijlrp_mdt_notes WHERE target_identifier = ? ORDER BY created_at DESC LIMIT 30', { identifier }) or {}
    local fines = MySQL.query.await('SELECT * FROM delfzijlrp_mdt_fines WHERE target_identifier = ? ORDER BY created_at DESC LIMIT 30', { identifier }) or {}
    local medical = MySQL.query.await('SELECT * FROM delfzijlrp_medical_records WHERE patient_identifier = ? ORDER BY created_at DESC LIMIT 15', { identifier }) or {}
    local court = MySQL.query.await('SELECT * FROM delfzijlrp_court_cases WHERE suspect_identifier = ? ORDER BY updated_at DESC LIMIT 15', { identifier }) or {}

    return { identity = identity, vehicles = vehicles, notes = notes, fines = fines, medical = medical, court = court }
end)

lib.callback.register('delfzijlrp_mdt_v2:server:searchVehicles', function(source, query)
    if not hasAccess(source) then return {} end
    query = tostring(query or '')
    if #query < 2 then return {} end
    audit(source, 'search_vehicle', query)

    local like = '%' .. query .. '%'
    return MySQL.query.await([[SELECT r.*, i.firstname, i.lastname, i.delfzijl_id
        FROM delfzijlrp_vehicle_registry r
        LEFT JOIN delfzijlrp_identities i ON i.identifier = r.owner
        WHERE r.plate LIKE ? OR r.vin LIKE ? OR r.model LIKE ?
        ORDER BY r.updated_at DESC LIMIT ?]], { like, like, like, Config.SearchLimits.vehicles }) or {}
end)

lib.callback.register('delfzijlrp_mdt_v2:server:getVehicle', function(source, plate)
    if not hasAccess(source) then return nil end
    plate = tostring(plate or ''):gsub('^%s*(.-)%s*$', '%1')
    audit(source, 'get_vehicle', plate)

    local vehicle = MySQL.single.await([[SELECT r.*, i.firstname, i.lastname, i.delfzijl_id
        FROM delfzijlrp_vehicle_registry r
        LEFT JOIN delfzijlrp_identities i ON i.identifier = r.owner
        WHERE r.plate = ? LIMIT 1]], { plate })
    if not vehicle then return nil end

    local notes = MySQL.query.await('SELECT * FROM delfzijlrp_mdt_notes WHERE target_plate = ? ORDER BY created_at DESC LIMIT 30', { plate }) or {}
    return { vehicle = vehicle, notes = notes }
end)

lib.callback.register('delfzijlrp_mdt_v2:server:getDispatch', function(source)
    if not hasAccess(source) then return {} end
    audit(source, 'get_dispatch', nil)
    return MySQL.query.await('SELECT * FROM delfzijlrp_dispatch_reports WHERE status IN (?, ?) ORDER BY created_at DESC LIMIT ?', {
        'open',
        'accepted',
        Config.SearchLimits.dispatch
    }) or {}
end)

lib.callback.register('delfzijlrp_mdt_v2:server:getCourtCases', function(source)
    if not hasAccess(source) then return {} end
    return MySQL.query.await('SELECT * FROM delfzijlrp_court_cases ORDER BY updated_at DESC LIMIT ?', { Config.SearchLimits.cases }) or {}
end)

RegisterNetEvent('delfzijlrp_mdt_v2:server:addNote', function(targetType, targetValue, noteType, note)
    local source = source
    if not hasAccess(source) then return end
    if not note or #note < 3 then
        notify(source, Config.Text.invalidInput, 'error')
        return
    end

    local identifier, plate = nil, nil
    if targetType == 'person' then identifier = targetValue end
    if targetType == 'vehicle' then plate = tostring(targetValue or ''):gsub('^%s*(.-)%s*$', '%1') end

    MySQL.insert.await([[INSERT INTO delfzijlrp_mdt_notes
        (target_identifier, target_plate, author_identifier, author_name, note_type, note)
        VALUES (?, ?, ?, ?, ?, ?)]], {
        identifier,
        plate,
        getIdentifier(source),
        GetPlayerName(source),
        noteType or 'note',
        note
    })

    audit(source, 'add_note', targetType .. ':' .. tostring(targetValue))
    notify(source, Config.Text.recordAdded, 'success')
end)

RegisterNetEvent('delfzijlrp_mdt_v2:server:createFine', function(targetIdentifier, category, reason, amount)
    local source = source
    if not hasAccess(source) then return end
    amount = tonumber(amount) or 0
    if not targetIdentifier or not reason or #reason < 3 or amount <= 0 then
        notify(source, Config.Text.invalidInput, 'error')
        return
    end

    local targetName = identityName(targetIdentifier, 'Onbekend')
    MySQL.insert.await([[INSERT INTO delfzijlrp_mdt_fines
        (target_identifier, target_name, issuer_identifier, issuer_name, category, reason, amount)
        VALUES (?, ?, ?, ?, ?, ?, ?)]], {
        targetIdentifier,
        targetName,
        getIdentifier(source),
        GetPlayerName(source),
        category or 'other',
        reason,
        amount
    })

    audit(source, 'create_fine', targetIdentifier .. ':' .. tostring(amount))
    notify(source, Config.Text.fineCreated, 'success')
end)

AddEventHandler('delfzijlrp_mdt:server:createFine', function(targetIdentifier, targetName, category, reason, amount)
    MySQL.insert.await([[INSERT INTO delfzijlrp_mdt_fines
        (target_identifier, target_name, category, reason, amount)
        VALUES (?, ?, ?, ?, ?)]], { targetIdentifier, targetName, category or 'other', reason or 'Boete', tonumber(amount) or 0 })
end)
