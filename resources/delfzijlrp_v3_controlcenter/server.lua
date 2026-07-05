local ESX = exports['es_extended']:getSharedObject()

local function adminAllowed(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return false end
    local group = xPlayer.getGroup and xPlayer.getGroup() or 'user'
    return Config.AdminGroups[group] == true, xPlayer
end

local function notify(src, text, kind)
    TriggerClientEvent('ox_lib:notify', src, {
        title = 'DRCC',
        description = text,
        type = kind or 'inform'
    })
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
        adminName or 'unknown',
        targetName or 'unknown',
        action or 'unknown',
        details or ''
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
end)

local function getTarget(targetId)
    targetId = tonumber(targetId)
    if not targetId then return nil end
    return ESX.GetPlayerFromId(targetId)
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
        if xPlayer then
            players[#players + 1] = {
                id = sid,
                name = GetPlayerName(sid),
                identifier = xPlayer.identifier
            }
        end
    end
    return players
end)

RegisterNetEvent('delfzijlrp_v3_controlcenter:server:money', function(targetId, account, amount)
    local src = source
    local allowed = adminAllowed(src)
    if not allowed then notify(src, Config.Text.noAccess, 'error') return end

    local target = getTarget(targetId)
    amount = tonumber(amount) or 0
    if not target or amount <= 0 then notify(src, Config.Text.invalid, 'error') return end

    if account == 'bank' then
        target.addAccountMoney('bank', amount)
    else
        target.addMoney(amount)
        account = 'cash'
    end

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

RegisterNetEvent('delfzijlrp_v3_controlcenter:server:announce', function(message)
    local src = source
    local allowed = adminAllowed(src)
    if not allowed then notify(src, Config.Text.noAccess, 'error') return end
    if not message or message == '' then notify(src, Config.Text.invalid, 'error') return end

    TriggerClientEvent('ox_lib:notify', -1, {
        title = 'Delfzijl RP',
        description = message,
        type = 'inform',
        duration = 12000
    })

    writeLog(GetPlayerName(src), 'Iedereen', 'announce', message)
    discordLog('DRCC stadsbericht', message)
    notify(src, Config.Text.announcement, 'success')
end)
