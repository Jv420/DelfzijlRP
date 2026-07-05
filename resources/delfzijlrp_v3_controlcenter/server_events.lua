local ESX = exports['es_extended']:getSharedObject()

local function allowed(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return false, nil end
    local group = xPlayer.getGroup and xPlayer.getGroup() or 'user'
    return Config.AdminGroups[group] == true, xPlayer
end

local function notify(src, text, kind)
    TriggerClientEvent('ox_lib:notify', src, { title = 'DRCC Events', description = text, type = kind or 'inform' })
end

local function log(admin, target, action, details)
    MySQL.insert.await('INSERT INTO delfzijlrp_control_logs (admin_name, target_name, action, details) VALUES (?, ?, ?, ?)', {
        admin or 'unknown', target or 'unknown', action or 'unknown', details or ''
    })
end

local function discord(title, text)
    if not Config.Discord.enabled or Config.Discord.webhook == '' then return end
    PerformHttpRequest(Config.Discord.webhook, function() end, 'POST', json.encode({
        username = Config.Discord.botName,
        embeds = {{ title = title, description = text, color = 65280 }}
    }), { ['Content-Type'] = 'application/json' })
end

CreateThread(function()
    MySQL.query.await([[CREATE TABLE IF NOT EXISTS delfzijlrp_giveaways (
        id int NOT NULL AUTO_INCREMENT,
        title varchar(128) NOT NULL,
        preset_id varchar(64) NOT NULL,
        seconds int NOT NULL DEFAULT 300,
        winner_name varchar(128) DEFAULT NULL,
        status varchar(32) NOT NULL DEFAULT 'running',
        created_by varchar(128) DEFAULT NULL,
        created_at timestamp NOT NULL DEFAULT current_timestamp(),
        PRIMARY KEY (id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]])

    MySQL.query.await([[CREATE TABLE IF NOT EXISTS delfzijlrp_staff_notes (
        id int NOT NULL AUTO_INCREMENT,
        target_name varchar(128) NOT NULL,
        target_identifier varchar(64) DEFAULT NULL,
        note text NOT NULL,
        created_by varchar(128) NOT NULL,
        created_at timestamp NOT NULL DEFAULT current_timestamp(),
        PRIMARY KEY (id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]])
end)

local function givePreset(target, preset)
    if preset.money and tonumber(preset.money) and tonumber(preset.money) > 0 then
        target.addAccountMoney('bank', tonumber(preset.money))
    end
    for _, item in ipairs(preset.items or {}) do
        local count = tonumber(item.count) or 1
        if item.name and exports.ox_inventory:Items(item.name) then
            exports.ox_inventory:AddItem(target.source, item.name, count)
        end
    end
end

RegisterNetEvent('delfzijlrp_v3_controlcenter:server:startGiveaway', function(title, presetId, seconds)
    local src = source
    local ok = allowed(src)
    if not ok then notify(src, Config.Text.noAccess, 'error') return end
    title = tostring(title or 'Giveaway')
    presetId = tostring(presetId or '')
    seconds = tonumber(seconds) or 300
    local preset = Config.RewardPresets[presetId]
    if not preset or seconds < 10 then notify(src, Config.Text.invalid, 'error') return end

    local giveawayId = MySQL.insert.await('INSERT INTO delfzijlrp_giveaways (title, preset_id, seconds, created_by) VALUES (?, ?, ?, ?)', {
        title, presetId, seconds, GetPlayerName(src)
    })

    TriggerClientEvent('ox_lib:notify', -1, { title = 'Giveaway gestart', description = title .. ' eindigt over ' .. seconds .. ' seconden.', type = 'inform', duration = 12000 })
    discord('DRCC Giveaway gestart', title .. ' | pakket: ' .. (preset.label or presetId))
    log(GetPlayerName(src), 'Iedereen', 'giveaway_start', title)

    SetTimeout(seconds * 1000, function()
        local ids = GetPlayers()
        if #ids < 1 then
            MySQL.update.await('UPDATE delfzijlrp_giveaways SET status = ? WHERE id = ?', { 'no_players', giveawayId })
            return
        end
        local winnerId = tonumber(ids[math.random(1, #ids)])
        local winner = ESX.GetPlayerFromId(winnerId)
        if not winner then return end
        givePreset(winner, preset)
        local winnerName = GetPlayerName(winner.source)
        MySQL.update.await('UPDATE delfzijlrp_giveaways SET status = ?, winner_name = ? WHERE id = ?', { 'finished', winnerName, giveawayId })
        TriggerClientEvent('ox_lib:notify', -1, { title = 'Giveaway winnaar', description = winnerName .. ' heeft ' .. title .. ' gewonnen!', type = 'success', duration = 15000 })
        discord('DRCC Giveaway winnaar', winnerName .. ' won ' .. title)
        log('giveaway', winnerName, 'giveaway_win', title)
    end)

    notify(src, 'Giveaway gestart.', 'success')
end)

RegisterNetEvent('delfzijlrp_v3_controlcenter:server:setWeather', function(weather)
    local src = source
    local ok = allowed(src)
    if not ok then notify(src, Config.Text.noAccess, 'error') return end
    weather = tostring(weather or 'CLEAR'):upper()
    TriggerClientEvent('delfzijlrp_v3_controlcenter:client:setWeather', -1, weather)
    log(GetPlayerName(src), 'Iedereen', 'weather', weather)
    discord('DRCC Weer', 'Weer aangepast naar ' .. weather)
    notify(src, 'Weer aangepast.', 'success')
end)

RegisterNetEvent('delfzijlrp_v3_controlcenter:server:setTime', function(hour)
    local src = source
    local ok = allowed(src)
    if not ok then notify(src, Config.Text.noAccess, 'error') return end
    hour = tonumber(hour) or 12
    if hour < 0 or hour > 23 then notify(src, Config.Text.invalid, 'error') return end
    TriggerClientEvent('delfzijlrp_v3_controlcenter:client:setTime', -1, hour)
    log(GetPlayerName(src), 'Iedereen', 'time', tostring(hour))
    notify(src, 'Tijd aangepast.', 'success')
end)

RegisterNetEvent('delfzijlrp_v3_controlcenter:server:addNote', function(targetId, note)
    local src = source
    local ok = allowed(src)
    if not ok then notify(src, Config.Text.noAccess, 'error') return end
    local target = ESX.GetPlayerFromId(tonumber(targetId))
    if not target or not note or note == '' then notify(src, Config.Text.invalid, 'error') return end
    MySQL.insert.await('INSERT INTO delfzijlrp_staff_notes (target_name, target_identifier, note, created_by) VALUES (?, ?, ?, ?)', {
        GetPlayerName(target.source), target.identifier, note, GetPlayerName(src)
    })
    log(GetPlayerName(src), GetPlayerName(target.source), 'staff_note', note)
    notify(src, 'Staff note opgeslagen.', 'success')
end)

lib.callback.register('delfzijlrp_v3_controlcenter:server:serverCheck', function(source)
    local ok = allowed(source)
    if not ok then return {} end
    local checks = {
        { label = 'ESX', value = ESX and 'OK' or 'FOUT' },
        { label = 'ox_inventory', value = GetResourceState('ox_inventory') },
        { label = 'oxmysql', value = GetResourceState('oxmysql') },
        { label = 'RDW', value = GetResourceState('delfzijlrp_rdw') },
        { label = 'Papieren', value = GetResourceState('delfzijlrp_v2_papieren') },
        { label = 'Vehicle Lock', value = GetResourceState('delfzijlrp_v2_vehiclelock') }
    }
    return checks
end)
