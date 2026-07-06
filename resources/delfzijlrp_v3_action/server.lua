local ESX = exports['es_extended']:getSharedObject()

local function notify(src, text, kind)
    TriggerClientEvent('ox_lib:notify', src, { title = 'Action Delfzijl', description = text, type = kind or 'inform' })
end

local function productByItem(item)
    for _, p in ipairs(Config.Products) do
        if p.item == item then return p end
    end
    return nil
end

CreateThread(function()
    Wait(3000)
    for _, p in ipairs(Config.Products) do
        MySQL.insert.await('INSERT IGNORE INTO delfzijlrp_business_stock (business_id, item, label, amount, price) VALUES (?, ?, ?, ?, ?)', {
            Config.BusinessId, p.item, p.label, 999, p.price
        })
    end
end)

RegisterNetEvent('delfzijlrp_v3_action:server:buy', function(item, count)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local product = productByItem(item)
    count = tonumber(count) or 1
    if not product or count < 1 then notify(src, Config.Text.invalid, 'error') return end

    local total = product.price * count
    if xPlayer.getMoney() < total then notify(src, Config.Text.noMoney, 'error') return end
    if not exports.ox_inventory:Items(product.item) then notify(src, Config.Text.missingItem .. ' (' .. product.item .. ')', 'error') return end

    xPlayer.removeMoney(total)
    local ok, reason = exports.ox_inventory:AddItem(src, product.item, (product.amount or 1) * count)
    if not ok then
        xPlayer.addMoney(total)
        notify(src, reason or Config.Text.invalid, 'error')
        return
    end

    MySQL.update.await('UPDATE delfzijlrp_businesses SET balance = balance + ?, turnover = turnover + ? WHERE id = ?', { total, total, Config.BusinessId })
    MySQL.update.await('UPDATE delfzijlrp_business_stock SET amount = GREATEST(amount - ?, 0) WHERE business_id = ? AND item = ?', { count, Config.BusinessId, product.item })
    exports['delfzijlrp_v3_business_core']:AddLog(Config.BusinessId, 'sale', total, product.label .. ' x' .. count, GetPlayerName(src))
    notify(src, Config.Text.bought, 'success')
end)
