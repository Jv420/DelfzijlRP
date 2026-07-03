local function notify(message, type)
    lib.notify({ title = 'Rechtbank Delfzijl', description = message, type = type or 'inform' })
end

local function hasAccess()
    local ok = lib.callback.await('delfzijlrp_court:server:hasAccess', false)
    if not ok then notify(Config.Text.noAccess, 'error') end
    return ok
end

local function caseTypeOptions()
    local options = {}
    for value, label in pairs(Config.CaseTypes) do
        options[#options + 1] = { value = value, label = label }
    end
    return options
end

local function statusOptions()
    local options = {}
    for value, label in pairs(Config.CaseStatuses) do
        options[#options + 1] = { value = value, label = label }
    end
    return options
end

local function createCaseDialog()
    if not hasAccess() then return end
    local input = lib.inputDialog('Nieuw rechtbankdossier', {
        { type = 'select', label = 'Zaaktype', required = true, options = caseTypeOptions() },
        { type = 'input', label = 'Titel', required = true, min = 3, max = 128 },
        { type = 'textarea', label = 'Omschrijving', required = false, max = 1500 },
        { type = 'number', label = 'Speler ID verdachte/betrokkene', required = false, min = 1 }
    })
    if input then
        TriggerServerEvent('delfzijlrp_court:server:createCase', {
            case_type = input[1],
            title = input[2],
            description = input[3],
            suspect_id = input[4]
        })
    end
end

local function addNoteDialog(caseId)
    local input = lib.inputDialog('Notitie toevoegen', {
        { type = 'textarea', label = 'Notitie', required = true, min = 3, max = 1500 }
    })
    if input then TriggerServerEvent('delfzijlrp_court:server:addNote', caseId, input[1]) end
end

local function scheduleDialog(caseId)
    local input = lib.inputDialog('Zitting plannen', {
        { type = 'input', label = 'Datum/tijd', description = 'YYYY-MM-DD HH:MM:SS', required = true, min = 10, max = 19 },
        { type = 'number', label = 'Duur minuten', default = Config.DefaultHearingDuration, required = true, min = 5, max = 240 },
        { type = 'textarea', label = 'Notitie', required = false, max = 1000 }
    })
    if input then TriggerServerEvent('delfzijlrp_court:server:scheduleHearing', caseId, input[1], input[2], input[3]) end
end

local function verdictDialog(caseId)
    local input = lib.inputDialog('Dossier afronden/bijwerken', {
        { type = 'select', label = 'Status', required = true, options = statusOptions() },
        { type = 'textarea', label = 'Uitspraak/besluit', required = false, max = 1500 },
        { type = 'number', label = 'Boetebedrag', default = 0, required = true, min = 0, max = 1000000 }
    })
    if input then TriggerServerEvent('delfzijlrp_court:server:updateVerdict', caseId, input[1], input[2], input[3]) end
end

local function openCaseDetails(caseId)
    local data = lib.callback.await('delfzijlrp_court:server:getCaseDetails', false, caseId)
    if not data then notify(Config.Text.notFound, 'error') return end

    local c = data.case
    local options = {
        { title = c.case_number, description = c.title, icon = 'scale-balanced', readOnly = true },
        { title = 'Status', description = Config.CaseStatuses[c.status] or c.status, icon = 'circle-info', readOnly = true },
        { title = 'Betrokkene', description = c.suspect_name or 'Onbekend', icon = 'user', readOnly = true },
        { title = 'Omschrijving', description = c.description or 'Geen omschrijving', icon = 'align-left', readOnly = true },
        { title = 'Notitie toevoegen', icon = 'note-sticky', onSelect = function() addNoteDialog(c.id) end },
        { title = 'Zitting plannen', icon = 'calendar-plus', onSelect = function() scheduleDialog(c.id) end },
        { title = 'Uitspraak/status bijwerken', icon = 'gavel', onSelect = function() verdictDialog(c.id) end }
    }

    for _, hearing in ipairs(data.hearings or {}) do
        options[#options + 1] = {
            title = 'Zitting: ' .. hearing.scheduled_at,
            description = ('Duur: %s min | %s'):format(hearing.duration_minutes, hearing.notes or ''),
            icon = 'calendar-days',
            readOnly = true
        }
    end

    for _, note in ipairs(data.notes or {}) do
        options[#options + 1] = {
            title = 'Notitie van ' .. (note.author_name or 'Onbekend'),
            description = note.note,
            icon = 'note-sticky',
            readOnly = true
        }
    end

    lib.registerContext({ id = 'delfzijlrp_court_case_detail', title = c.title, options = options })
    lib.showContext('delfzijlrp_court_case_detail')
end

local function openCases(onlyOpen)
    if not hasAccess() then return end
    local cases = lib.callback.await('delfzijlrp_court:server:getCases', false, onlyOpen) or {}
    if #cases == 0 then notify(Config.Text.noCases, 'inform') return end

    local options = {}
    for _, c in ipairs(cases) do
        options[#options + 1] = {
            title = ('%s | %s'):format(c.case_number, c.title),
            description = ('%s | %s'):format(Config.CaseTypes[c.case_type] or c.case_type, Config.CaseStatuses[c.status] or c.status),
            icon = 'folder-open',
            onSelect = function() openCaseDetails(c.id) end
        }
    end

    lib.registerContext({ id = 'delfzijlrp_court_cases', title = onlyOpen and 'Open dossiers' or 'Alle dossiers', options = options })
    lib.showContext('delfzijlrp_court_cases')
end

local function openCourt()
    if not hasAccess() then return end
    lib.registerContext({
        id = 'delfzijlrp_court_main',
        title = Config.CourtHouse.label,
        options = {
            { title = 'Nieuw dossier', icon = 'folder-plus', onSelect = createCaseDialog },
            { title = 'Open dossiers', icon = 'folder-open', onSelect = function() openCases(true) end },
            { title = 'Alle dossiers', icon = 'boxes-stacked', onSelect = function() openCases(false) end },
            { title = 'MDT openen', icon = 'tablet-screen-button', onSelect = function() ExecuteCommand('mdt') end }
        }
    })
    lib.showContext('delfzijlrp_court_main')
end

CreateThread(function()
    Wait(1500)
    if Config.CourtHouse.blip then
        local blip = AddBlipForCoord(Config.CourtHouse.coords.x, Config.CourtHouse.coords.y, Config.CourtHouse.coords.z)
        SetBlipSprite(blip, Config.CourtHouse.blip.sprite)
        SetBlipColour(blip, Config.CourtHouse.blip.color)
        SetBlipScale(blip, Config.CourtHouse.blip.scale)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(Config.CourtHouse.label)
        EndTextCommandSetBlipName(blip)
    end

    exports.ox_target:addSphereZone({
        coords = Config.CourtHouse.coords,
        radius = Config.CourtHouse.radius,
        debug = Config.Debug,
        options = {{ name = 'court_open', icon = 'fa-solid fa-scale-balanced', label = Config.Text.openCourt, onSelect = openCourt }}
    })
end)

RegisterCommand(Config.Command, openCourt, false)
