local ESX = exports['es_extended']:getSharedObject()
local frozenPlayers = {}

local function allowed(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return false, nil end
    local group = xPlayer.getGroup and xPlayer.getGroup() or 'user'
    return Config.AdminGroups[group] == true, xPlayer
end

local function notify(src, text, kind)
    TriggerClientEvent('ox_lib:notify', src, { title = 'DRCC Premium', description = text, type = kind or 'inform' })
end

local function logLine(admin, target, action, details)
    MySQL.insert.await('INSERT INTO delfzijlrp_control_logs (admin_name, target_name, action, details) VALUES (?, ?, ?, ?)', {
        admin or 'unknown', target or 'unknown', action or 'unknown', details or ''
    })
end

local function discord(title, text)
    if not Config.Discord.enabled or Config.Discord.webhook == '' then return end
    PerformHttpRequest(Config.Discord.webhook, function() end, 'POST', json.encode({
        username = Config.Discord.botName,
        embeds = {{ title = title, description = text, color = 3447003 }}
    }), { ['Content-Type'] = 'application/json' })
end

local function targetPlayer(id)
    id = tonumber(id)
    if not id then return nil end
    return ESX.GetPlayerFromId(id)
end

lib.callback.register('delfzijlrp_v3_controlcenter:server:getLogs', function(source)
    local ok = allowed(source)
    if not ok then return {} end
    return MySQL.query.await('SELECT admin_name, target_name, action, details, created_at FROM delfzijlrp_control_logs ORDER BY id DESC LIMIT 25') or {}
end)

RegisterNetEvent('delfzijlrp_v3_controlcenter:server:heal', function(targetId)
    local src = source
    local ok = allowed(src)
    if not ok then notify(src, Config.Text.noAccess, 'error') return end
    local t = targetPlayer(targetId)
    if not t then notify(src, Config.Text.playerNotFound, 'error') return end
    TriggerClientEvent('delfzijlrp_v3_controlcenter:client:heal', t.source)
    logLine(GetPlayerName(src), GetPlayerName(t.source), 'heal', 'Speler geheald')
    discord('DRCC heal', GetPlayerName(src) .. ' healde ' .. GetPlayerName(t.source))
    notify(src, Config.Text.done, 'success')
end)

RegisterNetEvent('delfzijlrp_v3_controlcenter:server:revive', function(targetId)
    local src = source
    local ok = allowed(src)
    if not ok then notify(src, Config.Text.noAccess, 'error') return end
    local t = targetPlayer(targetId)
    if not t then notify(src, Config.Text.playerNotFound, 'error') return end
    TriggerClientEvent('delfzijlrp_v3_controlcenter:client:revive', t.source)
    logLine(GetPlayerName(src), GetPlayerName(t.source), 'revive', 'Speler gerevived')
    discord('DRCC revive', GetPlayerName(src) .. ' revivde ' .. GetPlayerName(t.source))
    notify(src, Config.Text.done, 'success')
end)

RegisterNetEvent('delfzijlrp_v3_controlcenter:server:bring', function(targetId)
    local src = source
    local ok = allowed(src)
    if not ok then notify(src, Config.Text.noAccess, 'error') return end
    local t = targetPlayer(targetId)
    if not t then notify(src, Config.Text.playerNotFound, 'error') return end
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    TriggerClientEvent('delfzijlrp_v3_controlcenter:client:teleport', t.source, coords.x, coords.y, coords.z)
    logLine(GetPlayerName(src), GetPlayerName(t.source), 'bring', 'Speler naar admin gebracht')
    notify(src, Config.Text.done, 'success')
end)

RegisterNetEvent('delfzijlrp_v3_controlcenter:server:goto', function(targetId)
    local src = source
    local ok = allowed(src)
    if not ok then notify(src, Config.Text.noAccess, 'error') return end
    local t = targetPlayer(targetId)
    if not t then notify(src, Config.Text.playerNotFound, 'error') return end
    local ped = GetPlayerPed(t.source)
    local coords = GetEntityCoords(ped)
    TriggerClientEvent('delfzijlrp_v3_controlcenter:client:teleport', src, coords.x, coords.y, coords.z)
    logLine(GetPlayerName(src), GetPlayerName(t.source), 'goto', 'Admin naar speler gegaan')
    notify(src, Config.Text.done, 'success')
end)

RegisterNetEvent('delfzijlrp_v3_controlcenter:server:freeze', function(targetId)
    local src = source
    local ok = allowed(src)
    if not ok then notify(src, Config.Text.noAccess, 'error') return end
    local t = targetPlayer(targetId)
    if not t then notify(src, Config.Text.playerNotFound, 'error') return end
    frozenPlayers[t.source] = not frozenPlayers[t.source]
    TriggerClientEvent('delfzijlrp_v3_controlcenter:client:freeze', t.source, frozenPlayers[t.source])
    logLine(GetPlayerName(src), GetPlayerName(t.source), 'freeze', frozenPlayers[t.source] and 'Freeze aan' or 'Freeze uit')
    notify(src, frozenPlayers[t.source] and 'Speler bevroren.' or 'Speler vrijgegeven.', 'success')
end)

RegisterNetEvent('delfzijlrp_v3_controlcenter:server:moneyAll', function(account, amount)
    local src = source
    local ok = allowed(src)
    if not ok then notify(src, Config.Text.noAccess, 'error') return end
    amount = tonumber(amount) or 0
    if amount <= 0 then notify(src, Config.Text.invalid, 'error') return end
    local total = 0
    for _, id in ipairs(GetPlayers()) do
        local t = ESX.GetPlayerFromId(tonumber(id))
        if t then
            if account == 'cash' then t.addMoney(amount) else t.addAccountMoney('bank', amount); account = 'bank' end
            total = total + 1
        end
    end
    local text = ('Iedereen online kreeg euro %s op %s (%s spelers)'):format(amount, account, total)
    logLine(GetPlayerName(src), 'Iedereen online', 'money_all', text)
    discord('DRCC geld iedereen', text)
    notify(src, text, 'success')
end)

RegisterNetEvent('delfzijlrp_v3_controlcenter:server:clearCode', function(code)
    local src = source
    local ok = allowed(src)
    if not ok then notify(src, Config.Text.noAccess, 'error') return end
    code = tostring(code or ''):upper():gsub('%s+', '')
    if code == '' then notify(src, Config.Text.invalid, 'error') return end
    MySQL.update.await('UPDATE delfzijlrp_reward_codes SET active = 0 WHERE code = ?', { code })
    logLine(GetPlayerName(src), 'CODE', 'disable_code', code)
    notify(src, 'Code uitgeschakeld: ' .. code, 'success')
end)
