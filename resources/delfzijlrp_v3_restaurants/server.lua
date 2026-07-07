local ESX = exports['es_extended']:getSharedObject()

local function notify(src, text, kind)
    TriggerClientEvent('ox_lib:notify', src, { title = 'Restaurants', description = text, type = kind or 'inform' })
end

local function businessId(restId)
    local rest = Config.Restaurants[restId]
    return rest and (rest.business or restId) or restId
end

local function hasJobAccess(src, restId, allowedRoles)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return false end
    if GetResourceState('delfzijlrp_v3_jobs_core') ~= 'started' then return true end
    local emp = exports['delfzijlrp_v3_jobs_core']:GetEmployee(xPlayer.identifier, businessId(restId))
    if not emp then return false end
    if not allowedRoles then return true end
    return allowedRoles[emp.role] == true
end

CreateThread(function()
    MySQL.query.await([[CREATE TABLE IF NOT EXISTS delfzijlrp_restaurant_orders (
        id int NOT NULL AUTO_INCREMENT,
        restaurant_id varchar(64) NOT NULL,
        identifier varchar(64) NOT NULL,
        player_name varchar(128) NOT NULL,
        item varchar(64) NOT NULL,
        label varchar(128) NOT NULL,
        amount int NOT NULL DEFAULT 1,
        price int NOT NULL DEFAULT 0,
        status varchar(32) NOT NULL DEFAULT 'paid',
        courier_identifier varchar(64) DEFAULT NULL,
        courier_name varchar(128) DEFAULT NULL,
        delivery_fee int NOT NULL DEFAULT 0,
        created_at timestamp NOT NULL DEFAULT current_timestamp(),
        updated_at timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
        PRIMARY KEY(id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]])
    MySQL.query.await([[ALTER TABLE delfzijlrp_restaurant_orders ADD COLUMN IF NOT EXISTS courier_identifier varchar(64) DEFAULT NULL;]])
    MySQL.query.await([[ALTER TABLE delfzijlrp_restaurant_orders ADD COLUMN IF NOT EXISTS courier_name varchar(128) DEFAULT NULL;]])
    MySQL.query.await([[ALTER TABLE delfzijlrp_restaurant_orders ADD COLUMN IF NOT EXISTS delivery_fee int NOT NULL DEFAULT 0;]])
    MySQL.query.await([[ALTER TABLE delfzijlrp_restaurant_orders ADD COLUMN IF NOT EXISTS updated_at timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp();]])

    MySQL.query.await([[CREATE TABLE IF NOT EXISTS delfzijlrp_restaurant_reviews (
        id int NOT NULL AUTO_INCREMENT,
        restaurant_id varchar(64) NOT NULL,
        identifier varchar(64) NOT NULL,
        player_name varchar(128) NOT NULL,
        rating int NOT NULL DEFAULT 5,
        text text NULL,
        created_at timestamp NOT NULL DEFAULT current_timestamp(),
        PRIMARY KEY(id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]])

    MySQL.query.await([[CREATE TABLE IF NOT EXISTS delfzijlrp_restaurant_stock (
        id int NOT NULL AUTO_INCREMENT,
        restaurant_id varchar(64) NOT NULL,
        ingredient varchar(64) NOT NULL,
        amount int NOT NULL DEFAULT 0,
        minimum int NOT NULL DEFAULT 10,
        PRIMARY KEY(id),
        UNIQUE KEY rest_ing (restaurant_id, ingredient)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]])

    for id, r in pairs(Config.Restaurants) do
        MySQL.insert.await('INSERT IGNORE INTO delfzijlrp_businesses (id, label, type, balance, tax_rate) VALUES (?, ?, ?, ?, ?)', { r.business or id, r.label, 'horeca', 0, 21 })
        for _, p in ipairs(r.menu or {}) do
            MySQL.insert.await('INSERT IGNORE INTO delfzijlrp_business_stock (business_id, item, label, amount, price) VALUES (?, ?, ?, ?, ?)', { r.business or id, p.item, p.label, 999, p.price })
        end
        for _, recipe in pairs(Config.Recipes or {}) do
            for ingredient, _ in pairs(recipe) do
                MySQL.insert.await('INSERT IGNORE INTO delfzijlrp_restaurant_stock (restaurant_id, ingredient, amount, minimum) VALUES (?, ?, ?, ?)', { id, ingredient, Config.DefaultIngredientStock or 250, 10 })
            end
        end
    end
end)

local function getProduct(rest, item)
    for _, p in ipairs(rest.menu or {}) do if p.item == item then return p end end
    return nil
end

local function hasStock(restId, item, count)
    local recipe = (Config.Recipes or {})[item] or {}
    for ingredient, need in pairs(recipe) do
        local row = MySQL.single.await('SELECT amount FROM delfzijlrp_restaurant_stock WHERE restaurant_id = ? AND ingredient = ? LIMIT 1', { restId, ingredient })
        if not row or tonumber(row.amount or 0) < (tonumber(need) or 0) * count then return false, ingredient end
    end
    return true
end

local function useStock(restId, item, count)
    local recipe = (Config.Recipes or {})[item] or {}
    for ingredient, need in pairs(recipe) do
        MySQL.update.await('UPDATE delfzijlrp_restaurant_stock SET amount = GREATEST(amount - ?, 0) WHERE restaurant_id = ? AND ingredient = ?', { (tonumber(need) or 0) * count, restId, ingredient })
    end
end

RegisterNetEvent('delfzijlrp_v3_restaurants:server:buy', function(restId, item, count)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    local rest = Config.Restaurants[restId]
    if not rest then notify(src, Config.Text.invalid, 'error') return end
    local product = getProduct(rest, item)
    count = tonumber(count) or 1
    if not product or count < 1 then notify(src, Config.Text.invalid, 'error') return end
    local enough, missing = hasStock(restId, product.item, count)
    if not enough then notify(src, Config.Text.noStock .. ' (' .. tostring(missing) .. ')', 'error') return end

    local total = product.price * count
    if xPlayer.getMoney() < total then notify(src, Config.Text.noMoney, 'error') return end
    if not exports.ox_inventory:Items(product.item) then notify(src, Config.Text.missingItem .. ' (' .. product.item .. ')', 'error') return end

    xPlayer.removeMoney(total)
    local ok, reason = exports.ox_inventory:AddItem(src, product.item, count)
    if not ok then xPlayer.addMoney(total) notify(src, reason or Config.Text.invalid, 'error') return end

    useStock(restId, product.item, count)
    local bid = businessId(restId)
    MySQL.update.await('UPDATE delfzijlrp_businesses SET balance = balance + ?, turnover = turnover + ? WHERE id = ?', { total, total, bid })
    MySQL.update.await('UPDATE delfzijlrp_business_stock SET amount = GREATEST(amount - ?, 0) WHERE business_id = ? AND item = ?', { count, bid, product.item })
    local orderId = MySQL.insert.await('INSERT INTO delfzijlrp_restaurant_orders (restaurant_id, identifier, player_name, item, label, amount, price, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', { restId, xPlayer.identifier, GetPlayerName(src), product.item, product.label, count, total, 'paid' })
    exports['delfzijlrp_v3_business_core']:AddLog(bid, 'sale', total, product.label .. ' x' .. count .. ' order #' .. tostring(orderId), GetPlayerName(src))
    notify(src, Config.Text.bought .. ' Order #' .. tostring(orderId), 'success')
end)

RegisterNetEvent('delfzijlrp_v3_restaurants:server:review', function(restId, rating, text)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    if not Config.Restaurants[restId] then notify(src, Config.Text.invalid, 'error') return end
    rating = math.max(1, math.min(5, tonumber(rating) or 5))
    MySQL.insert.await('INSERT INTO delfzijlrp_restaurant_reviews (restaurant_id, identifier, player_name, rating, text) VALUES (?, ?, ?, ?, ?)', { restId, xPlayer.identifier, GetPlayerName(src), rating, tostring(text or '') })
    notify(src, 'Review opgeslagen.', 'success')
end)

lib.callback.register('delfzijlrp_v3_restaurants:server:getReviews', function(source, restId)
    return MySQL.query.await('SELECT player_name, rating, text, created_at FROM delfzijlrp_restaurant_reviews WHERE restaurant_id = ? ORDER BY id DESC LIMIT 10', { restId }) or {}
end)

lib.callback.register('delfzijlrp_v3_restaurants:server:getOrders', function(source, restId)
    if restId and restId ~= '' and not hasJobAccess(source, restId) then notify(source, Config.Text.noAccess or 'Geen toegang.', 'error') return {} end
    if restId and restId ~= '' then return MySQL.query.await('SELECT * FROM delfzijlrp_restaurant_orders WHERE restaurant_id = ? AND status IN (?, ?) ORDER BY id ASC LIMIT 50', { restId, 'paid', 'preparing' }) or {} end
    return MySQL.query.await('SELECT * FROM delfzijlrp_restaurant_orders WHERE status IN (?, ?) ORDER BY id ASC LIMIT 50', { 'paid', 'preparing' }) or {}
end)

lib.callback.register('delfzijlrp_v3_restaurants:server:getDeliveries', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if GetResourceState('delfzijlrp_v3_jobs_core') == 'started' and xPlayer then
        local allowed = false
        for id, _ in pairs(Config.Restaurants) do
            local emp = exports['delfzijlrp_v3_jobs_core']:GetEmployee(xPlayer.identifier, businessId(id))
            if emp and (emp.role == 'courier' or emp.role == 'manager' or emp.role == 'owner') then allowed = true break end
        end
        if not allowed then notify(source, Config.Text.noAccess or 'Geen toegang.', 'error') return {} end
    end
    return MySQL.query.await('SELECT * FROM delfzijlrp_restaurant_orders WHERE status IN (?, ?) ORDER BY id ASC LIMIT 50', { 'ready', 'picked_up' }) or {}
end)

lib.callback.register('delfzijlrp_v3_restaurants:server:getStock', function(source, restId)
    if not hasJobAccess(source, restId, { owner = true, manager = true, chef = true }) then notify(source, Config.Text.noAccess or 'Geen toegang.', 'error') return {} end
    return MySQL.query.await('SELECT ingredient, amount, minimum FROM delfzijlrp_restaurant_stock WHERE restaurant_id = ? ORDER BY ingredient ASC', { restId }) or {}
end)

RegisterNetEvent('delfzijlrp_v3_restaurants:server:addStock', function(restId, ingredient, amount)
    local src = source
    amount = tonumber(amount) or 0
    if not hasJobAccess(src, restId, { owner = true, manager = true, chef = true }) then notify(src, Config.Text.noAccess or 'Geen toegang.', 'error') return end
    if not Config.Restaurants[restId] or tostring(ingredient or '') == '' or amount < 1 then notify(src, Config.Text.invalid, 'error') return end
    MySQL.insert.await('INSERT INTO delfzijlrp_restaurant_stock (restaurant_id, ingredient, amount, minimum) VALUES (?, ?, ?, ?) ON DUPLICATE KEY UPDATE amount = amount + VALUES(amount)', { restId, ingredient, amount, 10 })
    exports['delfzijlrp_v3_business_core']:AddLog(businessId(restId), 'stock_add', amount, ingredient, GetPlayerName(src))
    notify(src, Config.Text.stockAdded, 'success')
end)

RegisterNetEvent('delfzijlrp_v3_restaurants:server:setOrderStatus', function(orderId, status)
    local src = source
    orderId = tonumber(orderId); status = tostring(status or '')
    local allowed = { preparing = true, ready = true, delivered = true }
    if not orderId or not allowed[status] then notify(src, Config.Text.invalid, 'error') return end
    local row = MySQL.single.await('SELECT * FROM delfzijlrp_restaurant_orders WHERE id = ? LIMIT 1', { orderId })
    if not row then notify(src, Config.Text.invalid, 'error') return end
    if not hasJobAccess(src, row.restaurant_id, { owner = true, manager = true, chef = true, cook = true, cashier = true }) then notify(src, Config.Text.noAccess or 'Geen toegang.', 'error') return end
    MySQL.update.await('UPDATE delfzijlrp_restaurant_orders SET status = ? WHERE id = ?', { status, orderId })
    exports['delfzijlrp_v3_business_core']:AddLog(businessId(row.restaurant_id), 'order_' .. status, row.price or 0, row.label .. ' #' .. orderId, GetPlayerName(src))
    notify(src, 'Order bijgewerkt.', 'success')
end)

RegisterNetEvent('delfzijlrp_v3_restaurants:server:claimDelivery', function(orderId)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    orderId = tonumber(orderId)
    local row = MySQL.single.await('SELECT * FROM delfzijlrp_restaurant_orders WHERE id = ? LIMIT 1', { orderId })
    if not row or row.status ~= 'ready' then notify(src, Config.Text.invalid, 'error') return end
    if not hasJobAccess(src, row.restaurant_id, { owner = true, manager = true, courier = true }) then notify(src, Config.Text.noAccess or 'Geen toegang.', 'error') return end
    MySQL.update.await('UPDATE delfzijlrp_restaurant_orders SET status = ?, courier_identifier = ?, courier_name = ?, delivery_fee = ? WHERE id = ?', { 'picked_up', xPlayer.identifier, GetPlayerName(src), Config.DeliveryFee or 25, orderId })
    exports['delfzijlrp_v3_business_core']:AddLog(businessId(row.restaurant_id), 'delivery_claim', Config.DeliveryFee or 25, row.label .. ' #' .. orderId, GetPlayerName(src))
    notify(src, Config.Text.accepted, 'success')
end)

RegisterNetEvent('delfzijlrp_v3_restaurants:server:finishDelivery', function(orderId)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    orderId = tonumber(orderId)
    local row = MySQL.single.await('SELECT * FROM delfzijlrp_restaurant_orders WHERE id = ? LIMIT 1', { orderId })
    if not row or row.status ~= 'picked_up' or row.courier_identifier ~= xPlayer.identifier then notify(src, Config.Text.invalid, 'error') return end
    local fee = tonumber(row.delivery_fee or Config.DeliveryFee or 25)
    xPlayer.addMoney(fee)
    MySQL.update.await('UPDATE delfzijlrp_restaurant_orders SET status = ? WHERE id = ?', { 'delivered', orderId })
    exports['delfzijlrp_v3_business_core']:AddLog(businessId(row.restaurant_id), 'delivery_done', fee, row.label .. ' #' .. orderId, GetPlayerName(src))
    notify(src, Config.Text.completed .. ' +€' .. fee, 'success')
end)
