local function notify(text, kind)
    lib.notify({ title = 'Business Manager', description = text, type = kind or 'inform' })
end

local function openEmployeeEdit(businessId, emp)
    local input = lib.inputDialog('Medewerker aanpassen', {
        { type = 'input', label = 'Rol', required = true, default = emp.role or 'employee' },
        { type = 'number', label = 'Salaris per minuut', required = true, min = 1, default = emp.pay_per_minute or 35 }
    })
    if input then
        TriggerServerEvent('delfzijlrp_v3_business_manager:server:setEmployeeRole', businessId, emp.identifier, input[1], input[2])
    end
end

local function openStockEdit(businessId, stock)
    local input = lib.inputDialog('Prijs aanpassen', {
        { type = 'number', label = 'Prijs', required = true, min = 0, default = stock.price or 0 }
    })
    if input then TriggerServerEvent('delfzijlrp_v3_business_manager:server:setStockPrice', businessId, stock.item, input[1]) end
end

local function money(value)
    return '€' .. tostring(value or 0)
end

local function showDashboard(businessId)
    local data = lib.callback.await('delfzijlrp_v3_business_manager:server:getDashboard', false, businessId)
    if not data then return end
    local b = data.business
    local stats = data.stats or {}

    local opts = {
        { title = 'Saldo', description = money(b.balance), readOnly = true },
        { title = 'Totale omzet', description = money(b.turnover), readOnly = true },
        { title = 'Omzet vandaag', description = money(data.sales.today), readOnly = true },
        { title = 'Omzet deze week', description = money(data.sales.week), readOnly = true },
        { title = 'Omzet deze maand', description = money(data.sales.month), readOnly = true },
        { title = 'Personeel actief/totaal', description = tostring(stats.active_shifts or 0) .. ' in dienst | ' .. tostring(stats.employee_count or 0) .. ' medewerkers', readOnly = true },
        { title = 'Open orders', description = tostring(stats.open_orders or 0), readOnly = true },
        { title = 'Reviews', description = tostring(stats.review_average or 0) .. '/5 uit ' .. tostring(stats.review_count or 0) .. ' reviews', readOnly = true }
    }

    opts[#opts + 1] = { title = '--- Personeel ---', readOnly = true }
    for _, e in ipairs(data.employees or {}) do
        opts[#opts + 1] = {
            title = e.player_name,
            description = e.role .. ' | €' .. tostring(e.pay_per_minute) .. '/min | actief: ' .. tostring(e.active),
            onSelect = function() openEmployeeEdit(businessId, e) end
        }
    end

    opts[#opts + 1] = { title = '--- Voorraad / producten ---', readOnly = true }
    for _, s in ipairs(data.stock or {}) do
        opts[#opts + 1] = {
            title = s.label or s.item,
            description = tostring(s.amount) .. 'x | €' .. tostring(s.price),
            onSelect = function() openStockEdit(businessId, s) end
        }
    end

    opts[#opts + 1] = { title = '--- Orders ---', readOnly = true }
    for _, o in ipairs(data.orders or {}) do
        opts[#opts + 1] = { title = '#' .. o.id .. ' ' .. o.label, description = o.status .. ' | €' .. tostring(o.price) .. ' | klant: ' .. o.player_name, readOnly = true }
    end

    opts[#opts + 1] = { title = '--- Reviews ---', readOnly = true }
    for _, r in ipairs(data.reviews or {}) do
        opts[#opts + 1] = { title = r.player_name .. ' ' .. tostring(r.rating) .. '/5', description = r.text or '', readOnly = true }
    end

    opts[#opts + 1] = { title = '--- Laatste logs ---', readOnly = true }
    for _, l in ipairs(data.logs or {}) do
        opts[#opts + 1] = { title = l.action .. ' €' .. tostring(l.amount or 0), description = (l.details or '') .. ' | ' .. tostring(l.created_by or ''), readOnly = true }
    end

    lib.registerContext({ id = 'biz_manager_dashboard_' .. businessId, title = b.label or businessId, options = opts })
    lib.showContext('biz_manager_dashboard_' .. businessId)
end

local function openManager()
    local rows = lib.callback.await('delfzijlrp_v3_business_manager:server:getMyBusinesses', false) or {}
    local opts = {}
    for _, b in ipairs(rows) do
        opts[#opts + 1] = {
            title = b.label or b.business_id,
            description = b.role .. ' | saldo €' .. tostring(b.balance or 0) .. ' | omzet €' .. tostring(b.turnover or 0),
            onSelect = function() showDashboard(b.business_id) end
        }
    end
    if #opts == 0 then opts[1] = { title = 'Geen beheerrechten', description = 'Je bent geen owner/manager bij een bedrijf.', readOnly = true } end
    lib.registerContext({ id = 'biz_manager_main', title = Config.Text.title, options = opts })
    lib.showContext('biz_manager_main')
end

RegisterCommand(Config.Command, openManager, false)
