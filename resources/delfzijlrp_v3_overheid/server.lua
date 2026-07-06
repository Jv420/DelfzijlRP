local ESX = exports['es_extended']:getSharedObject()

local function notify(src, text, kind)
    TriggerClientEvent('ox_lib:notify', src, { title = 'Overheid Delfzijl', description = text, type = kind or 'inform' })
end

CreateThread(function()
    MySQL.query.await([[CREATE TABLE IF NOT EXISTS delfzijlrp_digid_accounts (
        identifier varchar(64) NOT NULL,
        player_name varchar(128) NOT NULL,
        digid_number varchar(32) NOT NULL,
        active tinyint NOT NULL DEFAULT 1,
        created_at timestamp NOT NULL DEFAULT current_timestamp(),
        PRIMARY KEY(identifier),
        UNIQUE KEY digid_number (digid_number)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]])

    MySQL.query.await([[CREATE TABLE IF NOT EXISTS delfzijlrp_overheid_logs (
        id int NOT NULL AUTO_INCREMENT,
        identifier varchar(64) NOT NULL,
        player_name varchar(128) NOT NULL,
        action varchar(64) NOT NULL,
        details text NULL,
        created_at timestamp NOT NULL DEFAULT current_timestamp(),
        PRIMARY KEY(id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]])
end)

local function hasDigid(identifier)
    return MySQL.single.await('SELECT * FROM delfzijlrp_digid_accounts WHERE identifier = ? AND active = 1 LIMIT 1', { identifier })
end

local function newDigid()
    return 'DGD-' .. math.random(100000, 999999)
end

lib.callback.register('delfzijlrp_v3_overheid:server:getDigid', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return nil end
    return hasDigid(xPlayer.identifier)
end)

RegisterNetEvent('delfzijlrp_v3_overheid:server:createDigid', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    if hasDigid(xPlayer.identifier) then notify(src, Config.Text.digidExists, 'warning') return end

    local price = tonumber(Config.DigidPrice) or 0
    if price > 0 then
        local bank = xPlayer.getAccount('bank')
        if not bank or bank.money < price then notify(src, Config.Text.noMoney, 'error') return end
        xPlayer.removeAccountMoney('bank', price)
    end

    local number = newDigid()
    MySQL.insert.await('INSERT INTO delfzijlrp_digid_accounts (identifier, player_name, digid_number) VALUES (?, ?, ?)', {
        xPlayer.identifier, GetPlayerName(src), number
    })
    MySQL.insert.await('INSERT INTO delfzijlrp_overheid_logs (identifier, player_name, action, details) VALUES (?, ?, ?, ?)', {
        xPlayer.identifier, GetPlayerName(src), 'digid_create', number
    })
    notify(src, Config.Text.digidCreated .. ' Nummer: ' .. number, 'success')
end)
