local function notify(text, kind)
    lib.notify({ title = 'Vehicle Ecosystem', description = text, type = kind or 'inform' })
end

local function showProfile(data)
    if not data then notify(Config.Text.notFound, 'error') return end
    local opts = {
        { title = 'Plaat', description = data.plate or '-', readOnly = true },
        { title = 'Waarde', description = '€' .. tostring(data.value or 0), readOnly = true },
        { title = 'Conditie', description = tostring(data.condition_score or 0) .. '/100', readOnly = true },
        { title = 'Onderhoud', description = tostring(data.service_score or 0) .. '/100', readOnly = true },
        { title = 'Tracker', description = tonumber(data.tracker_enabled or 0) == 1 and 'Aan' or 'Uit', readOnly = true },
        { title = 'Sleutels', description = tonumber(data.keys_enabled or 0) == 1 and 'Actief' or 'Uit', readOnly = true }
    }
    if data.rdw then
        opts[#opts + 1] = { title = 'RDW eigenaar', description = data.rdw.owner_name or '-', readOnly = true }
        opts[#opts + 1] = { title = 'RDW APK', description = tostring(data.rdw.apk_until or '-'), readOnly = true }
    end
    for _, h in ipairs(data.history or {}) do
        opts[#opts + 1] = { title = 'Historie: ' .. h.action, description = (h.details or '') .. ' | ' .. tostring(h.created_at), readOnly = true }
    end
    lib.registerContext({ id = 'veh_eco_result', title = 'Voertuig Eco ' .. data.plate, menu = 'veh_eco_main', options = opts })
    lib.showContext('veh_eco_result')
end

local function search()
    local input = lib.inputDialog('Voertuig Eco zoeken', {
        { type = 'input', label = 'Plaat', required = true }
    })
    if not input then return end
    local data = lib.callback.await('delfzijlrp_v3_veh_eco:server:get', false, input[1])
    showProfile(data)
end

local function scores()
    local input = lib.inputDialog('Scores aanpassen', {
        { type = 'input', label = 'Plaat', required = true },
        { type = 'number', label = 'Conditie 0-100', required = true, min = 0, max = 100 },
        { type = 'number', label = 'Onderhoud 0-100', required = true, min = 0, max = 100 }
    })
    if not input then return end
    TriggerServerEvent('delfzijlrp_v3_veh_eco:server:updateScores', input[1], input[2], input[3])
end

local function main()
    lib.registerContext({
        id = 'veh_eco_main',
        title = 'Vehicle Ecosystem',
        options = {
            { title = 'Zoeken / maken', description = 'Voertuigprofiel openen', onSelect = search },
            { title = 'Conditie & onderhoud', description = 'Scores aanpassen', onSelect = scores }
        }
    })
    lib.showContext('veh_eco_main')
end

RegisterCommand(Config.Command, main, false)
