local ESX = exports['es_extended']:getSharedObject()

local function findShop(shopId)
    for _, shop in ipairs(Config.Shops) do
        if shop.id == shopId then return shop end
    end
    return nil
end

local function findItem(shop, itemName)
    for _, item in ipairs(shop.items or {}) do
        if item.name == itemName then return item end
    end
    return nil
end

local function pay(xPlayer, amount)
    if xPlayer.getMoney() >= amount then
        xPlayer.removeMoney(amount)
        return true
    end
    local bank = xPlayer.getAccount('bank')
    if bank and bank.money >= amount then
        xPlayer.removeAccountMoney('bank', amount)
        return true
    end
    return false
end

lib.callback.register('delfzijlrp_v2_shops:server:buyItem', function(source, shopId, itemName, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false, Config.Text.invalid end

    amount = tonumber(amount) or 1
    if amount < 1 or amount > 25 then return false, Config.Text.invalid end

    local shop = findShop(shopId)
    if not shop then return false, Config.Text.invalid end

    local item = findItem(shop, itemName)
    if not item then return false, Config.Text.invalid end

    local invItem = exports.ox_inventory:Items(item.name)
    if not invItem then return false, Config.Text.itemMissing .. ' (' .. item.name .. ')' end

    local total = item.price * amount
    if not pay(xPlayer, total) then return false, Config.Text.noMoney end

    local ok, reason = exports.ox_inventory:AddItem(source, item.name, amount)
    if not ok then
        xPlayer.addMoney(total)
        return false, reason or 'Inventory vol.'
    end

    return true, Config.Text.bought
end)
