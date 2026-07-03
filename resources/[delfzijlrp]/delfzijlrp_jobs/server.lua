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
        title = 'Delfzijl RP Jobs',
        description = message,
        type = type or 'inform'
    })
end

local function getJobConfig(jobName)
    return Config.Jobs[jobName]
end

RegisterNetEvent('delfzijlrp_jobs:server:giveWorkItem', function(jobName)
    local source = source
    local job = getJobConfig(jobName)
    if not job then
        notify(source, Config.Text.invalidJob, 'error')
        return
    end

    exports.ox_inventory:AddItem(source, job.item, 1)
    notify(source, Config.Text.workDone, 'success')
end)

RegisterNetEvent('delfzijlrp_jobs:server:sellItems', function(jobName)
    local source = source
    local xPlayer = getPlayer(source)
    local identifier = getIdentifier(source)
    local job = getJobConfig(jobName)
    if not xPlayer or not identifier or not job then return end

    local count = exports.ox_inventory:GetItemCount(source, job.item) or 0
    if count <= 0 then
        notify(source, Config.Text.noItems, 'error')
        return
    end

    exports.ox_inventory:RemoveItem(source, job.item, count)

    local total = 0
    for _ = 1, count do
        total = total + math.random(job.reward.min, job.reward.max)
    end

    xPlayer.addAccountMoney('bank', total)

    MySQL.insert.await([[INSERT INTO delfzijlrp_job_stats (identifier, job_name, completed_tasks, total_earned, level)
        VALUES (?, ?, ?, ?, 1)
        ON DUPLICATE KEY UPDATE completed_tasks = completed_tasks + VALUES(completed_tasks), total_earned = total_earned + VALUES(total_earned)]], {
        identifier,
        jobName,
        count,
        total
    })

    notify(source, ('%s €%s'):format(Config.Text.paid, total), 'success')
end)

lib.callback.register('delfzijlrp_jobs:server:getStats', function(source)
    local identifier = getIdentifier(source)
    if not identifier then return {} end

    return MySQL.query.await('SELECT * FROM delfzijlrp_job_stats WHERE identifier = ? ORDER BY total_earned DESC', { identifier }) or {}
end)
