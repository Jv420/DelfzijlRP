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
        title = 'Rechtbank Delfzijl',
        description = message,
        type = type or 'inform'
    })
end

local function hasAccess(source)
    local xPlayer = getPlayer(source)
    if not xPlayer or not xPlayer.job then return false end
    return Config.JobAccess[xPlayer.job.name] == true
end

local function createCaseNumber()
    local number
    repeat
        number = ('DRP-%s-%s'):format(os.date('%Y'), math.random(10000, 99999))
    until not MySQL.scalar.await('SELECT id FROM delfzijlrp_court_cases WHERE case_number = ? LIMIT 1', { number })
    return number
end

local function getIdentityName(identifier, fallback)
    if not identifier then return fallback end
    local identity = MySQL.single.await('SELECT firstname, lastname FROM delfzijlrp_identities WHERE identifier = ? LIMIT 1', { identifier })
    if identity then return identity.firstname .. ' ' .. identity.lastname end
    return fallback
end

lib.callback.register('delfzijlrp_court:server:hasAccess', function(source)
    return hasAccess(source)
end)

lib.callback.register('delfzijlrp_court:server:getCases', function(source, onlyOpen)
    if not hasAccess(source) then return {} end
    if onlyOpen then
        return MySQL.query.await('SELECT * FROM delfzijlrp_court_cases WHERE status IN (?, ?) ORDER BY updated_at DESC LIMIT 50', { 'open', 'scheduled' }) or {}
    end
    return MySQL.query.await('SELECT * FROM delfzijlrp_court_cases ORDER BY updated_at DESC LIMIT 50') or {}
end)

lib.callback.register('delfzijlrp_court:server:getCaseDetails', function(source, caseId)
    if not hasAccess(source) then return nil end
    caseId = tonumber(caseId)
    if not caseId then return nil end

    local case = MySQL.single.await('SELECT * FROM delfzijlrp_court_cases WHERE id = ? LIMIT 1', { caseId })
    if not case then return nil end

    local hearings = MySQL.query.await('SELECT * FROM delfzijlrp_court_hearings WHERE case_id = ? ORDER BY scheduled_at DESC', { caseId }) or {}
    local notes = MySQL.query.await('SELECT * FROM delfzijlrp_court_notes WHERE case_id = ? ORDER BY created_at DESC', { caseId }) or {}
    return { case = case, hearings = hearings, notes = notes }
end)

RegisterNetEvent('delfzijlrp_court:server:createCase', function(data)
    local source = source
    if not hasAccess(source) or type(data) ~= 'table' then return end

    local title = tostring(data.title or '')
    local caseType = data.case_type or 'other'
    local suspectId = tonumber(data.suspect_id)
    local suspectIdentifier = nil
    local suspectName = nil

    if #title < 3 or not Config.CaseTypes[caseType] then
        notify(source, Config.Text.invalidInput, 'error')
        return
    end

    if suspectId and GetPlayerName(suspectId) then
        local target = getPlayer(suspectId)
        suspectIdentifier = target and target.identifier or nil
        suspectName = getIdentityName(suspectIdentifier, GetPlayerName(suspectId))
    end

    local caseNumber = createCaseNumber()
    MySQL.insert.await([[INSERT INTO delfzijlrp_court_cases
        (case_number, case_type, title, description, suspect_identifier, suspect_name, created_by)
        VALUES (?, ?, ?, ?, ?, ?, ?)]], {
        caseNumber,
        caseType,
        title,
        data.description or '',
        suspectIdentifier,
        suspectName,
        getIdentifier(source)
    })

    notify(source, Config.Text.caseCreated, 'success')
end)

RegisterNetEvent('delfzijlrp_court:server:addNote', function(caseId, note)
    local source = source
    if not hasAccess(source) then return end
    caseId = tonumber(caseId)
    if not caseId or not note or #note < 3 then
        notify(source, Config.Text.invalidInput, 'error')
        return
    end

    MySQL.insert.await('INSERT INTO delfzijlrp_court_notes (case_id, author_identifier, author_name, note) VALUES (?, ?, ?, ?)', {
        caseId,
        getIdentifier(source),
        GetPlayerName(source),
        note
    })
    notify(source, Config.Text.caseUpdated, 'success')
end)

RegisterNetEvent('delfzijlrp_court:server:scheduleHearing', function(caseId, scheduledAt, duration, notes)
    local source = source
    if not hasAccess(source) then return end
    caseId = tonumber(caseId)
    duration = tonumber(duration) or Config.DefaultHearingDuration
    if not caseId or not scheduledAt or #scheduledAt < 10 then
        notify(source, Config.Text.invalidInput, 'error')
        return
    end

    MySQL.insert.await([[INSERT INTO delfzijlrp_court_hearings
        (case_id, scheduled_at, duration_minutes, notes, created_by)
        VALUES (?, ?, ?, ?, ?)]], {
        caseId,
        scheduledAt,
        duration,
        notes or '',
        getIdentifier(source)
    })
    MySQL.update.await('UPDATE delfzijlrp_court_cases SET status = ? WHERE id = ?', { 'scheduled', caseId })
    notify(source, Config.Text.hearingCreated, 'success')
end)

RegisterNetEvent('delfzijlrp_court:server:updateVerdict', function(caseId, status, verdict, fineAmount)
    local source = source
    if not hasAccess(source) then return end
    caseId = tonumber(caseId)
    fineAmount = tonumber(fineAmount) or 0
    if not caseId or not Config.CaseStatuses[status] then
        notify(source, Config.Text.invalidInput, 'error')
        return
    end

    MySQL.update.await('UPDATE delfzijlrp_court_cases SET status = ?, verdict = ?, fine_amount = ? WHERE id = ?', {
        status,
        verdict or '',
        fineAmount,
        caseId
    })
    notify(source, Config.Text.caseUpdated, 'success')
end)
