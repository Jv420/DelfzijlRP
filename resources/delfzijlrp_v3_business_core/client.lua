local function notify(text, kind)
    lib.notify({ title = 'Business Core', description = text, type = kind or 'inform' })
end

local function showBusiness(id)
    local b = lib.callback.await('delfzijlrp_v3_business_core:server:get', false, id)
    if not b then notify(Config.Text.notFound, 'error') return end

    local opts = {
        { title = 'Naam', description = b.label or '-', readOnly = true },
        { title = 'Type', description = b.type or '-', readOnly = true },
        { title = 'Eigenaar', description = b.owner_name or 'Geen eigenaar', readOnly = true },
        { title = 'Bedrijfskas', description = '€' .. tostring(b.balance or 0), readOnly = true },
        { title = 'Omzet', description = '€' .. tostring(b.turnover or 0), readOnly = true },
        { title = 'Eigenaar claimen', description = 'Alleen als er nog geen eigenaar is', onSelect = function()
            TriggerServerEvent('delfzijlrp_v3_business_core:server:claimOwner', b.id)
        end },
        { title = 'Geld storten', description = 'Contant naar bedrijfskas', onSelect = function()
            local input = lib.inputDialog('Geld storten', {
                { type = 'number', label = 'Bedrag', required = true, min = 1 }
            })
            if input then TriggerServerEvent('delfzijlrp_v3_business_core:server:addMoney', b.id, input[1]) end
        end }
    }

    for _, e in ipairs(b.employees or {}) do
        opts[#opts + 1] = { title = 'Werknemer: ' .. e.player_name, description = e.role .. ' | salaris €' .. tostring(e.salary), readOnly = true }
    end
    for _, s in ipairs(b.stock or {}) do
        opts[#opts + 1] = { title = 'Voorraad: ' .. (s.label or s.item), description = tostring(s.amount) .. 'x | €' .. tostring(s.price), readOnly = true }
    end
    for _, l in ipairs(b.logs or {}) do
        opts[#opts + 1] = { title = 'Log: ' .. l.action, description = (l.details or '') .. ' | €' .. tostring(l.amount), readOnly = true }
    end

    lib.registerContext({ id = 'business_core_detail', title = b.label, menu = 'business_core_main', options = opts })
    lib.showContext('business_core_detail')
end

local function openList()
    local rows = lib.callback.await('delfzijlrp_v3_business_core:server:list', false) or {}
    local opts = {}
    for _, b in ipairs(rows) do
        opts[#opts + 1] = {
            title = b.label,
            description = (b.type or '-') .. ' | eigenaar: ' .. (b.owner_name or 'geen'),
            onSelect = function() showBusiness(b.id) end
        }
    end
    if #opts == 0 then opts[1] = { title = 'Geen bedrijven gevonden', readOnly = true } end
    lib.registerContext({ id = 'business_core_main', title = 'Delfzijl Bedrijven', options = opts })
    lib.showContext('business_core_main')
end

RegisterCommand(Config.Command, openList, false)
