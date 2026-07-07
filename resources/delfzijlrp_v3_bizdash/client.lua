local function money(v)
    return '€' .. tostring(v or 0)
end

local function openDashboard(businessId)
    local data = lib.callback.await('delfzijlrp_v3_bizdash:server:get', false, businessId)
    if not data or not data.business then return end
    local b = data.business
    local opts = {
        { title = 'Bedrijf', description = b.label .. ' (' .. b.id .. ')', readOnly = true },
        { title = 'Saldo', description = money(b.balance), readOnly = true },
        { title = 'Totale omzet', description = money(b.turnover), readOnly = true },
        { title = 'Eigenaar', description = b.owner_name or 'Geen eigenaar', readOnly = true },
        { title = 'Werknemers', description = tostring(#(data.employees or {})), readOnly = true },
        { title = 'Actieve diensten', description = tostring(#(data.active_shifts or {})), readOnly = true }
    }

    if data.rating then
        opts[#opts + 1] = { title = 'Reviews gemiddeld', description = tostring(data.rating.avg_rating or 0) .. '/5 uit ' .. tostring(data.rating.total_reviews or 0) .. ' reviews', readOnly = true }
    end

    opts[#opts + 1] = { title = '--- Werknemers ---', readOnly = true }
    for _, e in ipairs(data.employees or {}) do
        opts[#opts + 1] = { title = e.player_name, description = e.role .. ' | ' .. money(e.pay_per_minute) .. '/min', readOnly = true }
    end

    opts[#opts + 1] = { title = '--- Actieve diensten ---', readOnly = true }
    for _, s in ipairs(data.active_shifts or {}) do
        opts[#opts + 1] = { title = s.player_name, description = s.role .. ' | gestart: ' .. tostring(s.started_at), readOnly = true }
    end

    if data.stock then
        opts[#opts + 1] = { title = '--- Voorraad ---', readOnly = true }
        for _, st in ipairs(data.stock or {}) do
            local low = tonumber(st.amount or 0) <= tonumber(st.minimum or 0)
            opts[#opts + 1] = { title = st.ingredient, description = 'Aantal: ' .. tostring(st.amount) .. (low and ' | LAAG' or ''), readOnly = true }
        end
    end

    if data.orders then
        opts[#opts + 1] = { title = '--- Laatste orders ---', readOnly = true }
        for _, o in ipairs(data.orders or {}) do
            opts[#opts + 1] = { title = '#' .. o.id .. ' ' .. o.label, description = o.status .. ' | ' .. o.player_name .. ' | ' .. money(o.price), readOnly = true }
        end
    end

    if data.reviews then
        opts[#opts + 1] = { title = '--- Reviews ---', readOnly = true }
        for _, r in ipairs(data.reviews or {}) do
            opts[#opts + 1] = { title = r.player_name .. ' - ' .. tostring(r.rating) .. '/5', description = r.text or '', readOnly = true }
        end
    end

    opts[#opts + 1] = { title = '--- Logs ---', readOnly = true }
    for _, l in ipairs(data.logs or {}) do
        opts[#opts + 1] = { title = l.action .. ' ' .. money(l.amount), description = (l.details or '') .. ' | ' .. (l.created_by or ''), readOnly = true }
    end

    lib.registerContext({ id = 'bizdash_detail_' .. businessId, title = 'Business Dashboard', options = opts })
    lib.showContext('bizdash_detail_' .. businessId)
end

local function openList()
    local rows = lib.callback.await('delfzijlrp_v3_bizdash:server:listMine', false) or {}
    local opts = {}
    for _, r in ipairs(rows) do
        opts[#opts + 1] = { title = r.business_id, description = 'Rol: ' .. r.role, onSelect = function() openDashboard(r.business_id) end }
    end
    if #opts == 0 then opts[1] = { title = 'Geen manager-bedrijven gevonden', description = 'Je moet owner of manager zijn.', readOnly = true } end
    lib.registerContext({ id = 'bizdash_list', title = 'Mijn bedrijven', options = opts })
    lib.showContext('bizdash_list')
end

RegisterCommand(Config.Command, openList, false)
