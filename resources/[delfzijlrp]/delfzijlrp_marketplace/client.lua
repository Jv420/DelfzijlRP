local function notify(message, type)
    lib.notify({ title = 'Delfzijl Marktplaats', description = message, type = type or 'inform' })
end

local function categoryOptions()
    local options = {}
    for value, label in pairs(Config.Categories) do
        options[#options + 1] = { value = value, label = label }
    end
    return options
end

local function statusOptions()
    local options = {}
    for value, label in pairs(Config.Status) do
        options[#options + 1] = { value = value, label = label }
    end
    return options
end

local function createListing()
    local input = lib.inputDialog('Advertentie plaatsen', {
        { type = 'select', label = 'Categorie', required = true, options = categoryOptions() },
        { type = 'input', label = 'Titel', required = true, min = 3, max = Config.MaxTitleLength },
        { type = 'textarea', label = 'Omschrijving', required = true, min = 3, max = Config.MaxDescriptionLength },
        { type = 'number', label = 'Prijs', required = true, min = 0, max = 100000000 },
        { type = 'input', label = 'Referentie type', description = 'Bijv. kenteken, woning, item', required = false, max = 32 },
        { type = 'input', label = 'Referentie waarde', description = 'Bijv. 12-ABC-3', required = false, max = 128 }
    })

    if not input then return end
    TriggerServerEvent('delfzijlrp_marketplace:server:createListing', {
        category = input[1],
        title = input[2],
        description = input[3],
        price = input[4],
        reference_type = input[5],
        reference_value = input[6]
    })
end

local function sendInterest(listing)
    local input = lib.inputDialog('Interesse sturen', {
        { type = 'textarea', label = 'Bericht', default = 'Ik heb interesse in je advertentie.', required = true, min = 3, max = 500 }
    })
    if input then
        TriggerServerEvent('delfzijlrp_marketplace:server:sendInterest', listing.id, input[1])
    end
end

local function openListing(listing)
    lib.registerContext({
        id = 'delfzijlrp_marketplace_listing',
        title = listing.title,
        options = {
            { title = 'Prijs', description = ('€%s'):format(listing.price), icon = 'euro-sign', readOnly = true },
            { title = 'Verkoper', description = listing.seller_name or 'Onbekend', icon = 'user', readOnly = true },
            { title = 'Categorie', description = Config.Categories[listing.category] or listing.category, icon = 'tag', readOnly = true },
            { title = 'Omschrijving', description = listing.description, icon = 'align-left', readOnly = true },
            { title = 'Referentie', description = listing.reference_value or 'Geen', icon = 'bookmark', readOnly = true },
            { title = 'Interesse sturen', icon = 'paper-plane', onSelect = function() sendInterest(listing) end }
        }
    })
    lib.showContext('delfzijlrp_marketplace_listing')
end

local function browseListings(category)
    local listings = lib.callback.await('delfzijlrp_marketplace:server:getListings', false, category) or {}
    if #listings == 0 then
        notify(Config.Text.noListings, 'inform')
        return
    end

    local options = {}
    for _, listing in ipairs(listings) do
        options[#options + 1] = {
            title = ('%s | €%s'):format(listing.title, listing.price),
            description = ('%s | %s'):format(Config.Categories[listing.category] or listing.category, listing.seller_name or 'Onbekend'),
            icon = 'store',
            onSelect = function() openListing(listing) end
        }
    end

    lib.registerContext({ id = 'delfzijlrp_marketplace_browse', title = 'Advertenties', options = options })
    lib.showContext('delfzijlrp_marketplace_browse')
end

local function browseByCategory()
    local options = {
        { title = 'Alle advertenties', icon = 'list', onSelect = function() browseListings(nil) end }
    }
    for category, label in pairs(Config.Categories) do
        options[#options + 1] = {
            title = label,
            icon = 'tag',
            onSelect = function() browseListings(category) end
        }
    end
    lib.registerContext({ id = 'delfzijlrp_marketplace_categories', title = 'Categorieën', options = options })
    lib.showContext('delfzijlrp_marketplace_categories')
end

local function showInterest(listing)
    local interest = lib.callback.await('delfzijlrp_marketplace:server:getListingInterest', false, listing.id) or {}
    local options = {}
    for _, row in ipairs(interest) do
        options[#options + 1] = {
            title = row.buyer_name or 'Onbekend',
            description = row.message or '',
            icon = 'envelope',
            readOnly = true
        }
    end
    if #options == 0 then
        options[#options + 1] = { title = 'Geen interesseberichten', icon = 'circle-info', readOnly = true }
    end
    lib.registerContext({ id = 'delfzijlrp_marketplace_interest', title = 'Interesseberichten', options = options })
    lib.showContext('delfzijlrp_marketplace_interest')
end

local function manageListing(listing)
    lib.registerContext({
        id = 'delfzijlrp_marketplace_manage_listing',
        title = listing.title,
        options = {
            { title = 'Status', description = Config.Status[listing.status] or listing.status, icon = 'circle-info', readOnly = true },
            { title = 'Interesseberichten', icon = 'envelope', onSelect = function() showInterest(listing) end },
            { title = 'Markeer gereserveerd', icon = 'bookmark', onSelect = function() TriggerServerEvent('delfzijlrp_marketplace:server:setStatus', listing.id, 'reserved') end },
            { title = 'Markeer verkocht', icon = 'circle-check', onSelect = function() TriggerServerEvent('delfzijlrp_marketplace:server:setStatus', listing.id, 'sold') end },
            { title = 'Annuleren', icon = 'ban', onSelect = function() TriggerServerEvent('delfzijlrp_marketplace:server:setStatus', listing.id, 'cancelled') end }
        }
    })
    lib.showContext('delfzijlrp_marketplace_manage_listing')
end

local function myListings()
    local listings = lib.callback.await('delfzijlrp_marketplace:server:getMyListings', false) or {}
    if #listings == 0 then
        notify('Je hebt geen advertenties.', 'inform')
        return
    end

    local options = {}
    for _, listing in ipairs(listings) do
        options[#options + 1] = {
            title = ('%s | €%s'):format(listing.title, listing.price),
            description = ('Status: %s'):format(Config.Status[listing.status] or listing.status),
            icon = 'clipboard-list',
            onSelect = function() manageListing(listing) end
        }
    end
    lib.registerContext({ id = 'delfzijlrp_marketplace_my', title = 'Mijn advertenties', options = options })
    lib.showContext('delfzijlrp_marketplace_my')
end

local function openMarketplace()
    lib.registerContext({
        id = 'delfzijlrp_marketplace_main',
        title = 'Delfzijl Marktplaats',
        options = {
            { title = 'Advertenties bekijken', icon = 'store', onSelect = browseByCategory },
            { title = ('Advertentie plaatsen (€%s)'):format(Config.ListingFee), icon = 'plus', onSelect = createListing },
            { title = 'Mijn advertenties', icon = 'clipboard-list', onSelect = myListings }
        }
    })
    lib.showContext('delfzijlrp_marketplace_main')
end

RegisterCommand(Config.Command, openMarketplace, false)
RegisterCommand(Config.PhoneCommand, openMarketplace, false)
