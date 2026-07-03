local ESX = exports['es_extended']:getSharedObject()

local function notify(source, message, type)
    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Delfzijl RP Meldkamer',
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

local function canReceive(jobName, service)
    local serviceConfig = Config.Services[service]
    return serviceConfig and serviceConfig.jobs[jobName] == true
end

local function getCallerName(identifier, fallback)
    if not identifier then return fallback end
    local identity = MySQL.single.await('SELECT firstname, lastname FROM delfzijlrp_identities WHERE identifier = ? LIMIT 1', { identifier })
    if identity then return identity.firstname .. ' ' .. identity.lastname end
    return fallback
end

local function notifyService(service, report)
    local players = ESX.GetExtendedPlayers()
    for _, xPlayer in pairs(players) do
        if xPlayer.job and canReceive(xPlayer.job.name, service) then
            TriggerClientEvent('delfzijlrp_dispatch:client:newReport', xPlayer.source, report)
        end
    end
end

lib.callback.register('delfzijlrp_dispatch:server:hasAccess', function(source)
    return hasAccess(source), getJobName(source)
end)

lib.callback.register('delfzijlrp_dispatch:server:getReports', function(source)
    if not hasAccess(source) then return {} end

    local jobName = getJobName(source)
    local services = {}
    for service, data in pairs(Config.Services) do
        if data.jobs[jobName] then services[#services + 1] = service end
    end

    if #services == 0 then return {} end

    local placeholders = table.concat((function()
        local t = {}
        for _ = 1, #services do t[#t + 1] = '?' end
        return t
    end)(), ',')

    local query = ('SELECT * FROM delfzijlrp_dispatch_reports WHERE status IN ("open", "accepted") AND service IN (%s) ORDER BY created_at DESC LIMIT 50'):format(placeholders)
    return MySQL.query.await(query, services) or {}
end)

RegisterNetEvent('delfzijlrp_dispatch:server:createReport', function(reportType, message, coords)
    local source = source
    local xPlayer = getPlayer(source)
    local reportConfig = Config.ReportTypes[reportType]

    if not reportConfig or not message or #message < 3 then
        notify(source, Config.Text.invalidInput, 'error')
        return
    end

    local identifier = xPlayer and xPlayer.identifier or nil
    local callerName = getCallerName(identifier, GetPlayerName(source))
    local service = reportConfig.service

    local reportId = MySQL.insert.await([[INSERT INTO delfzijlrp_dispatch_reports
        (report_type, service, caller_identifier, caller_name, message, coords)
        VALUES (?, ?, ?, ?, ?, ?)]], {
        reportType,
        service,
        identifier,
        callerName,
        message,
        json.encode(coords)
    })

    local report = {
        id = reportId,
        report_type = reportType,
        service = service,
        caller_name = callerName,
        message = message,
        coords = json.encode(coords),
        status = 'open'
    }

    notify(source, Config.Text.reportSent, 'success')
    notifyService(service, report)
end)

RegisterNetEvent('delfzijlrp_dispatch:server:acceptReport', function(reportId)
    local source = source
    local xPlayer = getPlayer(source)
    if not xPlayer or not hasAccess(source) then return end

    reportId = tonumber(reportId)
    local report = MySQL.single.await('SELECT * FROM delfzijlrp_dispatch_reports WHERE id = ? LIMIT 1', { reportId })
    if not report or not canReceive(xPlayer.job.name, report.service) then return end

    MySQL.update.await('UPDATE delfzijlrp_dispatch_reports SET status = ?, accepted_by = ?, accepted_job = ? WHERE id = ?', {
        'accepted',
        xPlayer.identifier,
        xPlayer.job.name,
        reportId
    })

    notify(source, Config.Text.reportAccepted, 'success')
end)

RegisterNetEvent('delfzijlrp_dispatch:server:closeReport', function(reportId)
    local source = source
    local xPlayer = getPlayer(source)
    if not xPlayer or not hasAccess(source) then return end

    reportId = tonumber(reportId)
    local report = MySQL.single.await('SELECT * FROM delfzijlrp_dispatch_reports WHERE id = ? LIMIT 1', { reportId })
    if not report or not canReceive(xPlayer.job.name, report.service) then return end

    MySQL.update.await('UPDATE delfzijlrp_dispatch_reports SET status = ? WHERE id = ?', { 'closed', reportId })
    notify(source, Config.Text.reportClosed, 'success')
end)

RegisterNetEvent('delfzijlrp_dispatch:server:panic', function(coords)
    local source = source
    local xPlayer = getPlayer(source)
    if not xPlayer or not hasAccess(source) then return end

    local message = ('Paniekknop geactiveerd door %s'):format(GetPlayerName(source))
    local reportId = MySQL.insert.await([[INSERT INTO delfzijlrp_dispatch_reports
        (report_type, service, caller_identifier, caller_name, message, coords)
        VALUES (?, ?, ?, ?, ?, ?)]], {
        'panic',
        'police',
        xPlayer.identifier,
        GetPlayerName(source),
        message,
        json.encode(coords)
    })

    notify(source, Config.Text.panicSent, 'warning')
    notifyService('police', { id = reportId, report_type = 'panic', service = 'police', caller_name = GetPlayerName(source), message = message, coords = json.encode(coords), status = 'open' })
end)
