local function notify(message, type)
    lib.notify({ title = 'KVK Delfzijl', description = message, type = type or 'inform' })
end

local function typeOptions()
    local options = {}
    for value, label in pairs(Config.BusinessTypes) do
        options[#options + 1] = { value = value, label = label }
    end
    return options
end

local function rankOptions()
    local options = {}
    for value, rank in pairs(Config.Ranks) do
        options[#options + 1] = { value = value, label = rank.label }
    end
    return options
end

local function amountDialog(title)
    local input = lib.inputDialog(title, {
        { type = 'number', label = 'Bedrag', required = true, min = 1, max = 10000000 }
    })
    return input and tonumber(input[1]) or nil
end

local function createBusinessDialog()
    local input = lib.inputDialog('Bedrijf inschrijven', {
        { type = 'input', label = 'Bedrijfsnaam', required = true, min = 3, max = 128 },
        { type = 'select', label = 'Bedrijfstype', required = true, options = typeOptions() }
    })
    if input then
        TriggerServerEvent('delfzijlrp_business_v2:server:createBusiness', { name = input[1], business_type = input[2] })
    end
end

local function addEmployeeDialog(businessId)
    local input = lib.inputDialog('Werknemer toevoegen', {
        { type = 'number', label = 'Speler ID', required = true, min = 1 },
        { type = 'select', label = 'Rang', required = true, options = rankOptions() },
        { type = 'number', label = 'Salaris', default = 0, required = true, min = 0, max = 100000 }
    })
    if input then
        TriggerServerEvent('delfzijlrp_business_v2:server:addEmployee', businessId, input[1], input[2], input[3])
    end
end

local function invoiceDialog(businessId)
    local input = lib.inputDialog('Factuur maken', {
        { type = 'number', label = 'Speler ID klant', required = true, min = 1 },
        { type = 'number', label = 'Bedrag', required = true, min = 1, max = Config.Invoice.maxAmount },
        { type = 'input', label = 'Omschrijving', required = true, min = 3, max = 255 }
    })
    if input then
        TriggerServerEvent('delfzijlrp_business_v2:server:createInvoice', businessId, input[1], input[2], input[3])
    end
end

local function openBusiness(businessId)
    local data = lib.callback.await('delfzijlrp_business_v2:server:getBusiness', false, businessId)
    if not data then notify(Config.Text.noAccess, 'error') return end

    local business = data.business
    local options = {
        { title = business.name, description = ('%s | %s | Saldo €%s'):format(business.kvk_number, Config.BusinessTypes[business.business_type] or business.business_type, business.balance), icon = 'briefcase', readOnly = true },
        { title = 'Voorraad openen', icon = 'box-archive', onSelect = function() TriggerServerEvent('delfzijlrp_business_v2:server:openStorage', business.id) end },
        { title = 'Geld storten', icon = 'money-bill-transfer', onSelect = function()
            local amount = amountDialog('Geld storten')
            if amount then TriggerServerEvent('delfzijlrp_business_v2:server:deposit', business.id, amount) end
        end },
        { title = 'Geld opnemen', icon = 'money-bill-wave', onSelect = function()
            local amount = amountDialog('Geld opnemen')
            if amount then TriggerServerEvent('delfzijlrp_business_v2:server:withdraw', business.id, amount) end
        end },
        { title = 'Werknemer toevoegen', icon = 'user-plus', onSelect = function() addEmployeeDialog(business.id) end },
        { title = 'Factuur maken', icon = 'file-invoice-dollar', onSelect = function() invoiceDialog(business.id) end }
    }

    for _, employee in ipairs(data.employees or {}) do
        local name = employee.firstname and (employee.firstname .. ' ' .. employee.lastname) or employee.identifier
        options[#options + 1] = {
            title = name,
            description = ('%s | Salaris €%s'):format(Config.Ranks[employee.rank] and Config.Ranks[employee.rank].label or employee.rank, employee.salary),
            icon = 'user-tie',
            onSelect = function()
                lib.registerContext({
                    id = 'delfzijlrp_business_v2_employee',
                    title = name,
                    options = {
                        { title = 'Loon uitbetalen', icon = 'money-check-dollar', onSelect = function() TriggerServerEvent('delfzijlrp_business_v2:server:paySalary', business.id, employee.identifier) end },
                        { title = 'Werknemer verwijderen', icon = 'user-minus', onSelect = function() TriggerServerEvent('delfzijlrp_business_v2:server:removeEmployee', business.id, employee.identifier) end }
                    }
                })
                lib.showContext('delfzijlrp_business_v2_employee')
            end
        }
    end

    for _, invoice in ipairs(data.invoices or {}) do
        options[#options + 1] = {
            title = ('Factuur €%s | %s'):format(invoice.amount, invoice.status),
            description = (invoice.target_name or 'Onbekend') .. ' | ' .. invoice.description,
            icon = 'receipt',
            readOnly = true
        }
    end

    lib.registerContext({ id = 'delfzijlrp_business_v2_detail', title = business.name, options = options })
    lib.showContext('delfzijlrp_business_v2_detail')
end

local function openMyBusinesses()
    local rows = lib.callback.await('delfzijlrp_business_v2:server:getMyBusinesses', false) or {}
    if #rows == 0 then notify(Config.Text.noBusinesses, 'inform') return end

    local options = {}
    for _, business in ipairs(rows) do
        options[#options + 1] = {
            title = business.name,
            description = ('%s | %s'):format(business.kvk_number, Config.Ranks[business.rank] and Config.Ranks[business.rank].label or business.rank),
            icon = 'briefcase',
            onSelect = function() openBusiness(business.id) end
        }
    end
    lib.registerContext({ id = 'delfzijlrp_business_v2_my', title = 'Mijn bedrijven', options = options })
    lib.showContext('delfzijlrp_business_v2_my')
end

local function openKvk()
    lib.registerContext({
        id = 'delfzijlrp_business_v2_kvk',
        title = Config.KvkOffice.label,
        options = {
            { title = ('Bedrijf inschrijven €%s'):format(Config.CreatePrice), icon = 'building-circle-check', onSelect = createBusinessDialog },
            { title = 'Mijn bedrijven', icon = 'briefcase', onSelect = openMyBusinesses }
        }
    })
    lib.showContext('delfzijlrp_business_v2_kvk')
end

CreateThread(function()
    Wait(1500)

    if Config.KvkOffice.blip then
        local blip = AddBlipForCoord(Config.KvkOffice.coords.x, Config.KvkOffice.coords.y, Config.KvkOffice.coords.z)
        SetBlipSprite(blip, Config.KvkOffice.blip.sprite)
        SetBlipColour(blip, Config.KvkOffice.blip.color)
        SetBlipScale(blip, Config.KvkOffice.blip.scale)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(Config.KvkOffice.label)
        EndTextCommandSetBlipName(blip)
    end

    exports.ox_target:addSphereZone({
        coords = Config.KvkOffice.coords,
        radius = Config.KvkOffice.radius,
        debug = Config.Debug,
        options = {{ name = 'business_v2_kvk', icon = 'fa-solid fa-building-columns', label = Config.Text.openKvk, onSelect = openKvk }}
    })

    for _, point in ipairs(Config.Points) do
        exports.ox_target:addSphereZone({
            coords = point.coords,
            radius = point.radius,
            debug = Config.Debug,
            options = {{ name = 'business_v2_point_' .. point.id, icon = 'fa-solid fa-briefcase', label = point.label, onSelect = openMyBusinesses }}
        })
    end
end)

RegisterCommand(Config.Command, openMyBusinesses, false)
RegisterCommand(Config.OfficeCommand, openKvk, false)

RegisterNetEvent('delfzijlrp_business_v2:client:openStorage', function(stashId)
    exports.ox_inventory:openInventory('stash', stashId)
end)
