local ESX = exports['es_extended']:getSharedObject()

local function findPlace(placeId)
    for _, place in ipairs(Config.Places) do
        if place.id == placeId then return place end
    end
    return nil
end

local function findItem(place, itemName)
    for _, item in ipairs(place.items or {}) do
        if item.name == itemName then return item end
    end
    return nil
end

local function pay(xPlayer, amount)
    if xPlayer.getMoney() >= amount then xPlayer.removeMoney(amount) return true end
    local bank = xPlayer.getAccount('bank')
    if bank and bank.money >= amount then xPlayer.removeAccountMoney('bank', amount) return true end
    return false
end

lib.callback.register('delfzijlrp_v2_horeca:server:buy', function(source, placeId, itemName, amount, tip)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false, Config.Text.invalid end

    amount = tonumber(amount) or 1
    tip = tonumber(tip) or 0
    if amount < 1 or amount > Config.Settings.maxAmount then return false, Config.Text.invalid end
    if tip < 0 or tip > Config.Settings.maxTip then return false, Config.Text.invalid end

    local place = findPlace(placeId)
    if not place then return false, Config.Text.invalid end

    local item = findItem(place, itemName)
    if not item then return false, Config.Text.invalid end

    if not exports.ox_inventory:Items(item.name) then
        return false, Config.Text.missing .. ' (' .. item.name .. ')'
    end

    local total = (item.price * amount) + tip
    if not pay(xPlayer, total) then return false, Config.Text.noMoney end

    local ok, reason = exports.ox_inventory:AddItem(source, item.name, amount)
    if not ok then
        xPlayer.addMoney(total)
        return false, reason or 'Inventory vol.'
    end

    return true, Config.Text.bought
end)
