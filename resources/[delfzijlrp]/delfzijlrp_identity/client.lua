local function notify(message, type)
    lib.notify({ title = 'Gemeente Delfzijl', description = message, type = type or 'inform' })
end

local function createProfileDialog()
    local input = lib.inputDialog('Delfzijl ID aanvragen', {
        { type = 'input', label = 'Voornaam', required = true, min = 2, max = 32 },
        { type = 'input', label = 'Achternaam', required = true, min = 2, max = 32 },
        { type = 'input', label = 'Geboortedatum', description = 'Bijvoorbeeld 01-01-2000', required = true, min = 8, max = 16 },
        { type = 'select', label = 'Geslacht', required = true, options = {
            { value = 'man', label = 'Man' },
            { value = 'vrouw', label = 'Vrouw' },
            { value = 'anders', label = 'Anders' }
        }},
        { type = 'number', label = 'Lengte in cm', required = true, min = 120, max = 230 },
        { type = 'input', label = 'Nationaliteit', default = 'Nederlands', required = true },
        { type = 'input', label = 'Geboorteplaats', default = 'Delfzijl', required = true }
    })

    if not input then return end

    TriggerServerEvent('delfzijlrp_identity:server:createProfile', {
        firstname = input[1],
        lastname = input[2],
        dateofbirth = input[3],
        sex = input[4],
        height = input[5],
        nationality = input[6],
        birthplace = input[7]
    })
end

local function showProfile()
    local profile = lib.callback.await('delfzijlrp_identity:server:getProfile', false)
    if not profile then
        notify(Config.Text.profileMissing, 'error')
        return
    end

    lib.registerContext({
        id = 'delfzijlrp_identity_profile',
        title = 'Mijn Delfzijl ID',
        options = {
            { title = 'Delfzijl ID', description = profile.delfzijl_id, icon = 'id-card', readOnly = true },
            { title = 'Naam', description = profile.firstname .. ' ' .. profile.lastname, icon = 'user', readOnly = true },
            { title = 'Geboortedatum', description = profile.dateofbirth, icon = 'cake-candles', readOnly = true },
            { title = 'Geslacht', description = profile.sex, icon = 'venus-mars', readOnly = true },
            { title = 'Nationaliteit', description = profile.nationality or 'Nederlands', icon = 'flag', readOnly = true },
            { title = 'Geboorteplaats', description = profile.birthplace or 'Delfzijl', icon = 'location-dot', readOnly = true }
        }
    })

    lib.showContext('delfzijlrp_identity_profile')
end

local function openDocumentsMenu()
    lib.registerContext({
        id = 'delfzijlrp_documents_menu',
        title = 'Documenten aanvragen',
        menu = 'delfzijlrp_cityhall',
        options = {
            { title = ('ID-kaart aanvragen (€%s)'):format(Config.Prices.id_card), icon = 'id-card', onSelect = function() TriggerServerEvent('delfzijlrp_identity:server:issueDocument', 'id_card') end },
            { title = ('Paspoort aanvragen (€%s)'):format(Config.Prices.passport), icon = 'passport', onSelect = function() TriggerServerEvent('delfzijlrp_identity:server:issueDocument', 'passport') end },
            { title = ('Rijbewijs aanvragen (€%s)'):format(Config.Prices.driver_license), icon = 'car', onSelect = function() TriggerServerEvent('delfzijlrp_identity:server:issueDocument', 'driver_license') end },
            { title = ('Uittreksel aanvragen (€%s)'):format(Config.Prices.birth_certificate), icon = 'file-signature', onSelect = function() TriggerServerEvent('delfzijlrp_identity:server:issueDocument', 'birth_certificate') end }
        }
    })

    lib.showContext('delfzijlrp_documents_menu')
end

local function openCityHall()
    lib.registerContext({
        id = 'delfzijlrp_cityhall',
        title = 'Burgerzaken Delfzijl',
        options = {
            { title = 'Delfzijl ID aanmaken', description = 'Maak je fictieve burgerprofiel aan', icon = 'user-plus', onSelect = createProfileDialog },
            { title = 'Mijn Delfzijl ID bekijken', icon = 'id-card', onSelect = showProfile },
            { title = 'Documenten aanvragen', description = 'ID-kaart, paspoort, rijbewijs en uittreksel', icon = 'folder-open', onSelect = openDocumentsMenu }
        }
    })

    lib.showContext('delfzijlrp_cityhall')
end

CreateThread(function()
    Wait(1500)

    exports.ox_target:addSphereZone({
        coords = Config.CityHall.coords,
        radius = Config.CityHall.radius,
        debug = Config.Debug,
        options = {
            {
                name = 'delfzijlrp_identity_cityhall_open',
                icon = 'fa-solid fa-id-card',
                label = 'Burgerzaken openen',
                distance = 2.0,
                onSelect = openCityHall
            }
        }
    })
end)

RegisterCommand('idbalie', openCityHall, false)
RegisterCommand('mijnid', showProfile, false)
