local ESX = exports['es_extended']:getSharedObject()

local function notify(source, message, type)
    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Delfzijl RP MDT',
        description = message,
        type = type or 'inform'
    })
end

local function getPlayer(source)
    return ESX.GetPlayerFromId(source)
end

local function getJobName(source)
    local xPlayer = getPlayer(source)
    return xPlayer and xPlayer.job and xPlayer.job.name or nil
end

local function hasAccess(source)
    local job = getJobName(source)
    return job and Config.AllowedJobs[job] == true
end

local function can(source, permission)
    local job = getJobName(source)
    return job and Config.Permissions[permission] and Config.Permissions[permission][job] == true
end

local function trimPlate(plate)
    return plate and plate:gsub('^%s*(.-)%s*$', '%1') or ''
end

lib.callback.register('delfzijlrp_mdt:server:hasAccess', function(source)
    return hasAccess(source), getJobName(source)
end)

lib.callback.register('delfzijlrp_mdt:server:searchPerson', function(source, query)
    if not can(source, 'peopleSearch') then return nil end
    query = ('%%%s%%'):format(query or '')

    return MySQL.query.await([[SELECT identifier, delfzijl_id, firstname, lastname, dateofbirth, sex, nationality, birthplace
        FROM delfzijlrp_identities
        WHERE delfzijl_id LIKE ? OR firstname LIKE ? OR lastname LIKE ?
        LIMIT 20]], { query, query, query }) or {}
end)

lib.callback.register('delfzijlrp_mdt:server:searchVehicle', function(source, plate)
    if not can(source, 'vehicleSearch') then return nil end
    plate = trimPlate(plate)

    return MySQL.single.await([[SELECT r.*, i.firstname, i.lastname, i.delfzijl_id
        FROM delfzijlrp_vehicle_registry r
        LEFT JOIN delfzijlrp_identities i ON i.identifier = r.owner
        WHERE r.plate = ? LIMIT 1]], { plate })
end)

lib.callback.register('delfzijlrp_mdt:server:getNotes', function(source, targetType, targetValue)
    if not hasAccess(source) then return {} end

    return MySQL.query.await([[SELECT id, author_job, target_type, target_value, title, body, created_at
        FROM delfzijlrp_mdt_notes
        WHERE target_type = ? AND target_value = ?
        ORDER BY created_at DESC
        LIMIT 30]], { targetType, targetValue }) or {}
end)

RegisterNetEvent('delfzijlrp_mdt:server:createNote', function(targetType, targetValue, title, body)
    local source = source
    if not can(source, 'createNote') then
        notify(source, Config.Text.notAllowed, 'error')
        return
    end

    local xPlayer = getPlayer(source)
    if not xPlayer or not targetType or not targetValue or not title or not body then
        notify(source, Config.Text.invalidInput, 'error')
        return
    end

    MySQL.insert.await([[INSERT INTO delfzijlrp_mdt_notes
        (author_identifier, author_job, target_type, target_value, title, body)
        VALUES (?, ?, ?, ?, ?, ?)]], {
        xPlayer.identifier,
        xPlayer.job.name,
        targetType,
        targetValue,
        title,
        body
    })

    notify(source, Config.Text.noteCreated, 'success')
end)

RegisterNetEvent('delfzijlrp_mdt:server:createFine', function(targetIdentifier, targetName, fineType, reason, amount)
    local source = source
    if not can(source, 'createFine') then
        notify(source, Config.Text.notAllowed, 'error')
        return
    end

    local xPlayer = getPlayer(source)
    amount = tonumber(amount) or 0
    if not xPlayer or not reason or amount <= 0 then
        notify(source, Config.Text.invalidInput, 'error')
        return
    end

    if not Config.FineTypes[fineType] then fineType = 'other' end

    MySQL.insert.await([[INSERT INTO delfzijlrp_mdt_fines
        (author_identifier, target_identifier, target_name, fine_type, reason, amount)
        VALUES (?, ?, ?, ?, ?, ?)]], {
        xPlayer.identifier,
        targetIdentifier,
        targetName,
        fineType,
        reason,
        amount
    })

    notify(source, Config.Text.fineCreated, 'success')
end)

RegisterNetEvent('delfzijlrp_mdt:server:setVehicleStolen', function(plate, state)
    local source = source
    if not can(source, 'markStolen') then
        notify(source, Config.Text.notAllowed, 'error')
        return
    end

    plate = trimPlate(plate)
    TriggerEvent('delfzijlrp_vehicles:server:setStolen', plate, state == true)
    MySQL.update.await('UPDATE delfzijlrp_vehicle_registry SET stolen = ? WHERE plate = ?', { state and 1 or 0, plate })
    notify(source, Config.Text.vehicleUpdated, 'success')
end)
