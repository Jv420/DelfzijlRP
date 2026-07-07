local ESX = exports['es_extended']:getSharedObject()

local function notify(src, text, kind)
    TriggerClientEvent('ox_lib:notify', src, { title = 'Business Manager', description = text, type = kind or 'inform' })
end

local function hasManagementAccess(src, businessId)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return false end
    local emp = exports['delfzijlrp_v3_jobs_core']:GetEmployee(xPlayer.identifier, businessId)
    return emp and Config.AllowedRoles[emp.role] == true
end

local function getBusiness(businessId)
    return exports['delfzijlrp_v3_business_core']:GetBusiness(businessId)
end

lib.callback.register('delfzijlrp_v3_business_manager:server:getMyBusinesses', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return {} end
    return MySQL.query.await([[SELECT e.business_id, e.role, b.label, b.type, b.balance, b.turnover
        FROM delfzijlrp_jobs_employees e
        LEFT JOIN delfzijlrp_businesses b ON b.id = e.business_id
        WHERE e.identifier = ? AND e.active = 1 AND e.role IN ('owner', 'manager')
        ORDER BY b.label ASC]], { xPlayer.identifier }) or {}
end)

lib.callback.register('delfzijlrp_v3_business_manager:server:getDashboard', function(source, businessId)
    businessId = tostring(businessId or ''):lower()
    if not hasManagementAccess(source, businessId) then notify(source, Config.Text.noAccess, 'error') return nil end

    local business = getBusiness(businessId)
    if not business then notify(source, Config.Text.noBusiness, 'error') return nil end

    local employees = MySQL.query.await('SELECT identifier, player_name, role, pay_per_minute, active FROM delfzijlrp_jobs_employees WHERE business_id = ? ORDER BY active DESC, role ASC, player_name ASC', { businessId }) or {}
    local shifts = MySQL.query.await('SELECT player_name, role, started_at, ended_at, minutes_worked, payout, status FROM delfzijlrp_jobs_shifts WHERE business_id = ? ORDER BY id DESC LIMIT 20', { businessId }) or {}
    local logs = MySQL.query.await('SELECT action, amount, details, created_by, created_at FROM delfzijlrp_business_logs WHERE business_id = ? ORDER BY id DESC LIMIT 20', { businessId }) or {}
    local stock = MySQL.query.await('SELECT item, label, amount, price FROM delfzijlrp_business_stock WHERE business_id = ? ORDER BY label ASC', { businessId }) or {}
    local orders = MySQL.query.await('SELECT id, restaurant_id, player_name, label, amount, price, status, courier_name, created_at FROM delfzijlrp_restaurant_orders WHERE restaurant_id = ? ORDER BY id DESC LIMIT 20', { businessId }) or {}
    local reviews = MySQL.query.await('SELECT player_name, rating, text, created_at FROM delfzijlrp_restaurant_reviews WHERE restaurant_id = ? ORDER BY id DESC LIMIT 10', { businessId }) or {}
    local today = MySQL.single.await("SELECT COALESCE(SUM(amount),0) AS total FROM delfzijlrp_business_logs WHERE business_id = ? AND action = 'sale' AND DATE(created_at) = CURDATE()", { businessId })
    local week = MySQL.single.await("SELECT COALESCE(SUM(amount),0) AS total FROM delfzijlrp_business_logs WHERE business_id = ? AND action = 'sale' AND YEARWEEK(created_at, 1) = YEARWEEK(CURDATE(), 1)", { businessId })
    local month = MySQL.single.await("SELECT COALESCE(SUM(amount),0) AS total FROM delfzijlrp_business_logs WHERE business_id = ? AND action = 'sale' AND YEAR(created_at) = YEAR(CURDATE()) AND MONTH(created_at) = MONTH(CURDATE())", { businessId })

    return {
        business = business,
        employees = employees,
        shifts = shifts,
        logs = logs,
        stock = stock,
        orders = orders,
        reviews = reviews,
        sales = {
            today = tonumber(today and today.total or 0) or 0,
            week = tonumber(week and week.total or 0) or 0,
            month = tonumber(month and month.total or 0) or 0
        }
    }
end)

RegisterNetEvent('delfzijlrp_v3_business_manager:server:setEmployeeRole', function(businessId, identifier, role, payPerMinute)
    local src = source
    businessId = tostring(businessId or ''):lower()
    if not hasManagementAccess(src, businessId) then notify(src, Config.Text.noAccess, 'error') return end
    role = tostring(role or 'employee')
    payPerMinute = tonumber(payPerMinute) or 35
    MySQL.update.await('UPDATE delfzijlrp_jobs_employees SET role = ?, pay_per_minute = ? WHERE business_id = ? AND identifier = ?', {
        role, payPerMinute, businessId, identifier
    })
    exports['delfzijlrp_v3_business_core']:AddLog(businessId, 'employee_update', payPerMinute, identifier .. ' -> ' .. role, GetPlayerName(src))
    notify(src, Config.Text.updated, 'success')
end)

RegisterNetEvent('delfzijlrp_v3_business_manager:server:setStockPrice', function(businessId, item, price)
    local src = source
    businessId = tostring(businessId or ''):lower()
    if not hasManagementAccess(src, businessId) then notify(src, Config.Text.noAccess, 'error') return end
    price = tonumber(price) or 0
    if tostring(item or '') == '' or price < 0 then notify(src, Config.Text.invalid, 'error') return end
    MySQL.update.await('UPDATE delfzijlrp_business_stock SET price = ? WHERE business_id = ? AND item = ?', { price, businessId, item })
    exports['delfzijlrp_v3_business_core']:AddLog(businessId, 'stock_price', price, item, GetPlayerName(src))
    notify(src, Config.Text.updated, 'success')
end)
