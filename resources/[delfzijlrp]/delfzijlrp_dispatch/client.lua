local function notify(message, type)
    lib.notify({ title = 'Delfzijl RP Meldkamer', description = message, type = type or 'inform' })
end

local function decodeCoords(coords)
    if type(coords) == 'string' then
        local ok, decoded = pcall(json.decode, coords)
        if ok then return decoded end
    end
    return coords
end

local function createReportDialog()
    local options = {}
    for value, data in pairs(Config.ReportTypes) do
        options[#options + 1] = { value = value, label = data.label }
    end

    local input = lib.inputDialog('Nieuwe melding', {
        { type = 'select', label = 'Soort melding', required = true, options = options },
        { type = 'textarea', label = 'Omschrijving', required = true, min = 3, max = 500 }
    })

    if not input then return end
    local coords = GetEntityCoords(PlayerPedId())
    TriggerServerEvent('delfzijlrp_dispatch:server:createReport', input[1], input[2], { x = coords.x, y = coords.y, z = coords.z })
end

local function openReport(report)
    local coords = decodeCoords(report.coords)

    lib.registerContext({
        id = 'delfzijlrp_dispatch_report',
        title = ('Melding #%s'):format(report.id),
        options = {
            { title = 'Melder', description = report.caller_name or 'Onbekend', icon = 'user', readOnly = true },
            { title = 'Omschrijving', description = report.message, icon = 'message', readOnly = true },
            { title = 'Status', description = report.status, icon = 'circle-info', readOnly = true },
            { title = 'Waypoint zetten', icon = 'location-dot', onSelect = function()
                if coords then
                    SetNewWaypoint(coords.x, coords.y)
                    notify('Waypoint ingesteld.', 'success')
                end
            end },
            { title = 'Melding aannemen', icon = 'check', onSelect = function() TriggerServerEvent('delfzijlrp_dispatch:server:acceptReport', report.id) end },
            { title = 'Melding afsluiten', icon = 'xmark', onSelect = function() TriggerServerEvent('delfzijlrp_dispatch:server:closeReport', report.id) end }
        }
    })

    lib.showContext('delfzijlrp_dispatch_report')
end

local function openDispatch()
    local access = lib.callback.await('delfzijlrp_dispatch:server:hasAccess', false)
    if not access then
        notify(Config.Text.noAccess, 'error')
        return
    end

    local reports = lib.callback.await('delfzijlrp_dispatch:server:getReports', false) or {}
    if #reports == 0 then
        notify(Config.Text.noReports, 'inform')
        return
    end

    local options = {}
    for _, report in ipairs(reports) do
        local label = Config.ReportTypes[report.report_type] and Config.ReportTypes[report.report_type].label or report.report_type
        options[#options + 1] = {
            title = ('#%s | %s'):format(report.id, label),
            description = ('%s | %s'):format(report.caller_name or 'Onbekend', report.status),
            icon = 'tower-broadcast',
            onSelect = function() openReport(report) end
        }
    end

    lib.registerContext({ id = 'delfzijlrp_dispatch_main', title = 'Meldkamer', options = options })
    lib.showContext('delfzijlrp_dispatch_main')
end

RegisterCommand(Config.ReportCommand, createReportDialog, false)
RegisterCommand(Config.Command, openDispatch, false)
RegisterCommand(Config.PanicCommand, function()
    local coords = GetEntityCoords(PlayerPedId())
    TriggerServerEvent('delfzijlrp_dispatch:server:panic', { x = coords.x, y = coords.y, z = coords.z })
end, false)

RegisterNetEvent('delfzijlrp_dispatch:client:newReport', function(report)
    local label = Config.ReportTypes[report.report_type] and Config.ReportTypes[report.report_type].label or report.report_type
    lib.notify({
        title = 'Nieuwe melding',
        description = ('%s: %s'):format(label, report.message),
        type = report.report_type == 'panic' and 'warning' or 'inform',
        duration = 10000
    })
end)
