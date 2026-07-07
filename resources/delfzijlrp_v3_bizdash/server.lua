local ESX = exports['es_extended']:getSharedObject()

local function canManage(identifier, businessId)
    local emp = exports['delfzijlrp_v3_jobs_core']:GetEmployee(identifier, businessId)
    if not emp then return false end
    return emp.role == 'owner' or emp.role == 'manager'
end

local function getDashboard(businessId)
    local business = exports['delfzijlrp_v3_business_core']:GetBusiness(businessId)
    if not business then return nil end

    local data = {
        business = business,
        employees = MySQL.query.await('SELECT player_name, role, pay_per_minute, active FROM delfzijlrp_jobs_employees WHERE business_id = ? ORDER BY role DESC, player_name ASC', { businessId }) or {},
        active_shifts = MySQL.query.await('SELECT player_name, role, started_at FROM delfzijlrp_jobs_shifts WHERE business_id = ? AND status = ? ORDER BY started_at DESC', { businessId, 'active' }) or {},
        recent_shifts = MySQL.query.await('SELECT player_name, role, minutes_worked, payout, ended_at FROM delfzijlrp_jobs_shifts WHERE business_id = ? AND status = ? ORDER BY id DESC LIMIT 10', { businessId, 'closed' }) or {},
        logs = MySQL.query.await('SELECT action, amount, details, created_by, created_at FROM delfzijlrp_business_logs WHERE business_id = ? ORDER BY id DESC LIMIT 15', { businessId }) or {}
    }

    if Config.RestaurantIds[businessId] then
        data.orders = MySQL.query.await('SELECT id, player_name, label, amount, price, status, courier_name, created_at FROM delfzijlrp_restaurant_orders WHERE restaurant_id = ? ORDER BY id DESC LIMIT 20', { businessId }) or {}
        data.stock = MySQL.query.await('SELECT ingredient, amount, minimum FROM delfzijlrp_restaurant_stock WHERE restaurant_id = ? ORDER BY ingredient ASC', { businessId }) or {}
        data.reviews = MySQL.query.await('SELECT player_name, rating, text, created_at FROM delfzijlrp_restaurant_reviews WHERE restaurant_id = ? ORDER BY id DESC LIMIT 10', { businessId }) or {}
        local rating = MySQL.single.await('SELECT AVG(rating) AS avg_rating, COUNT(*) AS total_reviews FROM delfzijlrp_restaurant_reviews WHERE restaurant_id = ?', { businessId })
        data.rating = rating or { avg_rating = 0, total_reviews = 0 }
    end

    return data
end

lib.callback.register('delfzijlrp_v3_bizdash:server:listMine', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return {} end
    return MySQL.query.await('SELECT business_id, role, pay_per_minute FROM delfzijlrp_jobs_employees WHERE identifier = ? AND active = 1 AND role IN (?, ?) ORDER BY business_id ASC', {
        xPlayer.identifier, 'owner', 'manager'
    }) or {}
end)

lib.callback.register('delfzijlrp_v3_bizdash:server:get', function(source, businessId)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return nil end
    businessId = tostring(businessId or ''):lower()
    if not canManage(xPlayer.identifier, businessId) then
        TriggerClientEvent('ox_lib:notify', source, { title = 'BizDash', description = Config.Text.noAccess, type = 'error' })
        return nil
    end
    return getDashboard(businessId)
end)
