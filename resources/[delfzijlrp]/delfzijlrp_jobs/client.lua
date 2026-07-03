local activeJob = nil
local activePointBlips = {}

local function notify(message, type)
    lib.notify({ title = 'Delfzijl RP Jobs', description = message, type = type or 'inform' })
end

local function clearPointBlips()
    for _, blip in ipairs(activePointBlips) do
        if DoesBlipExist(blip) then RemoveBlip(blip) end
    end
    activePointBlips = {}
end

local function doWork(jobName)
    local job = Config.Jobs[jobName]
    if not job then return end

    local success = lib.progressCircle({
        duration = job.workTime,
        label = job.label .. '...',
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = { car = true, move = true, combat = true },
        anim = { dict = 'amb@world_human_gardener_plant@male@base', clip = 'base' }
    })

    if success then
        TriggerServerEvent('delfzijlrp_jobs:server:giveWorkItem', jobName)
    end
end

local function startJob(jobName)
    local job = Config.Jobs[jobName]
    if not job then
        notify(Config.Text.invalidJob, 'error')
        return
    end

    activeJob = jobName
    clearPointBlips()

    for index, coords in ipairs(job.points) do
        local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(blip, 1)
        SetBlipColour(blip, 2)
        SetBlipScale(blip, 0.55)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(job.label .. ' werkpunt')
        EndTextCommandSetBlipName(blip)
        activePointBlips[#activePointBlips + 1] = blip

        exports.ox_target:addSphereZone({
            coords = coords,
            radius = 2.0,
            debug = Config.Debug,
            options = {
                {
                    name = ('delfzijlrp_job_%s_%s'):format(jobName, index),
                    icon = 'fa-solid fa-briefcase',
                    label = Config.Text.doWork,
                    distance = 2.0,
                    onSelect = function()
                        if activeJob ~= jobName then return end
                        doWork(jobName)
                    end
                }
            }
        })
    end

    notify(Config.Text.jobStarted, 'success')
end

local function stopJob()
    activeJob = nil
    clearPointBlips()
    notify(Config.Text.jobStopped, 'inform')
end

local function openJob(jobName)
    local job = Config.Jobs[jobName]
    if not job then return end

    lib.registerContext({
        id = 'delfzijlrp_job_detail',
        title = job.label,
        options = {
            { title = Config.Text.startJob, icon = 'play', onSelect = function() startJob(jobName) end },
            { title = Config.Text.stopJob, icon = 'stop', onSelect = stopJob },
            { title = Config.Text.sellItems, icon = 'money-bill', onSelect = function() TriggerServerEvent('delfzijlrp_jobs:server:sellItems', jobName) end }
        }
    })

    lib.showContext('delfzijlrp_job_detail')
end

local function openJobCenter()
    local options = {}
    for jobName, job in pairs(Config.Jobs) do
        options[#options + 1] = {
            title = job.label,
            description = ('Beloning per item: €%s - €%s'):format(job.reward.min, job.reward.max),
            icon = 'briefcase',
            onSelect = function() openJob(jobName) end
        }
    end

    options[#options + 1] = {
        title = 'Mijn werkstatistieken',
        icon = 'chart-line',
        onSelect = function()
            local stats = lib.callback.await('delfzijlrp_jobs:server:getStats', false) or {}
            local statOptions = {}
            for _, row in ipairs(stats) do
                statOptions[#statOptions + 1] = {
                    title = Config.Jobs[row.job_name] and Config.Jobs[row.job_name].label or row.job_name,
                    description = ('Taken: %s | Verdiend: €%s'):format(row.completed_tasks, row.total_earned),
                    icon = 'chart-simple',
                    readOnly = true
                }
            end
            if #statOptions == 0 then
                statOptions[#statOptions + 1] = { title = 'Nog geen statistieken', icon = 'circle-info', readOnly = true }
            end
            lib.registerContext({ id = 'delfzijlrp_job_stats', title = 'Werkstatistieken', options = statOptions })
            lib.showContext('delfzijlrp_job_stats')
        end
    }

    lib.registerContext({ id = 'delfzijlrp_jobs_center', title = Config.JobCenter.label, options = options })
    lib.showContext('delfzijlrp_jobs_center')
end

CreateThread(function()
    Wait(1500)

    if Config.UseBlips and Config.JobCenter.blip then
        local coords = Config.JobCenter.coords
        local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(blip, Config.JobCenter.blip.sprite)
        SetBlipColour(blip, Config.JobCenter.blip.color)
        SetBlipScale(blip, Config.JobCenter.blip.scale)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(Config.JobCenter.label)
        EndTextCommandSetBlipName(blip)
    end

    exports.ox_target:addSphereZone({
        coords = Config.JobCenter.coords,
        radius = Config.JobCenter.radius,
        debug = Config.Debug,
        options = {
            {
                name = 'delfzijlrp_jobs_center',
                icon = 'fa-solid fa-briefcase',
                label = Config.Text.openJobCenter,
                distance = 2.0,
                onSelect = openJobCenter
            }
        }
    })

    for jobName, job in pairs(Config.Jobs) do
        if Config.UseBlips and job.blip then
            local blip = AddBlipForCoord(job.start.x, job.start.y, job.start.z)
            SetBlipSprite(blip, job.blip.sprite)
            SetBlipColour(blip, job.blip.color)
            SetBlipScale(blip, job.blip.scale)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(job.label)
            EndTextCommandSetBlipName(blip)
        end

        exports.ox_target:addSphereZone({
            coords = job.start,
            radius = 2.0,
            debug = Config.Debug,
            options = {
                {
                    name = 'delfzijlrp_job_start_' .. jobName,
                    icon = 'fa-solid fa-briefcase',
                    label = job.label,
                    distance = 2.0,
                    onSelect = function() openJob(jobName) end
                }
            }
        })
    end
end)

RegisterCommand(Config.Command, openJobCenter, false)
