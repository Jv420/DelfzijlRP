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
        title = Config.City.name,
        description = message,
        type = type or 'inform'
    })
end

local function isGovernment(source)
    local xPlayer = getPlayer(source)
    return xPlayer and xPlayer.job and xPlayer.job.name == Config.CityJob
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

local function addTreasury(amount, actor, action, details)
    MySQL.update.await('UPDATE delfzijlrp_city_treasury SET balance = balance + ? WHERE id = 1', { amount })
    MySQL.insert.await('INSERT INTO delfzijlrp_city_logs (actor_identifier, action, amount, details) VALUES (?, ?, ?, ?)', {
        actor,
        action,
        amount,
        details
    })
end

local function chargeService(source, serviceId)
    local identifier = getIdentifier(source)
    local service = Config.Services[serviceId]
    if not identifier or not service then return false end
    if not pay(source, service.price) then
        notify(source, Config.Text.noMoney, 'error')
        return false
    end
    addTreasury(service.price, identifier, 'service_payment', serviceId)
    notify(source, Config.Text.paid, 'success')
    return true
end

lib.callback.register('delfzijlrp_city:server:getOverview', function(source)
    local identifier = getIdentifier(source)
    local identity = identifier and MySQL.single.await('SELECT * FROM delfzijlrp_identities WHERE identifier = ? LIMIT 1', { identifier }) or nil
    local permits = identifier and MySQL.query.await('SELECT * FROM delfzijlrp_city_permits WHERE identifier = ? ORDER BY created_at DESC LIMIT 10', { identifier }) or {}
    local reports = identifier and MySQL.query.await('SELECT * FROM delfzijlrp_city_reports WHERE identifier = ? ORDER BY created_at DESC LIMIT 10', { identifier }) or {}
    local taxes = identifier and MySQL.query.await('SELECT * FROM delfzijlrp_city_taxes WHERE identifier = ? ORDER BY created_at DESC LIMIT 15', { identifier }) or {}
    local treasury = MySQL.scalar.await('SELECT balance FROM delfzijlrp_city_treasury WHERE id = 1') or Config.City.startingBalance

    return {
        identity = identity,
        permits = permits or {},
        reports = reports or {},
        taxes = taxes or {},
        treasury = treasury,
        isGovernment = isGovernment(source)
    }
end)

lib.callback.register('delfzijlrp_city:server:getAdminData', function(source)
    if not isGovernment(source) then return nil end
    return {
        treasury = MySQL.scalar.await('SELECT balance FROM delfzijlrp_city_treasury WHERE id = 1') or 0,
        permits = MySQL.query.await('SELECT * FROM delfzijlrp_city_permits ORDER BY created_at DESC LIMIT 50') or {},
        reports = MySQL.query.await('SELECT * FROM delfzijlrp_city_reports ORDER BY created_at DESC LIMIT 50') or {},
        taxes = MySQL.query.await('SELECT * FROM delfzijlrp_city_taxes ORDER BY created_at DESC LIMIT 50') or {},
        logs = MySQL.query.await('SELECT * FROM delfzijlrp_city_logs ORDER BY created_at DESC LIMIT 30') or {}
    }
end)

RegisterNetEvent('delfzijlrp_city:server:payService', function(serviceId)
    chargeService(source, serviceId)
end)

RegisterNetEvent('delfzijlrp_city:server:createPermit', function(permitType, reason)
    local source = source
    local identifier = getIdentifier(source)
    if not identifier or not Config.PermitTypes[permitType] or not reason or #reason < 3 then
        notify(source, Config.Text.invalidInput, 'error')
        return
    end
    if not chargeService(source, 'permit_request') then return end

    MySQL.insert.await('INSERT INTO delfzijlrp_city_permits (identifier, person_name, permit_type, reason) VALUES (?, ?, ?, ?)', {
        identifier,
        getName(identifier, GetPlayerName(source)),
        permitType,
        reason
    })
    notify(source, Config.Text.permitCreated, 'success')
end)

RegisterNetEvent('delfzijlrp_city:server:updatePermit', function(permitId, status)
    local source = source
    if not isGovernment(source) then notify(source, Config.Text.noAccess, 'error') return end
    permitId = tonumber(permitId)
    if not permitId or not status then notify(source, Config.Text.invalidInput, 'error') return end

    MySQL.update.await('UPDATE delfzijlrp_city_permits SET status = ?, approved_by = ? WHERE id = ?', { status, getIdentifier(source), permitId })
    addTreasury(0, getIdentifier(source), 'permit_update', tostring(permitId) .. ':' .. status)
    notify(source, Config.Text.permitUpdated, 'success')
end)

RegisterNetEvent('delfzijlrp_city:server:createReport', function(reportType, description)
    local source = source
    local identifier = getIdentifier(source)
    if not identifier or not Config.PublicWorks[reportType] or not description or #description < 3 then
        notify(source, Config.Text.invalidInput, 'error')
        return
    end

    MySQL.insert.await('INSERT INTO delfzijlrp_city_reports (identifier, person_name, report_type, description) VALUES (?, ?, ?, ?)', {
        identifier,
        getName(identifier, GetPlayerName(source)),
        reportType,
        description
    })
    notify(source, Config.Text.reportCreated, 'success')
end)

RegisterNetEvent('delfzijlrp_city:server:updateReport', function(reportId, status)
    local source = source
    if not isGovernment(source) then notify(source, Config.Text.noAccess, 'error') return end
    reportId = tonumber(reportId)
    if not reportId or not status then notify(source, Config.Text.invalidInput, 'error') return end

    MySQL.update.await('UPDATE delfzijlrp_city_reports SET status = ? WHERE id = ?', { status, reportId })
    addTreasury(0, getIdentifier(source), 'report_update', tostring(reportId) .. ':' .. status)
    notify(source, 'Melding bijgewerkt.', 'success')
end)

RegisterNetEvent('delfzijlrp_city:server:createTax', function(targetId, taxType, amount, description)
    local source = source
    if not isGovernment(source) then notify(source, Config.Text.noAccess, 'error') return end
    local target = getPlayer(tonumber(targetId))
    amount = tonumber(amount) or 0

    if not target or not Config.TaxTypes[taxType] or amount <= 0 or not description or #description < 3 then
        notify(source, Config.Text.invalidInput, 'error')
        return
    end

    local dueAt = os.date('%Y-%m-%d %H:%M:%S', os.time() + (Config.Tax.defaultDueDays * 86400))
    MySQL.insert.await('INSERT INTO delfzijlrp_city_taxes (identifier, person_name, tax_type, amount, description, due_at) VALUES (?, ?, ?, ?, ?, ?)', {
        target.identifier,
        getName(target.identifier, GetPlayerName(target.source)),
        taxType,
        amount,
        description,
        dueAt
    })

    addTreasury(0, getIdentifier(source), 'tax_created', target.identifier .. ':' .. taxType .. ':' .. amount)
    notify(source, Config.Text.taxCreated, 'success')
    notify(target.source, ('Nieuwe gemeentelijke aanslag ontvangen: €%s'):format(amount), 'warning')
end)

RegisterNetEvent('delfzijlrp_city:server:payTax', function(taxId)
    local source = source
    local identifier = getIdentifier(source)
    taxId = tonumber(taxId)
    if not identifier or not taxId then return end

    local tax = MySQL.single.await('SELECT * FROM delfzijlrp_city_taxes WHERE id = ? AND identifier = ? AND status = ? LIMIT 1', { taxId, identifier, 'open' })
    if not tax then notify(source, Config.Text.noData, 'error') return end
    if not pay(source, tax.amount) then notify(source, Config.Text.noMoney, 'error') return end

    MySQL.update.await('UPDATE delfzijlrp_city_taxes SET status = ?, paid_at = NOW() WHERE id = ?', { 'paid', taxId })
    addTreasury(tax.amount, identifier, 'tax_paid', tax.tax_type .. ':' .. taxId)
    notify(source, Config.Text.taxPaid, 'success')
end)

RegisterNetEvent('delfzijlrp_city:server:cancelTax', function(taxId)
    local source = source
    if not isGovernment(source) then notify(source, Config.Text.noAccess, 'error') return end
    taxId = tonumber(taxId)
    if not taxId then return end

    MySQL.update.await('UPDATE delfzijlrp_city_taxes SET status = ? WHERE id = ? AND status = ?', { 'cancelled', taxId, 'open' })
    addTreasury(0, getIdentifier(source), 'tax_cancelled', tostring(taxId))
    notify(source, 'Belastingaanslag geannuleerd.', 'success')
end)

RegisterNetEvent('delfzijlrp_city:server:treasuryAdjust', function(amount, reason)
    local source = source
    if not isGovernment(source) then notify(source, Config.Text.noAccess, 'error') return end
    amount = tonumber(amount) or 0
    if amount == 0 or not reason or #reason < 3 then notify(source, Config.Text.invalidInput, 'error') return end

    addTreasury(amount, getIdentifier(source), 'treasury_adjust', reason)
    notify(source, Config.Text.treasuryUpdated, 'success')
end)
