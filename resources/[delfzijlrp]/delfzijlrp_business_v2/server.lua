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
        title = 'KVK Delfzijl',
        description = message,
        type = type or 'inform'
    })
end

local function pay(source, amount)
    local xPlayer = getPlayer(source)
    if not xPlayer then return false end
    if xPlayer.getMoney() >= amount then xPlayer.removeMoney(amount) return true end
    if xPlayer.getAccount('bank').money >= amount then xPlayer.removeAccountMoney('bank', amount) return true end
    return false
end

local function createKvkNumber()
    local number
    repeat
        number = 'KVK' .. os.date('%y') .. tostring(math.random(100000, 999999))
    until not MySQL.scalar.await('SELECT id FROM delfzijlrp_businesses WHERE kvk_number = ? LIMIT 1', { number })
    return number
end

local function rankLevel(rank)
    return Config.Ranks[rank] and Config.Ranks[rank].level or 0
end

local function getEmployee(source, businessId)
    local identifier = getIdentifier(source)
    if not identifier then return nil end
    return MySQL.single.await('SELECT * FROM delfzijlrp_business_employees WHERE business_id = ? AND identifier = ? LIMIT 1', { businessId, identifier })
end

local function canManage(source, businessId)
    local employee = getEmployee(source, businessId)
    return employee and rankLevel(employee.rank) >= 60
end

local function canDirect(source, businessId)
    local employee = getEmployee(source, businessId)
    return employee and rankLevel(employee.rank) >= 80
end

local function logBusiness(businessId, source, action, details)
    MySQL.insert.await('INSERT INTO delfzijlrp_business_logs (business_id, actor_identifier, action, details) VALUES (?, ?, ?, ?)', {
        businessId,
        getIdentifier(source),
        action,
        details
    })
end

local function identityName(identifier, fallback)
    local row = MySQL.single.await('SELECT firstname, lastname FROM delfzijlrp_identities WHERE identifier = ? LIMIT 1', { identifier })
    if row then return row.firstname .. ' ' .. row.lastname end
    return fallback
end

lib.callback.register('delfzijlrp_business_v2:server:getMyBusinesses', function(source)
    local identifier = getIdentifier(source)
    if not identifier then return {} end

    return MySQL.query.await([[SELECT b.*, e.rank, e.salary
        FROM delfzijlrp_businesses b
        JOIN delfzijlrp_business_employees e ON e.business_id = b.id
        WHERE e.identifier = ? AND b.active = 1
        ORDER BY b.name ASC]], { identifier }) or {}
end)

lib.callback.register('delfzijlrp_business_v2:server:getBusiness', function(source, businessId)
    businessId = tonumber(businessId)
    if not businessId then return nil end
    local employee = getEmployee(source, businessId)
    if not employee then return nil end

    local business = MySQL.single.await('SELECT * FROM delfzijlrp_businesses WHERE id = ? LIMIT 1', { businessId })
    local employees = MySQL.query.await([[SELECT e.*, i.firstname, i.lastname, i.delfzijl_id
        FROM delfzijlrp_business_employees e
        LEFT JOIN delfzijlrp_identities i ON i.identifier = e.identifier
        WHERE e.business_id = ? ORDER BY e.rank ASC]], { businessId }) or {}
    local invoices = MySQL.query.await('SELECT * FROM delfzijlrp_business_invoices WHERE business_id = ? ORDER BY created_at DESC LIMIT 20', { businessId }) or {}

    return { business = business, employees = employees, invoices = invoices, rank = employee.rank, salary = employee.salary }
end)

RegisterNetEvent('delfzijlrp_business_v2:server:createBusiness', function(data)
    local source = source
    local identifier = getIdentifier(source)
    if not identifier or type(data) ~= 'table' then return end

    local name = tostring(data.name or '')
    local businessType = data.business_type or 'other'
    if #name < 3 or not Config.BusinessTypes[businessType] then
        notify(source, Config.Text.invalidInput, 'error')
        return
    end

    if not pay(source, Config.CreatePrice) then
        notify(source, Config.Text.noMoney, 'error')
        return
    end

    local businessId = MySQL.insert.await('INSERT INTO delfzijlrp_businesses (kvk_number, name, business_type, owner_identifier) VALUES (?, ?, ?, ?)', {
        createKvkNumber(),
        name,
        businessType,
        identifier
    })

    MySQL.insert.await('INSERT INTO delfzijlrp_business_employees (business_id, identifier, rank, salary) VALUES (?, ?, ?, ?)', {
        businessId,
        identifier,
        'owner',
        0
    })

    logBusiness(businessId, source, 'create_business', name)
    notify(source, Config.Text.created, 'success')
end)

RegisterNetEvent('delfzijlrp_business_v2:server:addEmployee', function(businessId, targetId, rank, salary)
    local source = source
    businessId = tonumber(businessId)
    targetId = tonumber(targetId)
    salary = tonumber(salary) or 0

    if not businessId or not targetId or not canManage(source, businessId) then
        notify(source, Config.Text.notManager, 'error')
        return
    end

    local target = getPlayer(targetId)
    if not target then notify(source, Config.Text.playerNotFound, 'error') return end
    if not Config.Ranks[rank] then rank = 'employee' end

    MySQL.insert.await([[INSERT INTO delfzijlrp_business_employees (business_id, identifier, rank, salary)
        VALUES (?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE rank = VALUES(rank), salary = VALUES(salary)]], { businessId, target.identifier, rank, salary })
    logBusiness(businessId, source, 'add_employee', target.identifier .. ':' .. rank .. ':' .. salary)
    notify(source, Config.Text.employeeAdded, 'success')
    notify(target.source, 'Je bent toegevoegd aan een bedrijf.', 'success')
end)

RegisterNetEvent('delfzijlrp_business_v2:server:removeEmployee', function(businessId, targetIdentifier)
    local source = source
    businessId = tonumber(businessId)
    if not businessId or not canDirect(source, businessId) then
        notify(source, Config.Text.notManager, 'error')
        return
    end

    MySQL.update.await('DELETE FROM delfzijlrp_business_employees WHERE business_id = ? AND identifier = ? AND rank != ?', { businessId, targetIdentifier, 'owner' })
    logBusiness(businessId, source, 'remove_employee', targetIdentifier)
    notify(source, Config.Text.employeeRemoved, 'success')
end)

RegisterNetEvent('delfzijlrp_business_v2:server:deposit', function(businessId, amount)
    local source = source
    businessId = tonumber(businessId)
    amount = tonumber(amount) or 0
    if amount <= 0 or not getEmployee(source, businessId) then return end

    if not pay(source, amount) then notify(source, Config.Text.noMoney, 'error') return end
    MySQL.update.await('UPDATE delfzijlrp_businesses SET balance = balance + ? WHERE id = ?', { amount, businessId })
    logBusiness(businessId, source, 'deposit', tostring(amount))
    notify(source, Config.Text.deposited, 'success')
end)

RegisterNetEvent('delfzijlrp_business_v2:server:withdraw', function(businessId, amount)
    local source = source
    local xPlayer = getPlayer(source)
    businessId = tonumber(businessId)
    amount = tonumber(amount) or 0
    if not xPlayer or amount <= 0 or not canManage(source, businessId) then
        notify(source, Config.Text.notManager, 'error')
        return
    end

    local balance = MySQL.scalar.await('SELECT balance FROM delfzijlrp_businesses WHERE id = ? LIMIT 1', { businessId }) or 0
    if balance < amount then notify(source, Config.Text.noMoney, 'error') return end

    MySQL.update.await('UPDATE delfzijlrp_businesses SET balance = balance - ? WHERE id = ?', { amount, businessId })
    xPlayer.addAccountMoney('bank', amount)
    logBusiness(businessId, source, 'withdraw', tostring(amount))
    notify(source, Config.Text.withdrawn, 'success')
end)

RegisterNetEvent('delfzijlrp_business_v2:server:createInvoice', function(businessId, targetId, amount, description)
    local source = source
    businessId = tonumber(businessId)
    targetId = tonumber(targetId)
    amount = tonumber(amount) or 0
    if not businessId or not targetId or amount <= 0 or amount > Config.Invoice.maxAmount or not canManage(source, businessId) then
        notify(source, Config.Text.invalidInput, 'error')
        return
    end

    local target = getPlayer(targetId)
    if not target then notify(source, Config.Text.playerNotFound, 'error') return end
    local dueAt = os.date('%Y-%m-%d %H:%M:%S', os.time() + (Config.Invoice.defaultDueDays * 86400))
    MySQL.insert.await([[INSERT INTO delfzijlrp_business_invoices (business_id, target_identifier, target_name, amount, description, due_at)
        VALUES (?, ?, ?, ?, ?, ?)]], {
        businessId,
        target.identifier,
        identityName(target.identifier, GetPlayerName(target.source)),
        amount,
        description or 'Factuur',
        dueAt
    })
    logBusiness(businessId, source, 'create_invoice', target.identifier .. ':' .. amount)
    notify(source, Config.Text.invoiceCreated, 'success')
    notify(target.source, ('Je hebt een bedrijfsfactuur ontvangen: €%s'):format(amount), 'inform')
end)

RegisterNetEvent('delfzijlrp_business_v2:server:paySalary', function(businessId, targetIdentifier)
    local source = source
    businessId = tonumber(businessId)
    if not businessId or not canManage(source, businessId) then notify(source, Config.Text.notManager, 'error') return end

    local employee = MySQL.single.await('SELECT * FROM delfzijlrp_business_employees WHERE business_id = ? AND identifier = ? LIMIT 1', { businessId, targetIdentifier })
    if not employee or employee.salary <= 0 then notify(source, Config.Text.invalidInput, 'error') return end

    local balance = MySQL.scalar.await('SELECT balance FROM delfzijlrp_businesses WHERE id = ? LIMIT 1', { businessId }) or 0
    if balance < employee.salary then notify(source, Config.Text.noMoney, 'error') return end

    MySQL.update.await('UPDATE delfzijlrp_businesses SET balance = balance - ? WHERE id = ?', { employee.salary, businessId })
    for _, xPlayer in pairs(ESX.GetExtendedPlayers()) do
        if xPlayer.identifier == targetIdentifier then
            xPlayer.addAccountMoney('bank', employee.salary)
            notify(xPlayer.source, ('Loon ontvangen: €%s'):format(employee.salary), 'success')
            break
        end
    end
    logBusiness(businessId, source, 'pay_salary', targetIdentifier .. ':' .. employee.salary)
    notify(source, Config.Text.paidSalary, 'success')
end)

RegisterNetEvent('delfzijlrp_business_v2:server:openStorage', function(businessId)
    local source = source
    businessId = tonumber(businessId)
    if not businessId or not getEmployee(source, businessId) then notify(source, Config.Text.noAccess, 'error') return end

    local business = MySQL.single.await('SELECT * FROM delfzijlrp_businesses WHERE id = ? LIMIT 1', { businessId })
    if not business then return end
    local stashId = ('business_v2_%s'):format(businessId)
    exports.ox_inventory:RegisterStash(stashId, business.name .. ' Voorraad', Config.Stash.slots, Config.Stash.weight)
    TriggerClientEvent('delfzijlrp_business_v2:client:openStorage', source, stashId)
end)
