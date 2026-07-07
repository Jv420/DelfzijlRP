local ESX = exports['es_extended']:getSharedObject()

local function headers()
    return {
        ['Content-Type'] = 'application/json',
        ['Access-Control-Allow-Origin'] = '*',
        ['Access-Control-Allow-Headers'] = 'Content-Type, x-drcc-key',
        ['Access-Control-Allow-Methods'] = 'GET, POST, OPTIONS'
    }
end

local function send(res, code, data)
    res.writeHead(code, headers())
    res.send(json.encode(data))
end

local function authorized(req)
    local key = req.headers and (req.headers['x-drcc-key'] or req.headers['X-DRCC-Key'])
    return key and key == Config.ApiKey and Config.ApiKey ~= 'CHANGE_ME_SUPER_SECRET_KEY'
end

local function cleanId(id)
    return tostring(id or ''):lower():gsub('%s+', '')
end

local function readJson(req, cb)
    local body = ''
    req.setDataHandler(function(data) body = body .. (data or '') end)
    SetTimeout(100, function()
        local ok, decoded = pcall(json.decode, body ~= '' and body or '{}')
        cb(ok and decoded or {})
    end)
end

local function buildStatus()
    local players = {}
    for _, id in ipairs(GetPlayers()) do
        local sid = tonumber(id)
        local xPlayer = ESX.GetPlayerFromId(sid)
        players[#players + 1] = {
            id = sid,
            name = GetPlayerName(sid),
            identifier = xPlayer and xPlayer.identifier or '',
            job = xPlayer and xPlayer.job and xPlayer.job.name or 'unknown'
        }
    end
    return {
        ok = true,
        server = GetConvar('sv_hostname', 'Delfzijl RP'),
        online = #players,
        max = GetConvarInt('sv_maxclients', 0),
        resources = {
            es_extended = GetResourceState('es_extended'),
            ox_inventory = GetResourceState('ox_inventory'),
            oxmysql = GetResourceState('oxmysql'),
            business_core = GetResourceState('delfzijlrp_v3_business_core'),
            jobs_core = GetResourceState('delfzijlrp_v3_jobs_core'),
            restaurants = GetResourceState('delfzijlrp_v3_restaurants'),
            business_manager = GetResourceState('delfzijlrp_v3_business_manager'),
            controlcenter = GetResourceState('delfzijlrp_v3_controlcenter'),
            fanta_inbox = GetResourceState('delfzijlrp_v3_fanta_inbox')
        },
        players = players
    }
end

local function getOnlinePlayer(id)
    id = tonumber(id)
    if not id then return nil end
    return ESX.GetPlayerFromId(id)
end

local function queueReward(targetId, rewardType, rewardData)
    local xPlayer = getOnlinePlayer(targetId)
    if not xPlayer then return false, 'player not online' end
    if GetResourceState('delfzijlrp_v3_fanta_inbox') ~= 'started' then return false, 'fanta inbox not started' end
    local queueId = exports['delfzijlrp_v3_fanta_inbox']:CreateFantaQueue(
        xPlayer.identifier,
        GetPlayerName(xPlayer.source),
        rewardType,
        rewardData,
        'fanta-web'
    )
    return true, queueId
end

local function listBusinesses()
    local rows = MySQL.query.await('SELECT id, label, type, owner_name, balance, turnover, active FROM delfzijlrp_businesses ORDER BY label ASC') or {}
    return { ok = true, businesses = rows }
end

local function businessDashboard(businessId)
    businessId = cleanId(businessId)
    if businessId == '' then return nil, 'missing businessId' end

    local business = exports['delfzijlrp_v3_business_core']:GetBusiness(businessId)
    if not business then return nil, 'business not found' end

    local employees = MySQL.query.await('SELECT identifier, player_name, role, pay_per_minute, active FROM delfzijlrp_jobs_employees WHERE business_id = ? ORDER BY active DESC, role ASC, player_name ASC', { businessId }) or {}
    local shifts = MySQL.query.await('SELECT player_name, role, started_at, ended_at, minutes_worked, payout, status FROM delfzijlrp_jobs_shifts WHERE business_id = ? ORDER BY id DESC LIMIT 25', { businessId }) or {}
    local logs = MySQL.query.await('SELECT action, amount, details, created_by, created_at FROM delfzijlrp_business_logs WHERE business_id = ? ORDER BY id DESC LIMIT 50', { businessId }) or {}
    local stock = MySQL.query.await('SELECT item, label, amount, price FROM delfzijlrp_business_stock WHERE business_id = ? ORDER BY label ASC', { businessId }) or {}
    local orders = MySQL.query.await('SELECT id, restaurant_id, player_name, label, amount, price, status, courier_name, created_at FROM delfzijlrp_restaurant_orders WHERE restaurant_id = ? ORDER BY id DESC LIMIT 50', { businessId }) or {}
    local reviews = MySQL.query.await('SELECT player_name, rating, text, created_at FROM delfzijlrp_restaurant_reviews WHERE restaurant_id = ? ORDER BY id DESC LIMIT 25', { businessId }) or {}
    local today = MySQL.single.await("SELECT COALESCE(SUM(amount),0) AS total FROM delfzijlrp_business_logs WHERE business_id = ? AND action = 'sale' AND DATE(created_at) = CURDATE()", { businessId })
    local week = MySQL.single.await("SELECT COALESCE(SUM(amount),0) AS total FROM delfzijlrp_business_logs WHERE business_id = ? AND action = 'sale' AND YEARWEEK(created_at, 1) = YEARWEEK(CURDATE(), 1)", { businessId })
    local month = MySQL.single.await("SELECT COALESCE(SUM(amount),0) AS total FROM delfzijlrp_business_logs WHERE business_id = ? AND action = 'sale' AND YEAR(created_at) = YEAR(CURDATE()) AND MONTH(created_at) = MONTH(CURDATE())", { businessId })
    local activeShifts = MySQL.single.await("SELECT COUNT(*) AS total FROM delfzijlrp_jobs_shifts WHERE business_id = ? AND status = 'active'", { businessId })
    local openOrders = MySQL.single.await("SELECT COUNT(*) AS total FROM delfzijlrp_restaurant_orders WHERE restaurant_id = ? AND status IN ('paid','preparing','ready','picked_up')", { businessId })
    local avgReview = MySQL.single.await('SELECT COALESCE(AVG(rating),0) AS avg_rating, COUNT(*) AS total FROM delfzijlrp_restaurant_reviews WHERE restaurant_id = ?', { businessId })

    return {
        ok = true,
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
        },
        stats = {
            employee_count = #employees,
            active_shifts = tonumber(activeShifts and activeShifts.total or 0) or 0,
            open_orders = tonumber(openOrders and openOrders.total or 0) or 0,
            review_average = tonumber(avgReview and avgReview.avg_rating or 0) or 0,
            review_count = tonumber(avgReview and avgReview.total or 0) or 0
        }
    }
end

SetHttpHandler(function(req, res)
    local path = req.path or '/'
    local method = req.method or 'GET'

    if method == 'OPTIONS' then send(res, 200, { ok = true }) return end
    if not authorized(req) then send(res, 401, { ok = false, error = 'unauthorized' }) return end

    if path == '/drcc/status' and method == 'GET' then send(res, 200, buildStatus()) return end
    if path == '/drcc/businesses' and method == 'GET' then send(res, 200, listBusinesses()) return end

    if path == '/drcc/business/dashboard' and method == 'POST' then
        readJson(req, function(body)
            local data, err = businessDashboard(body.businessId or body.id)
            if not data then send(res, 400, { ok = false, error = err }) return end
            send(res, 200, data)
        end)
        return
    end

    if path == '/drcc/announce' and method == 'POST' then
        readJson(req, function(body)
            local message = tostring(body.message or '')
            if message == '' then send(res, 400, { ok = false, error = 'missing message' }) return end
            TriggerClientEvent('ox_lib:notify', -1, { title = 'Delfzijl RP', description = message, type = 'inform', duration = 12000 })
            send(res, 200, { ok = true, message = 'announcement sent' })
        end)
        return
    end

    if path == '/drcc/queue/money' and method == 'POST' then
        readJson(req, function(body)
            local targetId = tonumber(body.targetId)
            local amount = tonumber(body.amount) or 0
            local account = body.account == 'cash' and 'cash' or 'bank'
            if not targetId or amount <= 0 then send(res, 400, { ok = false, error = 'invalid data' }) return end
            local ok, result = queueReward(targetId, 'money', { amount = amount, account = account })
            if not ok then send(res, 400, { ok = false, error = result }) return end
            send(res, 200, { ok = true, queue_id = result, status = 'pending_approval' })
        end)
        return
    end

    if path == '/drcc/queue/item' and method == 'POST' then
        readJson(req, function(body)
            local targetId = tonumber(body.targetId)
            local item = tostring(body.item or '')
            local count = tonumber(body.count) or 1
            if not targetId or item == '' or count < 1 then send(res, 400, { ok = false, error = 'invalid data' }) return end
            local ok, result = queueReward(targetId, 'item', { item = item, count = count })
            if not ok then send(res, 400, { ok = false, error = result }) return end
            send(res, 200, { ok = true, queue_id = result, status = 'pending_approval' })
        end)
        return
    end

    send(res, 404, { ok = false, error = 'not found', path = path })
end)
