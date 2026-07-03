local function notify(message, type)
    lib.notify({ title = Config.City.name, description = message, type = type or 'inform' })
end

local function selectOptions(tbl)
    local options = {}
    for value, label in pairs(tbl) do
        options[#options + 1] = { value = value, label = label }
    end
    return options
end

local function openMyTaxes(taxes)
    local options = {}
    for _, tax in ipairs(taxes or {}) do
        options[#options + 1] = {
            title = ('%s | €%s'):format(Config.TaxTypes[tax.tax_type] or tax.tax_type, tax.amount),
            description = ('%s | %s | vervalt: %s'):format(tax.status, tax.description, tax.due_at or 'onbekend'),
            icon = 'file-invoice-dollar',
            onSelect = function()
                if tax.status == 'open' then
                    TriggerServerEvent('delfzijlrp_city:server:payTax', tax.id)
                else
                    notify('Deze aanslag staat niet open.', 'inform')
                end
            end
        }
    end
    if #options == 0 then options[#options + 1] = { title = 'Geen belastingaanslagen', icon = 'circle-info', readOnly = true } end
    lib.registerContext({ id = 'delfzijlrp_city_taxes', title = 'Mijn gemeentebelasting', options = options })
    lib.showContext('delfzijlrp_city_taxes')
end

local function createPermitDialog()
    local input = lib.inputDialog('Vergunning aanvragen', {
        { type = 'select', label = 'Vergunning', required = true, options = selectOptions(Config.PermitTypes) },
        { type = 'textarea', label = 'Reden/omschrijving', required = true, min = 3, max = 255 }
    })
    if input then TriggerServerEvent('delfzijlrp_city:server:createPermit', input[1], input[2]) end
end

local function createReportDialog()
    local input = lib.inputDialog('Melding openbare werken', {
        { type = 'select', label = 'Type melding', required = true, options = selectOptions(Config.PublicWorks) },
        { type = 'textarea', label = 'Omschrijving', required = true, min = 3, max = 500 }
    })
    if input then TriggerServerEvent('delfzijlrp_city:server:createReport', input[1], input[2]) end
end

local function payServiceDialog()
    local options = {}
    for serviceId, service in pairs(Config.Services) do
        options[#options + 1] = {
            title = service.label,
            description = 'Kosten: €' .. service.price,
            icon = 'receipt',
            onSelect = function() TriggerServerEvent('delfzijlrp_city:server:payService', serviceId) end
        }
    end
    lib.registerContext({ id = 'delfzijlrp_city_services', title = 'Gemeenteservices', options = options })
    lib.showContext('delfzijlrp_city_services')
end

local function createTaxDialog()
    local input = lib.inputDialog('Belastingaanslag maken', {
        { type = 'number', label = 'Speler ID', required = true, min = 1 },
        { type = 'select', label = 'Belastingtype', required = true, options = selectOptions(Config.TaxTypes) },
        { type = 'number', label = 'Bedrag', required = true, min = 1, max = Config.Tax.maxAmount },
        { type = 'input', label = 'Omschrijving', required = true, min = 3, max = 255 }
    })
    if input then TriggerServerEvent('delfzijlrp_city:server:createTax', input[1], input[2], input[3], input[4]) end
end

local function treasuryDialog()
    local input = lib.inputDialog('Gemeentekas aanpassen', {
        { type = 'number', label = 'Bedrag (+ of -)', required = true, min = -1000000, max = 1000000 },
        { type = 'input', label = 'Reden', required = true, min = 3, max = 255 }
    })
    if input then TriggerServerEvent('delfzijlrp_city:server:treasuryAdjust', input[1], input[2]) end
end

local function openAdminMenu()
    local data = lib.callback.await('delfzijlrp_city:server:getAdminData', false)
    if not data then notify(Config.Text.noAccess, 'error') return end

    local options = {
        { title = 'Gemeentekas', description = '€' .. data.treasury, icon = 'building-columns', readOnly = true },
        { title = 'Belastingaanslag maken', icon = 'file-invoice-dollar', onSelect = createTaxDialog },
        { title = 'Gemeentekas aanpassen', icon = 'money-bill-transfer', onSelect = treasuryDialog }
    }

    for _, permit in ipairs(data.permits or {}) do
        options[#options + 1] = {
            title = ('Vergunning #%s | %s'):format(permit.id, Config.PermitTypes[permit.permit_type] or permit.permit_type),
            description = (permit.person_name or 'Onbekend') .. ' | ' .. permit.status,
            icon = 'stamp',
            onSelect = function()
                lib.registerContext({
                    id = 'delfzijlrp_city_permit_admin',
                    title = 'Vergunning #' .. permit.id,
                    options = {
                        { title = 'Goedkeuren', icon = 'check', onSelect = function() TriggerServerEvent('delfzijlrp_city:server:updatePermit', permit.id, 'approved') end },
                        { title = 'Afwijzen', icon = 'xmark', onSelect = function() TriggerServerEvent('delfzijlrp_city:server:updatePermit', permit.id, 'rejected') end },
                        { title = 'Reden', description = permit.reason or '', icon = 'file-lines', readOnly = true }
                    }
                })
                lib.showContext('delfzijlrp_city_permit_admin')
            end
        }
    end

    for _, tax in ipairs(data.taxes or {}) do
        options[#options + 1] = {
            title = ('Aanslag #%s | €%s'):format(tax.id, tax.amount),
            description = (tax.person_name or 'Onbekend') .. ' | ' .. (Config.TaxTypes[tax.tax_type] or tax.tax_type) .. ' | ' .. tax.status,
            icon = 'file-invoice-dollar',
            onSelect = function()
                if tax.status == 'open' then TriggerServerEvent('delfzijlrp_city:server:cancelTax', tax.id) end
            end
        }
    end

    lib.registerContext({ id = 'delfzijlrp_city_admin', title = 'Gemeenteraad / Beheer', options = options })
    lib.showContext('delfzijlrp_city_admin')
end

local function openCityHall()
    local data = lib.callback.await('delfzijlrp_city:server:getOverview', false)
    if not data then return end
    local identity = data.identity
    local profile = identity and (identity.firstname .. ' ' .. identity.lastname .. ' | ' .. (identity.delfzijl_id or 'geen ID')) or 'Geen Delfzijl ID gevonden'

    local options = {
        { title = 'Burgerprofiel', description = profile, icon = 'id-card', readOnly = true },
        { title = 'Gemeenteservices', icon = 'receipt', onSelect = payServiceDialog },
        { title = 'Vergunning aanvragen', icon = 'stamp', onSelect = createPermitDialog },
        { title = 'Melding openbare werken', icon = 'road', onSelect = createReportDialog },
        { title = 'Mijn belastingaanslagen', icon = 'file-invoice-dollar', onSelect = function() openMyTaxes(data.taxes) end }
    }

    if data.isGovernment then
        options[#options + 1] = { title = 'Gemeenteraad / beheer', description = 'Gemeentekas: €' .. data.treasury, icon = 'building-columns', onSelect = openAdminMenu }
    end

    lib.registerContext({ id = 'delfzijlrp_city_main', title = Config.CityHall.label, options = options })
    lib.showContext('delfzijlrp_city_main')
end

CreateThread(function()
    Wait(1500)
    if Config.CityHall.blip then
        local blip = AddBlipForCoord(Config.CityHall.coords.x, Config.CityHall.coords.y, Config.CityHall.coords.z)
        SetBlipSprite(blip, Config.CityHall.blip.sprite)
        SetBlipColour(blip, Config.CityHall.blip.color)
        SetBlipScale(blip, Config.CityHall.blip.scale)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(Config.CityHall.label)
        EndTextCommandSetBlipName(blip)
    end

    exports.ox_target:addSphereZone({
        coords = Config.CityHall.coords,
        radius = Config.CityHall.radius,
        debug = Config.Debug,
        options = {{ name = 'city_hall_open', icon = 'fa-solid fa-building-columns', label = Config.Text.openCityHall, onSelect = openCityHall }}
    })
end)

RegisterCommand(Config.Command, openCityHall, false)
RegisterCommand(Config.AdminCommand, openAdminMenu, false)
