local ESX = exports['es_extended']:getSharedObject()

local function notify(src, text, kind)
    TriggerClientEvent('ox_lib:notify', src, { title = 'Restaurants', description = text, type = kind or 'inform' })
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
        created_at timestamp NOT NULL DEFAULT current_timestamp(),
        updated_at timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
        PRIMARY KEY(id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]])

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

    for id, r in pairs(Config.Restaurants) do
        MySQL.insert.await('INSERT IGNORE INTO delfzijlrp_businesses (id, label, type, balance, tax_rate) VALUES (?, ?, ?, ?, ?)', {
            r.business or id, r.label, 'horeca', 0, 21
        })
        for _, p in ipairs(r.menu or {}) do
            MySQL.insert.await('INSERT IGNORE INTO delfzijlrp_business_stock (business_id, item, label, amount, price) VALUES (?, ?, ?, ?, ?)', {
                r.business or id, p.item, p.label, 999, p.price
            })
        end
    end
end)

local function getProduct(rest, item)
    for _, p in ipairs(rest.menu or {}) do
        if p.item == item then return p end
    end
    return nil
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

    local total = product.price * count
    if xPlayer.getMoney() < total then notify(src, Config.Text.noMoney, 'error') return end
    if not exports.ox_inventory:Items(product.item) then notify(src, Config.Text.missingItem .. ' (' .. product.item .. ')', 'error') return end

    xPlayer.removeMoney(total)
    local ok, reason = exports.ox_inventory:AddItem(src, product.item, count)
    if not ok then
        xPlayer.addMoney(total)
        notify(src, reason or Config.Text.invalid, 'error')
        return
    end

    local businessId = rest.business or restId
    MySQL.update.await('UPDATE delfzijlrp_businesses SET balance = balance + ?, turnover = turnover + ? WHERE id = ?', { total, total, businessId })
    MySQL.update.await('UPDATE delfzijlrp_business_stock SET amount = GREATEST(amount - ?, 0) WHERE business_id = ? AND item = ?', { count, businessId, product.item })
    local orderId = MySQL.insert.await('INSERT INTO delfzijlrp_restaurant_orders (restaurant_id, identifier, player_name, item, label, amount, price, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
        restId, xPlayer.identifier, GetPlayerName(src), product.item, product.label, count, total, 'paid'
    })
    exports['delfzijlrp_v3_business_core']:AddLog(businessId, 'sale', total, product.label .. ' x' .. count .. ' order #' .. tostring(orderId), GetPlayerName(src))
    notify(src, Config.Text.bought .. ' Order #' .. tostring(orderId), 'success')
end)

RegisterNetEvent('delfzijlrp_v3_restaurants:server:review', function(restId, rating, text)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    if not Config.Restaurants[restId] then notify(src, Config.Text.invalid, 'error') return end
    rating = math.max(1, math.min(5, tonumber(rating) or 5))
    MySQL.insert.await('INSERT INTO delfzijlrp_restaurant_reviews (restaurant_id, identifier, player_name, rating, text) VALUES (?, ?, ?, ?, ?)', {
        restId, xPlayer.identifier, GetPlayerName(src), rating, tostring(text or '')
    })
    notify(src, 'Review opgeslagen.', 'success')
end)

lib.callback.register('delfzijlrp_v3_restaurants:server:getReviews', function(source, restId)
    return MySQL.query.await('SELECT player_name, rating, text, created_at FROM delfzijlrp_restaurant_reviews WHERE restaurant_id = ? ORDER BY id DESC LIMIT 10', { restId }) or {}
end)

lib.callback.register('delfzijlrp_v3_restaurants:server:getOrders', function(source, restId)
    if restId and restId ~= '' then
        return MySQL.query.await('SELECT * FROM delfzijlrp_restaurant_orders WHERE restaurant_id = ? AND status IN (?, ?) ORDER BY id ASC LIMIT 50', { restId, 'paid', 'preparing' }) or {}
    end
    return MySQL.query.await('SELECT * FROM delfzijlrp_restaurant_orders WHERE status IN (?, ?) ORDER BY id ASC LIMIT 50', { 'paid', 'preparing' }) or {}
end)

RegisterNetEvent('delfzijlrp_v3_restaurants:server:setOrderStatus', function(orderId, status)
    local src = source
    orderId = tonumber(orderId)
    status = tostring(status or '')
    local allowed = { preparing = true, ready = true, delivered = true }
    if not orderId or not allowed[status] then notify(src, Config.Text.invalid, 'error') return end
    local row = MySQL.single.await('SELECT * FROM delfzijlrp_restaurant_orders WHERE id = ? LIMIT 1', { orderId })
    if not row then notify(src, Config.Text.invalid, 'error') return end
    MySQL.update.await('UPDATE delfzijlrp_restaurant_orders SET status = ? WHERE id = ?', { status, orderId })
    local rest = Config.Restaurants[row.restaurant_id]
    local businessId = rest and (rest.business or row.restaurant_id) or row.restaurant_id
    exports['delfzijlrp_v3_business_core']:AddLog(businessId, 'order_' .. status, row.price or 0, row.label .. ' #' .. orderId, GetPlayerName(src))
    notify(src, Config.Text.updated or 'Order bijgewerkt.', 'success')
end)
