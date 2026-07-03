local function notify(message, type)
    lib.notify({ title = 'Delfzijl RP Business', description = message, type = type or 'inform' })
end

local function createBusinessDialog()
    local typeOptions = {}
    for value, label in pairs(Config.BusinessTypes) do
        typeOptions[#typeOptions + 1] = { value = value, label = label }
    end

    local input = lib.inputDialog('Bedrijf registreren', {
        { type = 'input', label = 'Bedrijfsnaam', required = true, min = 3, max = 96 },
        { type = 'select', label = 'Type bedrijf', required = true, options = typeOptions }
    })

    if not input then return end
    TriggerServerEvent('delfzijlrp_business:server:createBusiness', {
        name = input[1],
        business_type = input[2]
    })
end

local function amountDialog(title)
    local input = lib.inputDialog(title, {
        { type = 'number', label = 'Bedrag', required = true, min = 1, max = 10000000 }
    })
    return input and tonumber(input[1]) or nil
end

local function addEmployeeDialog(businessId)
    local rankOptions = {}
    for value, rank in pairs(Config.Ranks) do
        rankOptions[#rankOptions + 1] = { value = value, label = rank.label }
    end

    local input = lib.inputDialog('Medewerker toevoegen', {
        { type = 'number', label = 'Speler ID', required = true, min = 1 },
        { type = 'select', label = 'Rang', required = true, options = rankOptions },
        { type = 'number', label = 'Salaris', required = true, min = 0, max = 100000 }
    })

    if not input then return end
    TriggerServerEvent('delfzijlrp_business:server:addEmployee', businessId, input[1], input[2], input[3])
end

local function createInvoiceDialog(businessId)
    local input = lib.inputDialog('Factuur maken', {
        { type = 'number', label = 'Speler ID', required = true, min = 1 },
        { type = 'input', label = 'Omschrijving', required = true, min = 3, max = 255 },
        { type = 'number', label = 'Bedrag', required = true, min = 1, max = 1000000 }
    })

    if not input then return end
    TriggerServerEvent('delfzijlrp_business:server:createInvoice', businessId, input[1], input[2], input[3])
end

local function openBusiness(businessId)
    local data = lib.callback.await('delfzijlrp_business:server:getBusiness', false, businessId)
    if not data then
        notify(Config.Text.noAccess, 'error')
        return
    end

    local business = data.business
    local options = {
        { title = business.name, description = ('Type: %s | Saldo: €%s'):format(Config.BusinessTypes[business.business_type] or business.business_type, business.balance), icon = 'building', readOnly = true },
        { title = 'Geld storten', icon = 'money-bill-transfer', onSelect = function()
            local amount = amountDialog('Geld storten')
            if amount then TriggerServerEvent('delfzijlrp_business:server:deposit', business.id, amount) end
        end },
        { title = 'Geld opnemen', icon = 'money-bill-wave', onSelect = function()
            local amount = amountDialog('Geld opnemen')
            if amount then TriggerServerEvent('delfzijlrp_business:server:withdraw', business.id, amount) end
        end },
        { title = 'Factuur maken', icon = 'file-invoice-dollar', onSelect = function() createInvoiceDialog(business.id) end },
        { title = 'Medewerker toevoegen', icon = 'user-plus', onSelect = function() addEmployeeDialog(business.id) end }
    }

    for _, employee in ipairs(data.employees or {}) do
        local name = employee.firstname and (employee.firstname .. ' ' .. employee.lastname) or employee.identifier
        options[#options + 1] = {
            title = name,
            description = ('Rang: %s | Salaris: €%s'):format(Config.Ranks[employee.rank] and Config.Ranks[employee.rank].label or employee.rank, employee.salary),
            icon = 'user-tie',
            readOnly = true
        }
    end

    lib.registerContext({ id = 'delfzijlrp_business_detail', title = business.name, options = options })
    lib.showContext('delfzijlrp_business_detail')
end

local function openMyBusinesses()
    local businesses = lib.callback.await('delfzijlrp_business:server:getMyBusinesses', false) or {}
    if #businesses == 0 then
        notify('Je zit nog niet in een bedrijf.', 'error')
        return
    end

    local options = {}
    for _, business in ipairs(businesses) do
        options[#options + 1] = {
            title = business.name,
            description = ('%s | %s'):format(Config.BusinessTypes[business.business_type] or business.business_type, Config.Ranks[business.rank] and Config.Ranks[business.rank].label or business.rank),
            icon = 'building',
            onSelect = function() openBusiness(business.id) end
        }
    end

    lib.registerContext({ id = 'delfzijlrp_my_businesses', title = 'Mijn bedrijven', options = options })
    lib.showContext('delfzijlrp_my_businesses')
end

local function openInvoices()
    local invoices = lib.callback.await('delfzijlrp_business:server:getInvoices', false) or {}
    if #invoices == 0 then
        notify('Je hebt geen openstaande facturen.', 'inform')
        return
    end

    local options = {}
    for _, invoice in ipairs(invoices) do
        options[#options + 1] = {
            title = ('€%s | %s'):format(invoice.amount, invoice.business_name),
            description = invoice.reason,
            icon = 'file-invoice-dollar',
            onSelect = function()
                TriggerServerEvent('delfzijlrp_business:server:payInvoice', invoice.id)
            end
        }
    end

    lib.registerContext({ id = 'delfzijlrp_business_invoices', title = 'Openstaande facturen', options = options })
    lib.showContext('delfzijlrp_business_invoices')
end

local function openBusinessOffice()
    lib.registerContext({
        id = 'delfzijlrp_business_office',
        title = Config.BusinessOffice.label,
        options = {
            { title = ('Bedrijf registreren (€%s)'):format(Config.CreatePrice), icon = 'building-circle-check', onSelect = createBusinessDialog },
            { title = 'Mijn bedrijven', icon = 'briefcase', onSelect = openMyBusinesses },
            { title = 'Mijn facturen', icon = 'file-invoice-dollar', onSelect = openInvoices }
        }
    })

    lib.showContext('delfzijlrp_business_office')
end

CreateThread(function()
    Wait(1500)

    if Config.BusinessOffice.blip then
        local coords = Config.BusinessOffice.coords
        local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(blip, Config.BusinessOffice.blip.sprite)
        SetBlipColour(blip, Config.BusinessOffice.blip.color)
        SetBlipScale(blip, Config.BusinessOffice.blip.scale)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(Config.BusinessOffice.label)
        EndTextCommandSetBlipName(blip)
    end

    exports.ox_target:addSphereZone({
        coords = Config.BusinessOffice.coords,
        radius = Config.BusinessOffice.radius,
        debug = Config.Debug,
        options = {
            {
                name = 'delfzijlrp_business_office',
                icon = 'fa-solid fa-building',
                label = Config.Text.openOffice,
                distance = 2.0,
                onSelect = openBusinessOffice
            }
        }
    })
end)

RegisterCommand(Config.Command, openBusinessOffice, false)
