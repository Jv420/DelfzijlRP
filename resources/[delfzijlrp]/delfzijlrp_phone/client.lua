local function notify(message, type)
    lib.notify({ title = 'Delfzijl RP Phone', description = message, type = type or 'inform' })
end

local function openIdentityApp()
    local profile = lib.callback.await('delfzijlrp_phone:server:getProfile', false)
    if not profile then
        notify(Config.Text.noProfile, 'error')
        return
    end

    lib.registerContext({
        id = 'delfzijlrp_phone_identity',
        title = 'Delfzijl ID',
        options = {
            { title = 'Delfzijl ID', description = profile.delfzijl_id, icon = 'id-card', readOnly = true },
            { title = 'Naam', description = profile.firstname .. ' ' .. profile.lastname, icon = 'user', readOnly = true },
            { title = 'Geboortedatum', description = profile.dateofbirth, icon = 'cake-candles', readOnly = true },
            { title = 'Nationaliteit', description = profile.nationality or 'Nederlands', icon = 'flag', readOnly = true }
        }
    })

    lib.showContext('delfzijlrp_phone_identity')
end

local function openDispatchApp()
    local options = {}
    for value, data in pairs({
        emergency = { label = '112 Spoedmelding' },
        medical = { label = 'Ambulance' },
        roadside = { label = 'ANWB Pechhulp' },
        taxi = { label = 'Taxi oproep' }
    }) do
        options[#options + 1] = {
            title = data.label,
            icon = 'tower-broadcast',
            onSelect = function()
                local input = lib.inputDialog(data.label, {
                    { type = 'textarea', label = 'Omschrijving', required = true, min = 3, max = 500 }
                })
                if not input then return end
                local coords = GetEntityCoords(PlayerPedId())
                TriggerServerEvent('delfzijlrp_dispatch:server:createReport', value, input[1], { x = coords.x, y = coords.y, z = coords.z })
            end
        }
    end

    lib.registerContext({ id = 'delfzijlrp_phone_dispatch', title = '112 & Services', options = options })
    lib.showContext('delfzijlrp_phone_dispatch')
end

local function openAdsApp()
    local ads = lib.callback.await('delfzijlrp_phone:server:getAds', false) or {}
    local options = {
        {
            title = ('Advertentie plaatsen (€%s)'):format(Config.Advertisement.price),
            icon = 'plus',
            onSelect = function()
                local input = lib.inputDialog('Advertentie plaatsen', {
                    { type = 'textarea', label = 'Bericht', required = true, min = 3, max = Config.Advertisement.maxLength }
                })
                if input then
                    TriggerServerEvent('delfzijlrp_phone:server:postAd', input[1])
                end
            end
        }
    }

    for _, ad in ipairs(ads) do
        options[#options + 1] = {
            title = ad.author_name or 'Onbekend',
            description = ad.message,
            icon = 'rectangle-ad',
            readOnly = true
        }
    end

    lib.registerContext({ id = 'delfzijlrp_phone_ads', title = 'Advertenties', options = options })
    lib.showContext('delfzijlrp_phone_ads')
end

local function addContactDialog()
    local input = lib.inputDialog('Contact toevoegen', {
        { type = 'input', label = 'Naam', required = true, min = 2, max = 96 },
        { type = 'input', label = 'Telefoonnummer', required = true, min = 2, max = 32 },
        { type = 'input', label = 'Notitie', required = false, max = 255 }
    })

    if not input then return end
    TriggerServerEvent('delfzijlrp_phone:server:addContact', input[1], input[2], input[3])
end

local function openContactsApp()
    local contacts = lib.callback.await('delfzijlrp_phone:server:getContacts', false) or {}
    local options = {
        { title = 'Contact toevoegen', icon = 'user-plus', onSelect = addContactDialog }
    }

    for _, contact in ipairs(contacts) do
        options[#options + 1] = {
            title = contact.name,
            description = contact.phone_number .. (contact.note and (' | ' .. contact.note) or ''),
            icon = 'address-book',
            onSelect = function()
                lib.registerContext({
                    id = 'delfzijlrp_phone_contact_detail',
                    title = contact.name,
                    options = {
                        { title = 'Nummer', description = contact.phone_number, icon = 'phone', readOnly = true },
                        { title = 'Verwijderen', icon = 'trash', onSelect = function() TriggerServerEvent('delfzijlrp_phone:server:deleteContact', contact.id) end }
                    }
                })
                lib.showContext('delfzijlrp_phone_contact_detail')
            end
        }
    end

    if #contacts == 0 then
        options[#options + 1] = { title = 'Geen contacten', icon = 'circle-info', readOnly = true }
    end

    lib.registerContext({ id = 'delfzijlrp_phone_contacts', title = 'Contacten', options = options })
    lib.showContext('delfzijlrp_phone_contacts')
end

local function openPhone()
    local canOpen = lib.callback.await('delfzijlrp_phone:server:canOpen', false)
    if not canOpen then
        notify(Config.Text.noPhone, 'error')
        return
    end

    lib.registerContext({
        id = 'delfzijlrp_phone_main',
        title = 'Delfzijl RP Phone',
        options = {
            { title = Config.Apps.identity.label, icon = Config.Apps.identity.icon, onSelect = openIdentityApp },
            { title = Config.Apps.dispatch.label, icon = Config.Apps.dispatch.icon, onSelect = openDispatchApp },
            { title = Config.Apps.ads.label, icon = Config.Apps.ads.icon, onSelect = openAdsApp },
            { title = Config.Apps.contacts.label, icon = Config.Apps.contacts.icon, onSelect = openContactsApp },
            { title = Config.Apps.bank.label, description = 'Opent huidige bankmodule', icon = Config.Apps.bank.icon, onSelect = function() ExecuteCommand('bank') end },
            { title = Config.Apps.garage.label, description = 'RDW bekijken via /rdw', icon = Config.Apps.garage.icon, onSelect = function() ExecuteCommand('rdw') end },
            { title = Config.Apps.business.label, description = 'Opent bedrijvenmodule', icon = Config.Apps.business.icon, onSelect = function() ExecuteCommand('bedrijf') end }
        }
    })

    lib.showContext('delfzijlrp_phone_main')
end

RegisterCommand(Config.Command, openPhone, false)
RegisterKeyMapping(Config.Command, 'Delfzijl RP telefoon openen', 'keyboard', 'F1')

RegisterNetEvent('delfzijlrp_phone:client:newAd', function(authorName, message)
    lib.notify({
        title = ('Advertentie | %s'):format(authorName or 'Onbekend'),
        description = message,
        type = 'inform',
        duration = Config.Advertisement.duration
    })
end)
