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
        title = 'Delfzijl Marktplaats',
        description = message,
        type = type or 'inform'
    })
end

local function getName(identifier, fallback)
    local identity = MySQL.single.await('SELECT firstname, lastname FROM delfzijlrp_identities WHERE identifier = ? LIMIT 1', { identifier })
    if identity then return identity.firstname .. ' ' .. identity.lastname end
    return fallback
end

local function pay(source, amount)
    local xPlayer = getPlayer(source)
    if not xPlayer then return false end
    if xPlayer.getMoney() >= amount then xPlayer.removeMoney(amount) return true end
    if xPlayer.getAccount('bank').money >= amount then xPlayer.removeAccountMoney('bank', amount) return true end
    return false
end

lib.callback.register('delfzijlrp_marketplace:server:getListings', function(source, category)
    if category and Config.Categories[category] then
        return MySQL.query.await('SELECT * FROM delfzijlrp_marketplace_listings WHERE category = ? AND status = ? ORDER BY created_at DESC LIMIT 50', { category, 'active' }) or {}
    end

    return MySQL.query.await('SELECT * FROM delfzijlrp_marketplace_listings WHERE status = ? ORDER BY created_at DESC LIMIT 50', { 'active' }) or {}
end)

lib.callback.register('delfzijlrp_marketplace:server:getMyListings', function(source)
    local identifier = getIdentifier(source)
    if not identifier then return {} end
    return MySQL.query.await('SELECT * FROM delfzijlrp_marketplace_listings WHERE seller_identifier = ? ORDER BY created_at DESC LIMIT 50', { identifier }) or {}
end)

lib.callback.register('delfzijlrp_marketplace:server:getListingInterest', function(source, listingId)
    local identifier = getIdentifier(source)
    if not identifier then return {} end

    local listing = MySQL.single.await('SELECT * FROM delfzijlrp_marketplace_listings WHERE id = ? LIMIT 1', { tonumber(listingId) })
    if not listing or listing.seller_identifier ~= identifier then return {} end

    return MySQL.query.await('SELECT * FROM delfzijlrp_marketplace_interest WHERE listing_id = ? ORDER BY created_at DESC LIMIT 30', { tonumber(listingId) }) or {}
end)

RegisterNetEvent('delfzijlrp_marketplace:server:createListing', function(data)
    local source = source
    local identifier = getIdentifier(source)
    if not identifier or type(data) ~= 'table' then return end

    local category = data.category or 'other'
    local title = tostring(data.title or '')
    local description = tostring(data.description or '')
    local price = tonumber(data.price) or 0

    if not Config.Categories[category] or #title < 3 or #title > Config.MaxTitleLength or #description < 3 or #description > Config.MaxDescriptionLength or price < 0 then
        notify(source, Config.Text.invalidInput, 'error')
        return
    end

    if not pay(source, Config.ListingFee) then
        notify(source, Config.Text.noMoney, 'error')
        return
    end

    MySQL.insert.await([[INSERT INTO delfzijlrp_marketplace_listings
        (seller_identifier, seller_name, category, title, description, price, reference_type, reference_value)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)]], {
        identifier,
        getName(identifier, GetPlayerName(source)),
        category,
        title,
        description,
        price,
        data.reference_type,
        data.reference_value
    })

    notify(source, Config.Text.created, 'success')
end)

RegisterNetEvent('delfzijlrp_marketplace:server:setStatus', function(listingId, status)
    local source = source
    local identifier = getIdentifier(source)
    listingId = tonumber(listingId)
    if not identifier or not listingId or not Config.Status[status] then return end

    local seller = MySQL.scalar.await('SELECT seller_identifier FROM delfzijlrp_marketplace_listings WHERE id = ? LIMIT 1', { listingId })
    if seller ~= identifier then
        notify(source, Config.Text.notOwner, 'error')
        return
    end

    MySQL.update.await('UPDATE delfzijlrp_marketplace_listings SET status = ? WHERE id = ?', { status, listingId })
    notify(source, Config.Text.updated, 'success')
end)

RegisterNetEvent('delfzijlrp_marketplace:server:sendInterest', function(listingId, message)
    local source = source
    local identifier = getIdentifier(source)
    listingId = tonumber(listingId)
    if not identifier or not listingId then return end

    local listing = MySQL.single.await('SELECT * FROM delfzijlrp_marketplace_listings WHERE id = ? AND status = ? LIMIT 1', { listingId, 'active' })
    if not listing then
        notify(source, Config.Text.notFound, 'error')
        return
    end

    local buyerName = getName(identifier, GetPlayerName(source))
    MySQL.insert.await('INSERT INTO delfzijlrp_marketplace_interest (listing_id, buyer_identifier, buyer_name, message) VALUES (?, ?, ?, ?)', {
        listingId,
        identifier,
        buyerName,
        message or 'Ik heb interesse.'
    })

    notify(source, Config.Text.interestSent, 'success')

    for _, xPlayer in pairs(ESX.GetExtendedPlayers()) do
        if xPlayer.identifier == listing.seller_identifier then
            notify(xPlayer.source, ('Nieuwe interesse op advertentie: %s'):format(listing.title), 'inform')
        end
    end
end)
