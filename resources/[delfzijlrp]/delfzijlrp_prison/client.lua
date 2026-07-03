local function notify(message, type)
    lib.notify({ title = 'PI Delfzijl', description = message, type = type or 'inform' })
end

local function hasAccess()
    local ok = lib.callback.await('delfzijlrp_prison:server:hasAccess', false)
    if not ok then notify(Config.Text.noAccess, 'error') end
    return ok
end

local function teleport(coords)
    DoScreenFadeOut(350)
    Wait(450)
    SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, false, false, false, false)
    if coords.w then SetEntityHeading(PlayerPedId(), coords.w) end
    Wait(350)
    DoScreenFadeIn(350)
end

local function sentenceDialog()
    if not hasAccess() then return end
    local input = lib.inputDialog('Straf registreren', {
        { type = 'number', label = 'Speler ID', required = true, min = 1 },
        { type = 'number', label = 'Minuten', required = true, min = Config.Sentences.minMinutes, max = Config.Sentences.maxMinutes },
        { type = 'input', label = 'Reden', required = true, min = 3, max = 255 }
    })
    if input then
        TriggerServerEvent('delfzijlrp_prison:server:sentencePlayer', input[1], input[2], input[3])
    end
end

local function openActiveSentences()
    if not hasAccess() then return end
    local rows = lib.callback.await('delfzijlrp_prison:server:getActiveSentences', false) or {}
    local options = {}
    for _, row in ipairs(rows) do
        options[#options + 1] = {
            title = row.player_name or row.identifier,
            description = ('Resterend: %s min | %s'):format(row.minutes_remaining, row.reason),
            icon = 'lock',
            onSelect = function()
                lib.registerContext({
                    id = 'delfzijlrp_prison_sentence_detail',
                    title = row.player_name or row.identifier,
                    options = {
                        { title = 'Handmatig vrijlaten', icon = 'door-open', onSelect = function() TriggerServerEvent('delfzijlrp_prison:server:releasePlayer', row.identifier) end },
                        { title = 'Reden', description = row.reason, icon = 'file-lines', readOnly = true }
                    }
                })
                lib.showContext('delfzijlrp_prison_sentence_detail')
            end
        }
    end
    if #options == 0 then options[#options + 1] = { title = 'Geen actieve straffen', icon = 'circle-info', readOnly = true } end
    lib.registerContext({ id = 'delfzijlrp_prison_active', title = 'Actieve straffen', options = options })
    lib.showContext('delfzijlrp_prison_active')
end

local function openPrisonMenu()
    if not hasAccess() then return end
    lib.registerContext({
        id = 'delfzijlrp_prison_menu',
        title = Config.Prison.label,
        options = {
            { title = 'Straf registreren', icon = 'file-pen', onSelect = sentenceDialog },
            { title = 'Actieve straffen', icon = 'list', onSelect = openActiveSentences },
            { title = 'MDT openen', icon = 'tablet-screen-button', onSelect = function() ExecuteCommand('mdt2') end },
            { title = 'Rechtbank openen', icon = 'scale-balanced', onSelect = function() ExecuteCommand('rechtbank') end }
        }
    })
    lib.showContext('delfzijlrp_prison_menu')
end

local function doTask(task)
    local sentence = lib.callback.await('delfzijlrp_prison:server:getActiveSentence', false)
    if not sentence then notify(Config.Text.noSentence, 'error') return end

    local success = lib.progressCircle({
        duration = task.duration,
        label = task.label .. '...',
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = { car = true, move = true, combat = true },
        anim = { dict = 'amb@world_human_janitor@male@idle_a', clip = 'idle_a' }
    })

    if success then
        TriggerServerEvent('delfzijlrp_prison:server:reduceByTask', task.id)
    end
end

local function openMySentence()
    local sentence = lib.callback.await('delfzijlrp_prison:server:getActiveSentence', false)
    if not sentence then notify(Config.Text.noSentence, 'inform') return end
    lib.registerContext({
        id = 'delfzijlrp_prison_my_sentence',
        title = 'Mijn straf',
        options = {
            { title = 'Resterend', description = tostring(sentence.minutes_remaining) .. ' minuten', icon = 'clock', readOnly = true },
            { title = 'Reden', description = sentence.reason, icon = 'file-lines', readOnly = true },
            { title = 'Binnenplaats waypoint', icon = 'map-pin', onSelect = function() SetNewWaypoint(Config.Prison.yard.x, Config.Prison.yard.y) end }
        }
    })
    lib.showContext('delfzijlrp_prison_my_sentence')
end

CreateThread(function()
    Wait(1500)

    if Config.Prison.blip then
        local blip = AddBlipForCoord(Config.Prison.intake.x, Config.Prison.intake.y, Config.Prison.intake.z)
        SetBlipSprite(blip, Config.Prison.blip.sprite)
        SetBlipColour(blip, Config.Prison.blip.color)
        SetBlipScale(blip, Config.Prison.blip.scale)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(Config.Prison.label)
        EndTextCommandSetBlipName(blip)
    end

    exports.ox_target:addSphereZone({
        coords = Config.Prison.intake,
        radius = Config.Prison.radius,
        debug = Config.Debug,
        options = {{ name = 'prison_intake', icon = 'fa-solid fa-building-shield', label = Config.Text.intake, onSelect = openPrisonMenu }}
    })

    for _, task in ipairs(Config.Tasks) do
        exports.ox_target:addSphereZone({
            coords = task.coords,
            radius = 1.6,
            debug = Config.Debug,
            options = {{ name = 'prison_task_' .. task.id, icon = 'fa-solid fa-broom', label = task.label, onSelect = function() doTask(task) end }}
        })
    end
end)

RegisterCommand(Config.Command, openMySentence, false)
RegisterCommand(Config.AdminCommand, sentenceDialog, false)

RegisterNetEvent('delfzijlrp_prison:client:sendToCell', function(coords)
    teleport(coords)
end)

RegisterNetEvent('delfzijlrp_prison:client:release', function(coords)
    teleport(coords)
end)
