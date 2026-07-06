local function notify(text, kind)
    lib.notify({ title = 'RDW Premium', description = text, type = kind or 'inform' })
end

local function openSearch()
    local input = lib.inputDialog('Zoeken', {
        { type = 'input', label = 'Plaat', required = true }
    })
    if not input then return end
    local data = lib.callback.await('delfzijlrp_v3_rdw_premium:server:searchPlate', false, input[1])
    if not data then notify(Config.Text.notFound, 'error') return end

    lib.registerContext({
        id = 'rdwp_result',
        title = 'RDW ' .. data.plate,
        menu = 'rdwp_main',
        options = {
            { title = 'Plaat', description = data.plate or '-', readOnly = true },
            { title = 'Eigenaar', description = data.owner_name or '-', readOnly = true },
            { title = 'Burgernummer', description = data.citizen_id or '-', readOnly = true },
            { title = 'Model', description = data.model or '-', readOnly = true },
            { title = 'VIN', description = data.vin or '-', readOnly = true },
            { title = 'APK tot', description = tostring(data.apk_until or '-'), readOnly = true },
            { title = 'Status', description = data.status or '-', readOnly = true }
        }
    })
    lib.showContext('rdwp_result')
end

local function openRegister()
    local input = lib.inputDialog('Registreren', {
        { type = 'input', label = 'Plaat', required = true },
        { type = 'input', label = 'Model', required = true }
    })
    if not input then return end
    TriggerServerEvent('delfzijlrp_v3_rdw_premium:server:registerMine', input[1], input[2])
end

local function main()
    lib.registerContext({
        id = 'rdwp_main',
        title = 'RDW Premium',
        options = {
            { title = 'Zoeken', description = 'Zoek een voertuig op plaat', onSelect = openSearch },
            { title = 'Registreren', description = 'Registreer testvoertuig', onSelect = openRegister }
        }
    })
    lib.showContext('rdwp_main')
end

RegisterCommand(Config.Command, main, false)
