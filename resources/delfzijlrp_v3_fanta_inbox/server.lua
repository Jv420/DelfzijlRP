local ESX = exports['es_extended']:getSharedObject()

local function isAdmin(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return false end
    local group = xPlayer.getGroup and xPlayer.getGroup() or 'user'
    return Config.AdminGroups[group] == true, xPlayer
end

local function notify(src, text, kind)
    TriggerClientEvent('ox_lib:notify', src, { title = 'Fanta Queue', description = text, type = kind or 'inform' })
end

CreateThread(function()
    MySQL.query.await([[CREATE TABLE IF NOT EXISTS delfzijlrp_fanta_queue (
        id int NOT NULL AUTO_INCREMENT,
        identifier varchar(64) NOT NULL,
        player_name varchar(128) NOT NULL,
        reward_type varchar(32) NOT NULL,
        reward_data longtext NOT NULL,
        status varchar(32) NOT NULL DEFAULT 'pending',
        created_by varchar(128) DEFAULT 'fanta',
        created_at timestamp NOT NULL DEFAULT current_timestamp(),
        approved_by varchar(128) DEFAULT NULL,
        approved_at timestamp NULL DEFAULT NULL,
        claimed_at timestamp NULL DEFAULT NULL,
        PRIMARY KEY (id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]])
end)

local function applyReward(src, row)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return false, 'player offline' end
    local data = json.decode(row.reward_data or '{}') or {}

    if row.reward_type == 'money' then
        local amount = tonumber(data.amount) or 0
        local account = data.account == 'cash' and 'cash' or 'bank'
        if amount <= 0 then return false, Config.Text.invalid end
        if account == 'cash' then xPlayer.addMoney(amount) else xPlayer.addAccountMoney('bank', amount) end
        return true
    end

    if row.reward_type == 'item' then
        local item = tostring(data.item or '')
        local count = tonumber(data.count) or 1
        if item == '' or count < 1 then return false, Config.Text.invalid end
        if not exports.ox_inventory:Items(item) then return false, 'Item bestaat niet: ' .. item end
        local ok, reason = exports.ox_inventory:AddItem(src, item, count)
        return ok, reason
    end

    return false, 'type nog niet actief'
end

lib.callback.register('delfzijlrp_v3_fanta_inbox:server:listPending', function(source)
    local ok = isAdmin(source)
    if not ok then return {} end
    return MySQL.query.await('SELECT * FROM delfzijlrp_fanta_queue WHERE status = ? ORDER BY id DESC LIMIT 50', { 'pending' }) or {}
end)

lib.callback.register('delfzijlrp_v3_fanta_inbox:server:listMine', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return {} end
    return MySQL.query.await('SELECT * FROM delfzijlrp_fanta_queue WHERE identifier = ? AND status = ? ORDER BY id DESC LIMIT 25', { xPlayer.identifier, 'approved' }) or {}
end)

RegisterNetEvent('delfzijlrp_v3_fanta_inbox:server:approve', function(id)
    local src = source
    local ok = isAdmin(src)
    if not ok then notify(src, Config.Text.noAccess, 'error') return end
    id = tonumber(id)
    if not id then notify(src, Config.Text.invalid, 'error') return end
    MySQL.update.await('UPDATE delfzijlrp_fanta_queue SET status = ?, approved_by = ?, approved_at = NOW() WHERE id = ? AND status = ?', {
        'approved', GetPlayerName(src), id, 'pending'
    })
    notify(src, Config.Text.approved, 'success')
end)

RegisterNetEvent('delfzijlrp_v3_fanta_inbox:server:deny', function(id)
    local src = source
    local ok = isAdmin(src)
    if not ok then notify(src, Config.Text.noAccess, 'error') return end
    id = tonumber(id)
    if not id then notify(src, Config.Text.invalid, 'error') return end
    MySQL.update.await('UPDATE delfzijlrp_fanta_queue SET status = ?, approved_by = ?, approved_at = NOW() WHERE id = ? AND status = ?', {
        'denied', GetPlayerName(src), id, 'pending'
    })
    notify(src, Config.Text.denied, 'warning')
end)

RegisterNetEvent('delfzijlrp_v3_fanta_inbox:server:claim', function(id)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    id = tonumber(id)
    if not id then notify(src, Config.Text.invalid, 'error') return end
    local row = MySQL.single.await('SELECT * FROM delfzijlrp_fanta_queue WHERE id = ? AND identifier = ? AND status = ? LIMIT 1', { id, xPlayer.identifier, 'approved' })
    if not row then notify(src, Config.Text.invalid, 'error') return end
    local ok, reason = applyReward(src, row)
    if not ok then notify(src, reason or Config.Text.invalid, 'error') return end
    MySQL.update.await('UPDATE delfzijlrp_fanta_queue SET status = ?, claimed_at = NOW() WHERE id = ?', { 'claimed', id })
    notify(src, Config.Text.claimed, 'success')
end)

exports('CreateFantaQueue', function(identifier, playerName, rewardType, rewardData, createdBy)
    return MySQL.insert.await('INSERT INTO delfzijlrp_fanta_queue (identifier, player_name, reward_type, reward_data, created_by) VALUES (?, ?, ?, ?, ?)', {
        identifier, playerName, rewardType, json.encode(rewardData or {}), createdBy or 'fanta'
    })
end)
