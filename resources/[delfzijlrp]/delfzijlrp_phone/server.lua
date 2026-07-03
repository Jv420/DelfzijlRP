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
        title = 'Delfzijl RP Phone',
        description = message,
        type = type or 'inform'
    })
end

local function hasPhone(source)
    if not Config.RequireItem then return true end
    return (exports.ox_inventory:GetItemCount(source, Config.PhoneItem) or 0) > 0
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

local function getName(identifier, fallback)
    local identity = MySQL.single.await('SELECT firstname, lastname FROM delfzijlrp_identities WHERE identifier = ? LIMIT 1', { identifier })
    if identity then return identity.firstname .. ' ' .. identity.lastname end
    return fallback
end

lib.callback.register('delfzijlrp_phone:server:canOpen', function(source)
    return hasPhone(source)
end)

lib.callback.register('delfzijlrp_phone:server:getProfile', function(source)
    local identifier = getIdentifier(source)
    if not identifier then return nil end
    return MySQL.single.await('SELECT * FROM delfzijlrp_identities WHERE identifier = ? LIMIT 1', { identifier })
end)

lib.callback.register('delfzijlrp_phone:server:getContacts', function(source)
    local identifier = getIdentifier(source)
    if not identifier then return {} end
    return MySQL.query.await('SELECT * FROM delfzijlrp_phone_contacts WHERE identifier = ? ORDER BY name ASC', { identifier }) or {}
end)

lib.callback.register('delfzijlrp_phone:server:getAds', function(source)
    return MySQL.query.await('SELECT * FROM delfzijlrp_phone_ads ORDER BY created_at DESC LIMIT 30') or {}
end)

RegisterNetEvent('delfzijlrp_phone:server:addContact', function(name, phoneNumber, note)
    local source = source
    local identifier = getIdentifier(source)
    if not identifier or not name or not phoneNumber then return end

    MySQL.insert.await('INSERT INTO delfzijlrp_phone_contacts (identifier, name, phone_number, note) VALUES (?, ?, ?, ?)', {
        identifier,
        name,
        phoneNumber,
        note
    })

    notify(source, Config.Text.contactSaved, 'success')
end)

RegisterNetEvent('delfzijlrp_phone:server:deleteContact', function(contactId)
    local source = source
    local identifier = getIdentifier(source)
    contactId = tonumber(contactId)
    if not identifier or not contactId then return end

    MySQL.update.await('DELETE FROM delfzijlrp_phone_contacts WHERE id = ? AND identifier = ?', { contactId, identifier })
    notify(source, Config.Text.contactDeleted, 'success')
end)

RegisterNetEvent('delfzijlrp_phone:server:postAd', function(message)
    local source = source
    local identifier = getIdentifier(source)
    if not identifier or not message or #message < 3 or #message > Config.Advertisement.maxLength then
        notify(source, Config.Text.invalidInput, 'error')
        return
    end

    if not pay(source, Config.Advertisement.price) then
        notify(source, Config.Text.noMoney, 'error')
        return
    end

    local authorName = getName(identifier, GetPlayerName(source))
    MySQL.insert.await('INSERT INTO delfzijlrp_phone_ads (identifier, author_name, message) VALUES (?, ?, ?)', {
        identifier,
        authorName,
        message
    })

    notify(source, Config.Text.adPosted, 'success')

    local players = ESX.GetExtendedPlayers()
    for _, xPlayer in pairs(players) do
        TriggerClientEvent('delfzijlrp_phone:client:newAd', xPlayer.source, authorName, message)
    end
end)
