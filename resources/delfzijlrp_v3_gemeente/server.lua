local ESX = exports['es_extended']:getSharedObject()

local function notify(src, text, kind)
    TriggerClientEvent('ox_lib:notify', src, { title = 'Gemeente Delfzijl', description = text, type = kind or 'inform' })
end

local function pay(xPlayer, amount)
    if xPlayer.getMoney() >= amount then xPlayer.removeMoney(amount) return true end
    local bank = xPlayer.getAccount('bank')
    if bank and bank.money >= amount then xPlayer.removeAccountMoney('bank', amount) return true end
    return false
end

CreateThread(function()
    MySQL.query.await([[CREATE TABLE IF NOT EXISTS delfzijlrp_gemeente_logs (
        id int NOT NULL AUTO_INCREMENT,
        identifier varchar(64) NOT NULL,
        player_name varchar(128) NOT NULL,
        action varchar(64) NOT NULL,
        price int NOT NULL DEFAULT 0,
        created_at timestamp NOT NULL DEFAULT current_timestamp(),
        PRIMARY KEY (id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]])
end)

local function addDoc(src, item, meta)
    if not exports.ox_inventory:Items(item) then
        notify(src, Config.Text.missingItem .. ' (' .. item .. ')', 'error')
        return false
    end
    local ok, reason = exports.ox_inventory:AddItem(src, item, 1, meta or {})
    if not ok then notify(src, reason or Config.Text.invalid, 'error') return false end
    return true
end

RegisterNetEvent('delfzijlrp_v3_gemeente:server:request', function(kind)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local price = Config.Prices[kind]
    local item = Config.Items[kind]
    if not price or not item then notify(src, Config.Text.invalid, 'error') return end
    if not pay(xPlayer, price) then notify(src, Config.Text.noMoney, 'error') return end

    local meta = {
        naam = GetPlayerName(src),
        gemeente = 'Delfzijl',
        datum = os.date('%Y-%m-%d'),
        soort = kind
    }

    if not addDoc(src, item, meta) then
        xPlayer.addMoney(price)
        return
    end

    MySQL.insert.await('INSERT INTO delfzijlrp_gemeente_logs (identifier, player_name, action, price) VALUES (?, ?, ?, ?)', {
        xPlayer.identifier, GetPlayerName(src), kind, price
    })
    notify(src, Config.Text.done, 'success')
end)
