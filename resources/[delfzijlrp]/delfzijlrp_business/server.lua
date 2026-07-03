local ESX = exports['es_extended']:getSharedObject()

local function notify(source, message, type)
    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Delfzijl RP Business',
        description = message,
        type = type or 'inform'
    })
end

local function getPlayer(source)
    return ESX.GetPlayerFromId(source)
end

local function getIdentifier(source)
    local xPlayer = getPlayer(source)
    return xPlayer and xPlayer.identifier or nil
end

local function slugify(name)
    return (name or ''):lower():gsub('[^%w%s%-]', ''):gsub('%s+', '-'):sub(1, 96)
end

local function getEmployee(source, businessId)
    local identifier = getIdentifier(source)
    if not identifier then return nil end

    return MySQL.single.await('SELECT * FROM delfzijlrp_business_employees WHERE business_id = ? AND identifier = ? LIMIT 1', {
        businessId,
        identifier
    })
end

local function canManage(source, businessId)
    local employee = getEmployee(source, businessId)
    if not employee then return false end

    local rank = Config.Ranks[employee.rank]
    return rank and rank.level >= 70
end

local function canOwner(source, businessId)
    local employee = getEmployee(source, businessId)
    if not employee then return false end

    local rank = Config.Ranks[employee.rank]
    return rank and rank.level >= 100
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

lib.callback.register('delfzijlrp_business:server:getMyBusinesses', function(source)
    local identifier = getIdentifier(source)
    if not identifier then return {} end

    return MySQL.query.await([[SELECT b.*, e.rank, e.salary
        FROM delfzijlrp_businesses b
        JOIN delfzijlrp_business_employees e ON e.business_id = b.id
        WHERE e.identifier = ? AND b.active = 1
        ORDER BY b.name ASC]], { identifier }) or {}
end)

lib.callback.register('delfzijlrp_business:server:getBusiness', function(source, businessId)
    businessId = tonumber(businessId)
    if not businessId then return nil end

    local employee = getEmployee(source, businessId)
    if not employee then return nil end

    local business = MySQL.single.await('SELECT * FROM delfzijlrp_businesses WHERE id = ? LIMIT 1', { businessId })
    if not business then return nil end

    local employees = MySQL.query.await([[SELECT e.*, i.firstname, i.lastname, i.delfzijl_id
        FROM delfzijlrp_business_employees e
        LEFT JOIN delfzijlrp_identities i ON i.identifier = e.identifier
        WHERE e.business_id = ?
        ORDER BY e.rank ASC]], { businessId }) or {}

    return { business = business, employees = employees, rank = employee.rank }
end)

lib.callback.register('delfzijlrp_business:server:getInvoices', function(source)
    local identifier = getIdentifier(source)
    if not identifier then return {} end

    return MySQL.query.await([[SELECT inv.*, b.name as business_name
        FROM delfzijlrp_business_invoices inv
        JOIN delfzijlrp_businesses b ON b.id = inv.business_id
        WHERE inv.target_identifier = ? AND inv.paid = 0
        ORDER BY inv.created_at DESC]], { identifier }) or {}
end)

RegisterNetEvent('delfzijlrp_business:server:createBusiness', function(data)
    local source = source
    local identifier = getIdentifier(source)
    if not identifier or type(data) ~= 'table' then return end

    local name = data.name
    local businessType = data.business_type or 'other'
    if not name or #name < 3 or not Config.BusinessTypes[businessType] then
        notify(source, Config.Text.invalidInput, 'error')
        return
    end

    if not pay(source, Config.CreatePrice) then
        notify(source, Config.Text.noMoney, 'error')
        return
    end

    local slug = slugify(name)
    local exists = MySQL.scalar.await('SELECT id FROM delfzijlrp_businesses WHERE slug = ? LIMIT 1', { slug })
    if exists then
        slug = slug .. '-' .. tostring(math.random(100, 999))
    end

    local businessId = MySQL.insert.await('INSERT INTO delfzijlrp_businesses (name, slug, business_type, owner_identifier) VALUES (?, ?, ?, ?)', {
        name,
        slug,
        businessType,
        identifier
    })

    MySQL.insert.await('INSERT INTO delfzijlrp_business_employees (business_id, identifier, rank, salary) VALUES (?, ?, ?, ?)', {
        businessId,
        identifier,
        'owner',
        0
    })

    notify(source, Config.Text.created, 'success')
end)

RegisterNetEvent('delfzijlrp_business:server:addEmployee', function(businessId, targetId, rank, salary)
    local source = source
    businessId = tonumber(businessId)
    targetId = tonumber(targetId)
    salary = tonumber(salary) or 0

    if not businessId or not targetId or not canManage(source, businessId) then
        notify(source, Config.Text.noAccess, 'error')
        return
    end

    if not Config.Ranks[rank] then rank = 'employee' end

    local target = getPlayer(targetId)
    if not target then
        notify(source, Config.Text.notFound, 'error')
        return
    end

    MySQL.insert.await('INSERT IGNORE INTO delfzijlrp_business_employees (business_id, identifier, rank, salary) VALUES (?, ?, ?, ?)', {
        businessId,
        target.identifier,
        rank,
        salary
    })

    notify(source, Config.Text.employeeAdded, 'success')
    notify(targetId, Config.Text.employeeAdded, 'success')
end)

RegisterNetEvent('delfzijlrp_business:server:removeEmployee', function(businessId, identifier)
    local source = source
    businessId = tonumber(businessId)

    if not businessId or not canOwner(source, businessId) then
        notify(source, Config.Text.noAccess, 'error')
        return
    end

    MySQL.update.await('DELETE FROM delfzijlrp_business_employees WHERE business_id = ? AND identifier = ? AND rank != ?', {
        businessId,
        identifier,
        'owner'
    })

    notify(source, Config.Text.employeeRemoved, 'success')
end)

RegisterNetEvent('delfzijlrp_business:server:deposit', function(businessId, amount)
    local source = source
    businessId = tonumber(businessId)
    amount = tonumber(amount) or 0

    if amount <= 0 or not getEmployee(source, businessId) then return end
    if not pay(source, amount) then
        notify(source, Config.Text.noMoney, 'error')
        return
    end

    MySQL.update.await('UPDATE delfzijlrp_businesses SET balance = balance + ? WHERE id = ?', { amount, businessId })
    notify(source, Config.Text.deposited, 'success')
end)

RegisterNetEvent('delfzijlrp_business:server:withdraw', function(businessId, amount)
    local source = source
    local xPlayer = getPlayer(source)
    businessId = tonumber(businessId)
    amount = tonumber(amount) or 0

    if not xPlayer or amount <= 0 or not canManage(source, businessId) then
        notify(source, Config.Text.noAccess, 'error')
        return
    end

    local balance = MySQL.scalar.await('SELECT balance FROM delfzijlrp_businesses WHERE id = ? LIMIT 1', { businessId }) or 0
    if balance < amount then
        notify(source, Config.Text.noMoney, 'error')
        return
    end

    MySQL.update.await('UPDATE delfzijlrp_businesses SET balance = balance - ? WHERE id = ?', { amount, businessId })
    xPlayer.addAccountMoney('bank', amount)
    notify(source, Config.Text.withdrawn, 'success')
end)

RegisterNetEvent('delfzijlrp_business:server:createInvoice', function(businessId, targetId, reason, amount)
    local source = source
    local issuer = getPlayer(source)
    local target = getPlayer(tonumber(targetId))
    businessId = tonumber(businessId)
    amount = tonumber(amount) or 0

    if not issuer or not target or amount <= 0 or not getEmployee(source, businessId) then
        notify(source, Config.Text.invalidInput, 'error')
        return
    end

    local identity = MySQL.single.await('SELECT firstname, lastname FROM delfzijlrp_identities WHERE identifier = ? LIMIT 1', { target.identifier })
    local targetName = identity and (identity.firstname .. ' ' .. identity.lastname) or GetPlayerName(target.source)

    MySQL.insert.await([[INSERT INTO delfzijlrp_business_invoices
        (business_id, issuer_identifier, target_identifier, target_name, reason, amount)
        VALUES (?, ?, ?, ?, ?, ?)]], {
        businessId,
        issuer.identifier,
        target.identifier,
        targetName,
        reason,
        amount
    })

    notify(source, Config.Text.invoiceCreated, 'success')
    notify(target.source, 'Je hebt een nieuwe bedrijfsfactuur ontvangen.', 'inform')
end)

RegisterNetEvent('delfzijlrp_business:server:payInvoice', function(invoiceId)
    local source = source
    local xPlayer = getPlayer(source)
    local identifier = getIdentifier(source)
    invoiceId = tonumber(invoiceId)

    if not xPlayer or not identifier or not invoiceId then return end

    local invoice = MySQL.single.await('SELECT * FROM delfzijlrp_business_invoices WHERE id = ? AND target_identifier = ? AND paid = 0 LIMIT 1', {
        invoiceId,
        identifier
    })

    if not invoice then
        notify(source, Config.Text.notFound, 'error')
        return
    end

    if not pay(source, invoice.amount) then
        notify(source, Config.Text.noMoney, 'error')
        return
    end

    local fee = math.floor(invoice.amount * (Config.InvoiceFeePercent / 100))
    local payout = invoice.amount - fee

    MySQL.update.await('UPDATE delfzijlrp_business_invoices SET paid = 1, paid_at = NOW() WHERE id = ?', { invoiceId })
    MySQL.update.await('UPDATE delfzijlrp_businesses SET balance = balance + ? WHERE id = ?', { payout, invoice.business_id })

    notify(source, Config.Text.invoicePaid, 'success')
end)
