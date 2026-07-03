local ESX = exports['es_extended']:getSharedObject()

local function getPlayer(source)
    return ESX.GetPlayerFromId(source)
end

local function getIdentifier(source)
    local xPlayer = getPlayer(source)
    return xPlayer and xPlayer.identifier or nil
end

local function notify(source, message, type)
    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Delfzijl RP Housing',
        description = message,
        type = type or 'inform'
    })
end

local function getHouseConfig(houseId)
    for _, house in ipairs(Config.Houses) do
        if house.id == houseId then return house end
    end
    return nil
end

local function pay(source, amount)
    local xPlayer = getPlayer(source)
    if not xPlayer then return false end

    if xPlayer.getMoney() >= amount then
        xPlayer.removeMoney(amount)
        return true
    end

    if xPlayer.getAccount('bank').money >= amount then
        xPlayer.removeAccountMoney('bank', amount)
        return true
    end

    return false
end

local function ensureHouse(houseId)
    MySQL.insert.await('INSERT IGNORE INTO delfzijlrp_houses (house_id) VALUES (?)', { houseId })
end

local function hasKey(identifier, houseId)
    local found = MySQL.scalar.await('SELECT id FROM delfzijlrp_house_keys WHERE house_id = ? AND identifier = ? LIMIT 1', {
        houseId,
        identifier
    })
    return found ~= nil
end

exports('HasHouseAccess', function(source, houseId)
    local identifier = getIdentifier(source)
    if not identifier then return false end

    ensureHouse(houseId)
    local house = MySQL.single.await('SELECT * FROM delfzijlrp_houses WHERE house_id = ? LIMIT 1', { houseId })
    if house and house.owner_identifier == identifier then return true end
    return hasKey(identifier, houseId)
end)

lib.callback.register('delfzijlrp_housing:server:getHouseState', function(source, houseId)
    ensureHouse(houseId)
    local state = MySQL.single.await('SELECT * FROM delfzijlrp_houses WHERE house_id = ? LIMIT 1', { houseId })
    local identifier = getIdentifier(source)
    local access = false

    if identifier then
        access = (state and state.owner_identifier == identifier) or hasKey(identifier, houseId)
    end

    return { state = state, access = access }
end)

lib.callback.register('delfzijlrp_housing:server:getMyHouses', function(source)
    local identifier = getIdentifier(source)
    if not identifier then return {} end

    return MySQL.query.await([[SELECT h.* FROM delfzijlrp_houses h
        LEFT JOIN delfzijlrp_house_keys k ON k.house_id = h.house_id
        WHERE h.owner_identifier = ? OR k.identifier = ?
        ORDER BY h.house_id ASC]], { identifier, identifier }) or {}
end)

RegisterNetEvent('delfzijlrp_housing:server:buyHouse', function(houseId)
    local source = source
    local identifier = getIdentifier(source)
    local houseConfig = getHouseConfig(houseId)
    if not identifier or not houseConfig then return end

    ensureHouse(houseId)
    local state = MySQL.single.await('SELECT * FROM delfzijlrp_houses WHERE house_id = ? LIMIT 1', { houseId })
    if state and state.owned == 1 then
        notify(source, Config.Text.alreadyOwned, 'error')
        return
    end

    if not pay(source, houseConfig.price) then
        notify(source, Config.Text.noMoney, 'error')
        return
    end

    MySQL.update.await('UPDATE delfzijlrp_houses SET owner_identifier = ?, owned = 1, rented = 0, rent_until = NULL WHERE house_id = ?', {
        identifier,
        houseId
    })
    MySQL.insert.await('INSERT IGNORE INTO delfzijlrp_house_keys (house_id, identifier, key_type) VALUES (?, ?, ?)', {
        houseId,
        identifier,
        'owner'
    })

    exports.ox_inventory:RegisterStash(('house_%s'):format(houseId), houseConfig.label, Config.DefaultStashSlots, Config.DefaultStashWeight, identifier)
    notify(source, Config.Text.bought, 'success')
end)

RegisterNetEvent('delfzijlrp_housing:server:rentHouse', function(houseId)
    local source = source
    local identifier = getIdentifier(source)
    local houseConfig = getHouseConfig(houseId)
    if not identifier or not houseConfig then return end

    ensureHouse(houseId)
    local state = MySQL.single.await('SELECT * FROM delfzijlrp_houses WHERE house_id = ? LIMIT 1', { houseId })
    if state and state.owned == 1 then
        notify(source, Config.Text.alreadyOwned, 'error')
        return
    end

    if not pay(source, houseConfig.rent) then
        notify(source, Config.Text.noMoney, 'error')
        return
    end

    local rentUntil = os.date('%Y-%m-%d %H:%M:%S', os.time() + (Config.RentDays * 86400))
    MySQL.update.await('UPDATE delfzijlrp_houses SET owner_identifier = ?, owned = 0, rented = 1, rent_until = ? WHERE house_id = ?', {
        identifier,
        rentUntil,
        houseId
    })
    MySQL.insert.await('INSERT IGNORE INTO delfzijlrp_house_keys (house_id, identifier, key_type) VALUES (?, ?, ?)', {
        houseId,
        identifier,
        'tenant'
    })

    notify(source, Config.Text.rented, 'success')
end)

RegisterNetEvent('delfzijlrp_housing:server:giveKey', function(houseId, targetId)
    local source = source
    local identifier = getIdentifier(source)
    local target = getPlayer(tonumber(targetId))
    if not identifier or not target then
        notify(source, Config.Text.invalidInput, 'error')
        return
    end

    ensureHouse(houseId)
    local state = MySQL.single.await('SELECT * FROM delfzijlrp_houses WHERE house_id = ? LIMIT 1', { houseId })
    if not state or state.owner_identifier ~= identifier then
        notify(source, Config.Text.notOwner, 'error')
        return
    end

    MySQL.insert.await('INSERT IGNORE INTO delfzijlrp_house_keys (house_id, identifier, key_type) VALUES (?, ?, ?)', {
        houseId,
        target.identifier,
        'shared'
    })

    notify(source, Config.Text.keyGiven, 'success')
    notify(target.source, Config.Text.keyReceived, 'success')
end)

RegisterNetEvent('delfzijlrp_housing:server:openStash', function(houseId)
    local source = source
    local identifier = getIdentifier(source)
    local houseConfig = getHouseConfig(houseId)
    if not identifier or not houseConfig then return end

    local access = exports[GetCurrentResourceName()]:HasHouseAccess(source, houseId)
    if not access then
        notify(source, Config.Text.noAccess, 'error')
        return
    end

    exports.ox_inventory:RegisterStash(('house_%s'):format(houseId), houseConfig.label, Config.DefaultStashSlots, Config.DefaultStashWeight)
    TriggerClientEvent('delfzijlrp_housing:client:openStash', source, ('house_%s'):format(houseId))
end)
