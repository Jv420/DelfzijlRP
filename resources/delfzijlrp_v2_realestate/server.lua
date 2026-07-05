local ESX = exports['es_extended']:getSharedObject()

local function cfg(id)
    for _, p in ipairs(Config.Properties) do if p.id == id then return p end end
    return nil
end

local function pay(xPlayer, amount)
    if xPlayer.getMoney() >= amount then xPlayer.removeMoney(amount) return true end
    local bank = xPlayer.getAccount('bank')
    if bank and bank.money >= amount then xPlayer.removeAccountMoney('bank', amount) return true end
    return false
end

CreateThread(function()
    MySQL.query.await([[CREATE TABLE IF NOT EXISTS delfzijlrp_realestate (
        id varchar(64) NOT NULL,
        owner varchar(64) DEFAULT NULL,
        status varchar(32) NOT NULL DEFAULT 'available',
        price int NOT NULL DEFAULT 0,
        updated_at timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
        PRIMARY KEY (id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]])
    for _, p in ipairs(Config.Properties) do
        MySQL.insert.await('INSERT IGNORE INTO delfzijlrp_realestate (id, price) VALUES (?, ?)', { p.id, p.price })
    end
end)

lib.callback.register('delfzijlrp_v2_realestate:server:list', function(source)
    local rows = MySQL.query.await('SELECT * FROM delfzijlrp_realestate') or {}
    local states = {}; for _, r in ipairs(rows) do states[r.id] = r end
    local out = {}
    for _, p in ipairs(Config.Properties) do out[#out+1] = { config = p, state = states[p.id] } end
    return out
end)

lib.callback.register('delfzijlrp_v2_realestate:server:buy', function(source, id)
    local xPlayer = ESX.GetPlayerFromId(source); local p = cfg(id)
    if not xPlayer or not p then return false, Config.Text.invalid end
    local state = MySQL.single.await('SELECT * FROM delfzijlrp_realestate WHERE id = ? LIMIT 1', { id })
    if state and state.status == 'owned' then return false, Config.Text.alreadyOwned end
    if not pay(xPlayer, p.price) then return false, Config.Text.noMoney end
    MySQL.update.await('UPDATE delfzijlrp_realestate SET owner = ?, status = ? WHERE id = ?', { xPlayer.identifier, 'owned', id })
    return true, Config.Text.bought
end)

lib.callback.register('delfzijlrp_v2_realestate:server:sell', function(source, id)
    local xPlayer = ESX.GetPlayerFromId(source); local p = cfg(id)
    if not xPlayer or not p then return false, Config.Text.invalid end
    local state = MySQL.single.await('SELECT * FROM delfzijlrp_realestate WHERE id = ? LIMIT 1', { id })
    if not state or state.owner ~= xPlayer.identifier then return false, Config.Text.notOwner end
    local payout = math.floor(p.price * 0.75)
    xPlayer.addAccountMoney('bank', payout)
    MySQL.update.await('UPDATE delfzijlrp_realestate SET owner = NULL, status = ? WHERE id = ?', { 'available', id })
    return true, Config.Text.sold .. ' Uitbetaling: €' .. payout
end)
