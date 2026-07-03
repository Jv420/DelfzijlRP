local ESX = exports['es_extended']:getSharedObject()
local cooldowns = {}

local function getPlayer(source)
    return ESX.GetPlayerFromId(source)
end

local function getIdentifier(source)
    local xPlayer = getPlayer(source)
    return xPlayer and xPlayer.identifier or nil
end

local function notify(source, message, type)
    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Delfzijl RP Haven',
        description = message,
        type = type or 'inform'
    })
end

local function getCargo(cargoType)
    return Config.CargoTypes[cargoType]
end

local function getTerminal(terminalId)
    for _, terminal in ipairs(Config.Terminals) do
        if terminal.id == terminalId then return terminal end
    end
    return nil
end

local function logPort(jobId, source, action, details)
    MySQL.insert.await('INSERT INTO delfzijlrp_port_logs (job_id, identifier, action, details) VALUES (?, ?, ?, ?)', {
        jobId,
        getIdentifier(source),
        action,
        details
    })
end

lib.callback.register('delfzijlrp_port:server:getActiveJob', function(source)
    local identifier = getIdentifier(source)
    if not identifier then return nil end

    return MySQL.single.await('SELECT * FROM delfzijlrp_port_jobs WHERE identifier = ? AND status != ? ORDER BY created_at DESC LIMIT 1', {
        identifier,
        'delivered'
    })
end)

lib.callback.register('delfzijlrp_port:server:getStats', function(source)
    local identifier = getIdentifier(source)
    if not identifier then return nil end

    return MySQL.single.await([[SELECT COUNT(*) as jobs, COALESCE(SUM(payout), 0) as earned
        FROM delfzijlrp_port_jobs WHERE identifier = ? AND status = ?]], { identifier, 'delivered' })
end)

RegisterNetEvent('delfzijlrp_port:server:startJob', function(terminalId, cargoType)
    local source = source
    local identifier = getIdentifier(source)
    local terminal = getTerminal(terminalId)
    local cargo = getCargo(cargoType)
    if not identifier or not terminal or not cargo then
        notify(source, Config.Text.invalidInput, 'error')
        return
    end

    if cooldowns[identifier] and cooldowns[identifier] > os.time() then
        notify(source, Config.Text.cooldown, 'error')
        return
    end

    local active = MySQL.scalar.await('SELECT id FROM delfzijlrp_port_jobs WHERE identifier = ? AND status != ? LIMIT 1', { identifier, 'delivered' })
    if active then
        notify(source, 'Je hebt al een actieve havenopdracht.', 'error')
        return
    end

    local payout = math.random(cargo.payout.min, cargo.payout.max)
    local customs = math.random(1, 100) <= Config.Job.customsChance and 1 or 0
    local jobId = MySQL.insert.await([[INSERT INTO delfzijlrp_port_jobs
        (identifier, terminal_id, cargo_type, payout, requires_customs)
        VALUES (?, ?, ?, ?, ?)]], { identifier, terminalId, cargoType, payout, customs })

    cooldowns[identifier] = os.time() + Config.Job.cooldown
    logPort(jobId, source, 'start_job', terminalId .. ':' .. cargoType)
    notify(source, Config.Text.jobStarted, 'success')
    TriggerClientEvent('delfzijlrp_port:client:setJobWaypoint', source, terminal.pickup)
end)

RegisterNetEvent('delfzijlrp_port:server:pickupCargo', function(jobId)
    local source = source
    local identifier = getIdentifier(source)
    jobId = tonumber(jobId)
    if not identifier or not jobId then return end

    local job = MySQL.single.await('SELECT * FROM delfzijlrp_port_jobs WHERE id = ? AND identifier = ? LIMIT 1', { jobId, identifier })
    if not job or job.status ~= 'started' then return end

    local cargo = getCargo(job.cargo_type)
    if cargo then exports.ox_inventory:AddItem(source, cargo.item, 1) end
    MySQL.update.await('UPDATE delfzijlrp_port_jobs SET status = ? WHERE id = ?', { 'picked_up', jobId })
    logPort(jobId, source, 'pickup', job.cargo_type)
    notify(source, Config.Text.pickedUp, 'success')
end)

RegisterNetEvent('delfzijlrp_port:server:scanCargo', function(jobId, coords)
    local source = source
    local identifier = getIdentifier(source)
    jobId = tonumber(jobId)
    if not identifier or not jobId then return end

    local job = MySQL.single.await('SELECT * FROM delfzijlrp_port_jobs WHERE id = ? AND identifier = ? LIMIT 1', { jobId, identifier })
    if not job or job.status ~= 'picked_up' then return end

    MySQL.update.await('UPDATE delfzijlrp_port_jobs SET status = ? WHERE id = ?', { 'scanned', jobId })
    logPort(jobId, source, 'scan', 'customs:' .. tostring(job.requires_customs))
    notify(source, Config.Text.scanned, 'success')

    if job.requires_customs == 1 then
        notify(source, Config.Text.customsAlert, 'warning')
        TriggerEvent('delfzijlrp_dispatch:server:createReport', 'emergency', 'Douanecontrole gevraagd bij de haven voor verdachte lading.', coords or {})
    end
end)

RegisterNetEvent('delfzijlrp_port:server:deliverCargo', function(jobId)
    local source = source
    local xPlayer = getPlayer(source)
    local identifier = getIdentifier(source)
    jobId = tonumber(jobId)
    if not xPlayer or not identifier or not jobId then return end

    local job = MySQL.single.await('SELECT * FROM delfzijlrp_port_jobs WHERE id = ? AND identifier = ? LIMIT 1', { jobId, identifier })
    if not job or job.status ~= 'scanned' then return end

    local cargo = getCargo(job.cargo_type)
    if cargo then
        local count = exports.ox_inventory:GetItemCount(source, cargo.item) or 0
        if count <= 0 then
            notify(source, 'Je mist de lading.', 'error')
            return
        end
        exports.ox_inventory:RemoveItem(source, cargo.item, 1)
    end

    xPlayer.addAccountMoney('bank', job.payout)
    MySQL.update.await('UPDATE delfzijlrp_port_jobs SET status = ? WHERE id = ?', { 'delivered', jobId })
    logPort(jobId, source, 'deliver', tostring(job.payout))
    notify(source, Config.Text.delivered .. ' €' .. job.payout, 'success')
end)
