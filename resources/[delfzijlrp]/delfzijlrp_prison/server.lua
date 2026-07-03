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
        title = 'PI Delfzijl',
        description = message,
        type = type or 'inform'
    })
end

local function hasAccess(source)
    local xPlayer = getPlayer(source)
    return xPlayer and xPlayer.job and Config.AccessJobs[xPlayer.job.name] == true
end

local function identityName(identifier, fallback)
    local row = MySQL.single.await('SELECT firstname, lastname FROM delfzijlrp_identities WHERE identifier = ? LIMIT 1', { identifier })
    if row then return row.firstname .. ' ' .. row.lastname end
    return fallback
end

local function logPrison(sentenceId, source, action, details)
    MySQL.insert.await('INSERT INTO delfzijlrp_prison_logs (sentence_id, actor_identifier, action, details) VALUES (?, ?, ?, ?)', {
        sentenceId,
        source and getIdentifier(source) or nil,
        action,
        details
    })
end

lib.callback.register('delfzijlrp_prison:server:hasAccess', function(source)
    return hasAccess(source)
end)

lib.callback.register('delfzijlrp_prison:server:getActiveSentence', function(source)
    local identifier = getIdentifier(source)
    if not identifier then return nil end
    return MySQL.single.await('SELECT * FROM delfzijlrp_prison_sentences WHERE identifier = ? AND status = ? ORDER BY created_at DESC LIMIT 1', { identifier, 'active' })
end)

lib.callback.register('delfzijlrp_prison:server:getActiveSentences', function(source)
    if not hasAccess(source) then return {} end
    return MySQL.query.await('SELECT * FROM delfzijlrp_prison_sentences WHERE status = ? ORDER BY created_at DESC LIMIT 50', { 'active' }) or {}
end)

RegisterNetEvent('delfzijlrp_prison:server:sentencePlayer', function(targetId, minutes, reason)
    local source = source
    if not hasAccess(source) then return end

    targetId = tonumber(targetId)
    minutes = tonumber(minutes) or 0
    reason = tostring(reason or '')
    if not targetId or not GetPlayerName(targetId) or minutes < Config.Sentences.minMinutes or minutes > Config.Sentences.maxMinutes or #reason < 3 then
        notify(source, Config.Text.invalidInput, 'error')
        return
    end

    local target = getPlayer(targetId)
    if not target then notify(source, Config.Text.playerNotFound, 'error') return end

    MySQL.update.await('UPDATE delfzijlrp_prison_sentences SET status = ?, released_at = NOW() WHERE identifier = ? AND status = ?', { 'superseded', target.identifier, 'active' })
    local sentenceId = MySQL.insert.await([[INSERT INTO delfzijlrp_prison_sentences
        (identifier, player_name, issuer_identifier, issuer_name, reason, minutes_total, minutes_remaining)
        VALUES (?, ?, ?, ?, ?, ?, ?)]], {
        target.identifier,
        identityName(target.identifier, GetPlayerName(targetId)),
        getIdentifier(source),
        GetPlayerName(source),
        reason,
        minutes,
        minutes
    })

    logPrison(sentenceId, source, 'sentence', reason .. ':' .. minutes)
    TriggerClientEvent('delfzijlrp_prison:client:sendToCell', targetId, Config.Prison.cell)
    notify(source, Config.Text.sentenced, 'success')
    notify(targetId, ('Je bent overgebracht naar PI Delfzijl. Resterend: %s minuten.'):format(minutes), 'warning')
end)

RegisterNetEvent('delfzijlrp_prison:server:reduceByTask', function(taskId)
    local source = source
    local identifier = getIdentifier(source)
    if not identifier then return end

    local sentence = MySQL.single.await('SELECT * FROM delfzijlrp_prison_sentences WHERE identifier = ? AND status = ? ORDER BY created_at DESC LIMIT 1', { identifier, 'active' })
    if not sentence then notify(source, Config.Text.noSentence, 'error') return end

    local reduced = Config.Sentences.taskReductionMinutes
    local remaining = math.max(0, sentence.minutes_remaining - reduced)
    MySQL.update.await('UPDATE delfzijlrp_prison_sentences SET minutes_remaining = ? WHERE id = ?', { remaining, sentence.id })
    MySQL.insert.await('INSERT INTO delfzijlrp_prison_tasks (sentence_id, identifier, task_id, minutes_reduced) VALUES (?, ?, ?, ?)', { sentence.id, identifier, taskId, reduced })
    logPrison(sentence.id, source, 'task', taskId .. ':' .. reduced)

    if remaining <= 0 then
        MySQL.update.await('UPDATE delfzijlrp_prison_sentences SET status = ?, released_at = NOW() WHERE id = ?', { 'released', sentence.id })
        TriggerClientEvent('delfzijlrp_prison:client:release', source, Config.Prison.release)
        notify(source, Config.Text.released, 'success')
    else
        notify(source, Config.Text.taskDone .. ' Resterend: ' .. remaining .. ' minuten.', 'success')
    end
end)

RegisterNetEvent('delfzijlrp_prison:server:releasePlayer', function(targetIdentifier)
    local source = source
    if not hasAccess(source) then return end
    if not targetIdentifier then return end

    local sentence = MySQL.single.await('SELECT * FROM delfzijlrp_prison_sentences WHERE identifier = ? AND status = ? ORDER BY created_at DESC LIMIT 1', { targetIdentifier, 'active' })
    if not sentence then notify(source, Config.Text.noSentence, 'error') return end

    MySQL.update.await('UPDATE delfzijlrp_prison_sentences SET status = ?, minutes_remaining = 0, released_at = NOW() WHERE id = ?', { 'released', sentence.id })
    logPrison(sentence.id, source, 'manual_release', targetIdentifier)

    for _, xPlayer in pairs(ESX.GetExtendedPlayers()) do
        if xPlayer.identifier == targetIdentifier then
            TriggerClientEvent('delfzijlrp_prison:client:release', xPlayer.source, Config.Prison.release)
            notify(xPlayer.source, Config.Text.released, 'success')
            break
        end
    end
    notify(source, Config.Text.released, 'success')
end)

CreateThread(function()
    while true do
        Wait(60000)
        local rows = MySQL.query.await('SELECT * FROM delfzijlrp_prison_sentences WHERE status = ? AND minutes_remaining > 0', { 'active' }) or {}
        for _, row in ipairs(rows) do
            local remaining = math.max(0, row.minutes_remaining - 1)
            local status = remaining <= 0 and 'released' or 'active'
            MySQL.update.await('UPDATE delfzijlrp_prison_sentences SET minutes_remaining = ?, status = ?, released_at = IF(? = ?, NOW(), released_at) WHERE id = ?', { remaining, status, status, 'released', row.id })
            if remaining <= 0 then
                for _, xPlayer in pairs(ESX.GetExtendedPlayers()) do
                    if xPlayer.identifier == row.identifier then
                        TriggerClientEvent('delfzijlrp_prison:client:release', xPlayer.source, Config.Prison.release)
                        notify(xPlayer.source, Config.Text.released, 'success')
                        break
                    end
                end
            end
        end
    end
end)
