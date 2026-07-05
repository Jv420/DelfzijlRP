local ESX = exports['es_extended']:getSharedObject()

local function adminAllowed(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return false end
    local group = xPlayer.getGroup and xPlayer.getGroup() or 'user'
    return Config.AdminGroups[group] == true, xPlayer
end

local function notify(src, text, kind)
    TriggerClientEvent('ox_lib:notify', src, { title = 'DRCC', description = text, type = kind or 'inform' })
end

local function discordLog(title, text)
    if not Config.Discord.enabled or Config.Discord.webhook == '' then return end
    PerformHttpRequest(Config.Discord.webhook, function() end, 'POST', json.encode({
        username = Config.Discord.botName,
        embeds = {{ title = title, description = text, color = 16763904 }}
    }), { ['Content-Type'] = 'application/json' })
end

local function writeLog(adminName, targetName, action, details)
    MySQL.insert.await('INSERT INTO delfzijlrp_control_logs (admin_name, target_name, action, details) VALUES (?, ?, ?, ?)', {
        adminName or 'unknown', targetName or 'unknown', action or 'unknown', details or ''
    })
end

CreateThread(function()
    MySQL.query.await([[CREATE TABLE IF NOT EXISTS delfzijlrp_control_logs (
        id int NOT NULL AUTO_INCREMENT,
        admin_name varchar(128) NOT NULL,
        target_name varchar(128) NOT NULL,
        action varchar(64) NOT NULL,
        details text NULL,
        created_at timestamp NOT NULL DEFAULT current_timestamp(),
        PRIMARY KEY (id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]])

    MySQL.query.await([[CREATE TABLE IF NOT EXISTS delfzijlrp_reward_codes (
        code varchar(64) NOT NULL,
        label varchar(128) NOT NULL,
        reward_json longtext NOT NULL,
        max_claims int NOT NULL DEFAULT 1,
        active tinyint NOT NULL DEFAULT 1,
        created_by varchar(128) DEFAULT NULL,
        created_at timestamp NOT NULL DEFAULT current_timestamp(),
        PRIMARY KEY (code)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]])

    MySQL.query.await([[CREATE TABLE IF NOT EXISTS delfzijlrp_reward_claims (
        id int NOT NULL AUTO_INCREMENT,
        code varchar(64) NOT NULL,
        identifier varchar(64) NOT NULL,
        player_name varchar(128) NOT NULL,
        claimed_at timestamp NOT NULL DEFAULT current_timestamp(),
        PRIMARY KEY (id),
        UNIQUE KEY unique_code_identifier (code, identifier)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]])
end)

local function getTarget(targetId)
    targetId = tonumber(targetId)
    if not targetId then return nil end
    return ESX.GetPlayerFromId(targetId)
end

local function giveRewardToPlayer(target, reward)
    if not target or not reward then return false, Config.Text.invalid end

    if reward.money and tonumber(reward.money) and tonumber(reward.money) > 0 then
        target.addAccountMoney('bank', tonumber(reward.money))
    end

    for _, item in ipairs(reward.items or {}) do
        local count = tonumber(item.count) or 1
        if item.name and count > 0 then
            if not exports.ox_inventory:Items(item.name) then
                return false, Config.Text.missingItem .. ' (' .. item.name .. ')'
            end
            local ok, reason = exports.ox_inventory:AddItem(target.source, item.name, count)
            if not ok then return false, reason or Config.Text.invalid end
        end
    end

    return true, Config.Text.done
end

lib.callback.register('delfzijlrp_v3_controlcenter:server:canOpen', function(source)
    local allowed = adminAllowed(source)
    return allowed == true
end)

lib.callback.register('delfzijlrp_v3_controlcenter:server:getPlayers', function(source)
    local allowed = adminAllowed(source)
    if not allowed then return {} end
    local players = {}
    for _, id in ipairs(GetPlayers()) do
        local sid = tonumber(id)
        local xPlayer = ESX.GetPlayerFromId(sid)
        if xPlayer then players[#players + 1] = { id = sid, name = GetPlayerName(sid), identifier = xPlayer.identifier } end
    end
    return players
end)

lib.callback.register('delfzijlrp_v3_controlcenter:server:getPresets', function(source)
    local allowed = adminAllowed(source)
    if not allowed then return {} end
    local out = {}
    for id, preset in pairs(Config.RewardPresets or {}) do
        out[#out + 1] = { id = id, label = preset.label or id, money = preset.money or 0, items = preset.items or {} }
    end
    return out
end)

RegisterNetEvent('delfzijlrp_v3_controlcenter:server:money', function(targetId, account, amount)
    local src = source
    local allowed = adminAllowed(src)
    if not allowed then notify(src, Config.Text.noAccess, 'error') return end
    local target = getTarget(targetId)
    amount = tonumber(amount) or 0
    if not target or amount <= 0 then notify(src, Config.Text.invalid, 'error') return end
    if account == 'bank' then target.addAccountMoney('bank', amount) else target.addMoney(amount); account = 'cash' end
    local details = ('%s kreeg euro %s op %s'):format(GetPlayerName(target.source), amount, account)
    writeLog(GetPlayerName(src), GetPlayerName(target.source), 'money', details)
    discordLog('DRCC geld', details)
    notify(src, Config.Text.done, 'success')
end)

RegisterNetEvent('delfzijlrp_v3_controlcenter:server:item', function(targetId, itemName, count)
    local src = source
    local allowed = adminAllowed(src)
    if not allowed then notify(src, Config.Text.noAccess, 'error') return end
    local target = getTarget(targetId)
    count = tonumber(count) or 1
    if not target or not itemName or count < 1 then notify(src, Config.Text.invalid, 'error') return end
    if not exports.ox_inventory:Items(itemName) then notify(src, Config.Text.missingItem .. ' (' .. itemName .. ')', 'error') return end
    local ok, reason = exports.ox_inventory:AddItem(target.source, itemName, count)
    if not ok then notify(src, reason or Config.Text.invalid, 'error') return end
    local details = ('%s kreeg %sx %s'):format(GetPlayerName(target.source), count, itemName)
    writeLog(GetPlayerName(src), GetPlayerName(target.source), 'item', details)
    discordLog('DRCC item', details)
    notify(src, Config.Text.done, 'success')
end)

RegisterNetEvent('delfzijlrp_v3_controlcenter:server:vehicle', function(targetId, model, label)
    local src = source
    local allowed = adminAllowed(src)
    if not allowed then notify(src, Config.Text.noAccess, 'error') return end
    local target = getTarget(targetId)
    if not target or not model or model == '' then notify(src, Config.Text.invalid, 'error') return end
    local plate = exports['delfzijlrp_rdw']:GeneratePlate()
    local vin = ('DRCC%s%s'):format(os.time(), math.random(1000, 9999))
    local props = { model = joaat(model), plate = plate }
    local encoded = json.encode(props)
    label = label or model
    MySQL.insert.await('INSERT INTO owned_vehicles (owner, plate, vehicle, type, stored) VALUES (?, ?, ?, ?, ?)', { target.identifier, plate, encoded, 'car', 1 })
    MySQL.insert.await('INSERT INTO delfzijlrp_garage_states (plate, owner, garage_id, stored, impounded, vehicle_props) VALUES (?, ?, ?, ?, ?, ?)', { plate, target.identifier, Config.DefaultGarage, 1, 0, encoded })
    MySQL.insert.await('INSERT INTO delfzijlrp_rdw_registry (plate, owner, owner_name, vin, model, vehicle_props, insurance_type, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', { plate, target.identifier, GetPlayerName(target.source), vin, label, encoded, 'WA', 'active' })
    MySQL.insert.await('INSERT INTO delfzijlrp_vehicle_keys (plate, identifier, key_type) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE key_type = VALUES(key_type)', { plate, target.identifier, 'owner' })
    local details = ('%s kreeg voertuig %s kenteken %s'):format(GetPlayerName(target.source), label, plate)
    writeLog(GetPlayerName(src), GetPlayerName(target.source), 'vehicle', details)
    discordLog('DRCC voertuig', details)
    notify(src, Config.Text.vehicleGiven .. ' ' .. plate, 'success')
end)

RegisterNetEvent('delfzijlrp_v3_controlcenter:server:preset', function(targetId, presetId)
    local src = source
    local allowed = adminAllowed(src)
    if not allowed then notify(src, Config.Text.noAccess, 'error') return end
    local target = getTarget(targetId)
    local preset = Config.RewardPresets[presetId]
    if not target or not preset then notify(src, Config.Text.invalid, 'error') return end
    local ok, text = giveRewardToPlayer(target, preset)
    if not ok then notify(src, text, 'error') return end
    local details = ('%s kreeg pakket %s'):format(GetPlayerName(target.source), preset.label or presetId)
    writeLog(GetPlayerName(src), GetPlayerName(target.source), 'preset', details)
    discordLog('DRCC cadeaupakket', details)
    notify(src, Config.Text.done, 'success')
end)

RegisterNetEvent('delfzijlrp_v3_controlcenter:server:presetAll', function(presetId)
    local src = source
    local allowed = adminAllowed(src)
    if not allowed then notify(src, Config.Text.noAccess, 'error') return end
    local preset = Config.RewardPresets[presetId]
    if not preset then notify(src, Config.Text.invalid, 'error') return end
    local total = 0
    for _, id in ipairs(GetPlayers()) do
        local target = ESX.GetPlayerFromId(tonumber(id))
        if target then
            local ok = giveRewardToPlayer(target, preset)
            if ok then total = total + 1 end
        end
    end
    local details = ('Iedereen online kreeg pakket %s (%s spelers)'):format(preset.label or presetId, total)
    writeLog(GetPlayerName(src), 'Iedereen online', 'preset_all', details)
    discordLog('DRCC pakket iedereen', details)
    notify(src, Config.Text.done .. ' ' .. total .. ' spelers.', 'success')
end)

RegisterNetEvent('delfzijlrp_v3_controlcenter:server:createCode', function(code, label, presetId, maxClaims)
    local src = source
    local allowed = adminAllowed(src)
    if not allowed then notify(src, Config.Text.noAccess, 'error') return end
    code = tostring(code or ''):upper():gsub('%s+', '')
    maxClaims = tonumber(maxClaims) or 1
    local preset = Config.RewardPresets[presetId]
    if code == '' or not preset or maxClaims < 1 then notify(src, Config.Text.invalid, 'error') return end
    MySQL.insert.await('REPLACE INTO delfzijlrp_reward_codes (code, label, reward_json, max_claims, active, created_by) VALUES (?, ?, ?, ?, ?, ?)', {
        code, label or preset.label or code, json.encode(preset), maxClaims, 1, GetPlayerName(src)
    })
    local details = ('Code %s aangemaakt voor pakket %s max %s claims'):format(code, preset.label or presetId, maxClaims)
    writeLog(GetPlayerName(src), 'CODE', 'create_code', details)
    discordLog('DRCC claimcode', details)
    notify(src, Config.Text.done, 'success')
end)

RegisterCommand('claimcode', function(src, args)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    local code = tostring(args[1] or ''):upper():gsub('%s+', '')
    if code == '' then notify(src, 'Gebruik: /claimcode CODE', 'error') return end
    local row = MySQL.single.await('SELECT * FROM delfzijlrp_reward_codes WHERE code = ? AND active = 1 LIMIT 1', { code })
    if not row then notify(src, 'Deze code bestaat niet of is niet actief.', 'error') return end
    local count = MySQL.scalar.await('SELECT COUNT(*) FROM delfzijlrp_reward_claims WHERE code = ?', { code }) or 0
    if tonumber(count) >= tonumber(row.max_claims) then notify(src, 'Deze code is al volledig geclaimd.', 'error') return end
    local already = MySQL.scalar.await('SELECT id FROM delfzijlrp_reward_claims WHERE code = ? AND identifier = ? LIMIT 1', { code, xPlayer.identifier })
    if already then notify(src, 'Je hebt deze code al geclaimd.', 'error') return end
    local reward = json.decode(row.reward_json)
    local ok, text = giveRewardToPlayer(xPlayer, reward)
    if not ok then notify(src, text, 'error') return end
    MySQL.insert.await('INSERT INTO delfzijlrp_reward_claims (code, identifier, player_name) VALUES (?, ?, ?)', { code, xPlayer.identifier, GetPlayerName(src) })
    writeLog('claimcode', GetPlayerName(src), 'claim_code', code)
    discordLog('DRCC code geclaimd', GetPlayerName(src) .. ' claimde ' .. code)
    notify(src, 'Code geclaimd: ' .. row.label, 'success')
end, false)

RegisterNetEvent('delfzijlrp_v3_controlcenter:server:announce', function(message)
    local src = source
    local allowed = adminAllowed(src)
    if not allowed then notify(src, Config.Text.noAccess, 'error') return end
    if not message or message == '' then notify(src, Config.Text.invalid, 'error') return end
    TriggerClientEvent('ox_lib:notify', -1, { title = 'Delfzijl RP', description = message, type = 'inform', duration = 12000 })
    writeLog(GetPlayerName(src), 'Iedereen', 'announce', message)
    discordLog('DRCC stadsbericht', message)
    notify(src, Config.Text.announcement, 'success')
end)
