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
        title = 'Kadaster Delfzijl',
        description = message,
        type = type or 'inform'
    })
end

local function getPropertyConfig(propertyId)
    for _, property in ipairs(Config.Properties) do
        if property.id == propertyId then return property end
    end
    return nil
end

local function pay(source, amount)
    local xPlayer = getPlayer(source)
    if not xPlayer then return false end
    if xPlayer.getMoney() >= amount then xPlayer.removeMoney(amount) return true end
    if xPlayer.getAccount('bank').money >= amount then xPlayer.removeAccountMoney('bank', amount) return true end
    return false
end

local function ensureProperty(property)
    MySQL.insert.await([[INSERT IGNORE INTO delfzijlrp_kadaster_properties
        (property_id, cadastral, purchase_price)
        VALUES (?, ?, ?)]], { property.id, property.cadastral, property.price })
end

local function hasEntry(identifier, propertyId)
    local found = MySQL.scalar.await('SELECT id FROM delfzijlrp_kadaster_keys WHERE property_id = ? AND identifier = ? LIMIT 1', { propertyId, identifier })
    return found ~= nil
end

local function logProperty(propertyId, source, action, details)
    MySQL.insert.await('INSERT INTO delfzijlrp_kadaster_logs (property_id, actor_identifier, action, details) VALUES (?, ?, ?, ?)', {
        propertyId,
        getIdentifier(source),
        action,
        details
    })
end

local function registerStorage(property, stashType)
    local stash = Config.StashTypes[stashType] or Config.StashTypes.general
    local stashId = ('kadaster_%s_%s'):format(property.id, stashType)
    exports.ox_inventory:RegisterStash(stashId, property.address .. ' - ' .. stash.label, stash.slots, stash.weight)
    return stashId
end

exports('HasPropertyAccess', function(source, propertyId)
    local identifier = getIdentifier(source)
    if not identifier then return false end
    local property = getPropertyConfig(propertyId)
    if not property then return false end
    ensureProperty(property)

    local state = MySQL.single.await('SELECT * FROM delfzijlrp_kadaster_properties WHERE property_id = ? LIMIT 1', { propertyId })
    if state and (state.owner_identifier == identifier or state.co_owner_identifier == identifier) then return true end
    return hasEntry(identifier, propertyId)
end)

lib.callback.register('delfzijlrp_housing_v2:server:getProperties', function(source)
    for _, property in ipairs(Config.Properties) do ensureProperty(property) end
    local rows = MySQL.query.await('SELECT * FROM delfzijlrp_kadaster_properties ORDER BY property_id ASC') or {}
    local states = {}
    for _, row in ipairs(rows) do states[row.property_id] = row end

    local list = {}
    for _, property in ipairs(Config.Properties) do
        list[#list + 1] = { config = property, state = states[property.id] }
    end
    return list
end)

lib.callback.register('delfzijlrp_housing_v2:server:getMyProperties', function(source)
    local identifier = getIdentifier(source)
    if not identifier then return {} end

    return MySQL.query.await([[SELECT p.*, k.key_type
        FROM delfzijlrp_kadaster_properties p
        LEFT JOIN delfzijlrp_kadaster_keys k ON k.property_id = p.property_id AND k.identifier = ?
        WHERE p.owner_identifier = ? OR p.co_owner_identifier = ? OR k.identifier = ?
        ORDER BY p.updated_at DESC]], { identifier, identifier, identifier, identifier }) or {}
end)

lib.callback.register('delfzijlrp_housing_v2:server:getPropertyState', function(source, propertyId)
    local property = getPropertyConfig(propertyId)
    if not property then return nil end
    ensureProperty(property)

    local state = MySQL.single.await('SELECT * FROM delfzijlrp_kadaster_properties WHERE property_id = ? LIMIT 1', { propertyId })
    local identifier = getIdentifier(source)
    local access = identifier and ((state and (state.owner_identifier == identifier or state.co_owner_identifier == identifier)) or hasEntry(identifier, propertyId)) or false
    return { config = property, state = state, access = access }
end)

RegisterNetEvent('delfzijlrp_housing_v2:server:buyProperty', function(propertyId)
    local source = source
    local identifier = getIdentifier(source)
    local property = getPropertyConfig(propertyId)
    if not identifier or not property then return end
    ensureProperty(property)

    local state = MySQL.single.await('SELECT * FROM delfzijlrp_kadaster_properties WHERE property_id = ? LIMIT 1', { propertyId })
    if state and state.status == 'owned' then notify(source, Config.Text.alreadyOwned, 'error') return end

    local transferTax = math.floor(property.price * (Config.Defaults.transferTaxPercent / 100))
    local total = property.price + transferTax
    if not pay(source, total) then notify(source, Config.Text.noMoney, 'error') return end

    MySQL.update.await([[UPDATE delfzijlrp_kadaster_properties
        SET owner_identifier = ?, co_owner_identifier = NULL, status = ?, rented = 0, rent_until = NULL, purchase_price = ?
        WHERE property_id = ?]], { identifier, 'owned', property.price, propertyId })
    MySQL.insert.await('INSERT IGNORE INTO delfzijlrp_kadaster_keys (property_id, identifier, key_type) VALUES (?, ?, ?)', { propertyId, identifier, 'owner' })
    logProperty(propertyId, source, 'purchase', 'price:' .. property.price .. ',tax:' .. transferTax)
    notify(source, Config.Text.bought, 'success')
end)

RegisterNetEvent('delfzijlrp_housing_v2:server:rentProperty', function(propertyId)
    local source = source
    local identifier = getIdentifier(source)
    local property = getPropertyConfig(propertyId)
    if not identifier or not property then return end
    ensureProperty(property)

    local state = MySQL.single.await('SELECT * FROM delfzijlrp_kadaster_properties WHERE property_id = ? LIMIT 1', { propertyId })
    if state and state.status == 'owned' then notify(source, Config.Text.alreadyOwned, 'error') return end
    if not pay(source, property.rent) then notify(source, Config.Text.noMoney, 'error') return end

    local rentUntil = os.date('%Y-%m-%d %H:%M:%S', os.time() + (Config.Defaults.rentDays * 86400))
    MySQL.update.await([[UPDATE delfzijlrp_kadaster_properties
        SET owner_identifier = ?, status = ?, rented = 1, rent_until = ?
        WHERE property_id = ?]], { identifier, 'rented', rentUntil, propertyId })
    MySQL.insert.await('INSERT IGNORE INTO delfzijlrp_kadaster_keys (property_id, identifier, key_type, expires_at) VALUES (?, ?, ?, ?)', { propertyId, identifier, 'tenant', rentUntil })
    logProperty(propertyId, source, 'rent', 'until:' .. rentUntil)
    notify(source, Config.Text.rented, 'success')
end)

RegisterNetEvent('delfzijlrp_housing_v2:server:shareAccess', function(propertyId, targetId, accessType)
    local source = source
    local identifier = getIdentifier(source)
    local target = getPlayer(tonumber(targetId))
    if not identifier or not target then notify(source, Config.Text.invalidInput, 'error') return end

    local state = MySQL.single.await('SELECT * FROM delfzijlrp_kadaster_properties WHERE property_id = ? LIMIT 1', { propertyId })
    if not state or state.owner_identifier ~= identifier then notify(source, Config.Text.notOwner, 'error') return end

    MySQL.insert.await([[INSERT INTO delfzijlrp_kadaster_keys (property_id, identifier, key_type)
        VALUES (?, ?, ?)
        ON DUPLICATE KEY UPDATE key_type = VALUES(key_type)]], { propertyId, target.identifier, accessType or 'shared' })
    logProperty(propertyId, source, 'share_access', target.identifier)
    notify(source, Config.Text.keyGiven, 'success')
    notify(target.source, 'Je hebt toegang tot een pand ontvangen.', 'success')
end)

RegisterNetEvent('delfzijlrp_housing_v2:server:removeAccess', function(propertyId, targetIdentifier)
    local source = source
    local identifier = getIdentifier(source)
    local state = MySQL.single.await('SELECT * FROM delfzijlrp_kadaster_properties WHERE property_id = ? LIMIT 1', { propertyId })
    if not state or state.owner_identifier ~= identifier then notify(source, Config.Text.notOwner, 'error') return end

    MySQL.update.await('DELETE FROM delfzijlrp_kadaster_keys WHERE property_id = ? AND identifier = ? AND key_type != ?', { propertyId, targetIdentifier, 'owner' })
    logProperty(propertyId, source, 'remove_access', targetIdentifier)
    notify(source, Config.Text.keyRevoked, 'success')
end)

RegisterNetEvent('delfzijlrp_housing_v2:server:openStorage', function(propertyId, stashType)
    local source = source
    local property = getPropertyConfig(propertyId)
    if not property then return end
    local access = exports[GetCurrentResourceName()]:HasPropertyAccess(source, propertyId)
    if not access then notify(source, Config.Text.noAccess, 'error') return end

    local stashId = registerStorage(property, stashType or 'general')
    TriggerClientEvent('delfzijlrp_housing_v2:client:openStorage', source, stashId)
end)
