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
            controlcenter = GetResourceState('delfzijlrp_v3_controlcenter')
        },
        players = players
    }
end

SetHttpHandler(function(req, res)
    local path = req.path or '/'
    local method = req.method or 'GET'

    if method == 'OPTIONS' then send(res, 200, { ok = true }) return end
    if not authorized(req) then send(res, 401, { ok = false, error = 'unauthorized' }) return end

    if path == '/drcc/status' and method == 'GET' then
        send(res, 200, buildStatus())
        return
    end

    if path == '/drcc/announce' and method == 'POST' then
        readJson(req, function(body)
            local message = tostring(body.message or '')
            if message == '' then send(res, 400, { ok = false, error = 'missing message' }) return end
            TriggerClientEvent('ox_lib:notify', -1, {
                title = 'Delfzijl RP',
                description = message,
                type = 'inform',
                duration = 12000
            })
            send(res, 200, { ok = true, message = 'announcement sent' })
        end)
        return
    end

    send(res, 404, { ok = false, error = 'not found', path = path })
end)
