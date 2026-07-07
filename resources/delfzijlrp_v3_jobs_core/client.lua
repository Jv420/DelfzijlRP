local function notify(text, kind)
    lib.notify({ title = 'Jobs Core', description = text, type = kind or 'inform' })
end

local function openHire()
    local input = lib.inputDialog('Medewerker aannemen', {
        { type = 'input', label = 'Bedrijf ID', required = true },
        { type = 'number', label = 'Speler server ID', required = true, min = 1 },
        { type = 'input', label = 'Rol', required = true, default = 'employee' },
        { type = 'number', label = 'Salaris per minuut', required = true, min = 1, default = Config.DefaultPayPerMinute }
    })
    if input then TriggerServerEvent('delfzijlrp_v3_jobs_core:server:hire', input[1], input[2], input[3], input[4]) end
end

local function openFire()
    local input = lib.inputDialog('Medewerker uitschrijven', {
        { type = 'input', label = 'Bedrijf ID', required = true },
        { type = 'input', label = 'Identifier/license van speler', required = true }
    })
    if input then TriggerServerEvent('delfzijlrp_v3_jobs_core:server:fire', input[1], input[2]) end
end

local function openClockIn()
    local jobs = lib.callback.await('delfzijlrp_v3_jobs_core:server:getMine', false) or {}
    local opts = {}
    for _, j in ipairs(jobs) do
        opts[#opts + 1] = {
            title = j.business_id,
            description = (Config.Roles[j.role] or j.role) .. ' | €' .. tostring(j.pay_per_minute) .. '/min',
            onSelect = function() TriggerServerEvent('delfzijlrp_v3_jobs_core:server:clockIn', j.business_id) end
        }
    end
    if #opts == 0 then opts[1] = { title = 'Geen banen gevonden', description = 'Je staat nog niet als werknemer geregistreerd.', readOnly = true } end
    lib.registerContext({ id = 'jobs_clockin', title = 'In dienst gaan', menu = 'jobs_main', options = opts })
    lib.showContext('jobs_clockin')
end

local function openMenu()
    local shift = lib.callback.await('delfzijlrp_v3_jobs_core:server:getShift', false)
    local opts = {
        { title = 'In dienst gaan', description = 'Kies een bedrijf waar je werkt', onSelect = openClockIn },
        { title = 'Uit dienst gaan', description = shift and ('Actief bij ' .. shift.business_id) or 'Geen actieve dienst', disabled = not shift, onSelect = function() TriggerServerEvent('delfzijlrp_v3_jobs_core:server:clockOut') end },
        { title = 'Medewerker aannemen', description = 'Alleen eigenaar/manager', onSelect = openHire },
        { title = 'Medewerker uitschrijven', description = 'Alleen eigenaar/manager', onSelect = openFire }
    }
    if shift then
        opts[#opts + 1] = { title = 'Actieve dienst', description = shift.business_id .. ' | ' .. shift.role .. ' | gestart: ' .. tostring(shift.started_at), readOnly = true }
    end
    lib.registerContext({ id = 'jobs_main', title = 'DRP Jobs', options = opts })
    lib.showContext('jobs_main')
end

RegisterCommand(Config.Command, openMenu, false)
RegisterCommand(Config.ClockInCommand, openClockIn, false)
RegisterCommand(Config.ClockOutCommand, function() TriggerServerEvent('delfzijlrp_v3_jobs_core:server:clockOut') end, false)
