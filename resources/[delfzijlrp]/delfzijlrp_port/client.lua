local function notify(message, type)
    lib.notify({ title = 'Delfzijl RP Haven', description = message, type = type or 'inform' })
end

local function cargoOptions()
    local options = {}
    for value, cargo in pairs(Config.CargoTypes) do
        options[#options + 1] = { value = value, label = cargo.label }
    end
    return options
end

local function terminalOptions()
    local options = {}
    for _, terminal in ipairs(Config.Terminals) do
        options[#options + 1] = { value = terminal.id, label = terminal.label }
    end
    return options
end

local function getTerminal(id)
    for _, terminal in ipairs(Config.Terminals) do
        if terminal.id == id then return terminal end
    end
    return nil
end

local function progress(label, duration)
    return lib.progressCircle({
        duration = duration,
        label = label,
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = { car = true, move = true, combat = true },
        anim = { dict = 'anim@heists@box_carry@', clip = 'idle' }
    })
end

local function startJobDialog()
    local input = lib.inputDialog('Nieuwe havenopdracht', {
        { type = 'select', label = 'Terminal', required = true, options = terminalOptions() },
        { type = 'select', label = 'Lading', required = true, options = cargoOptions() }
    })
    if input then
        TriggerServerEvent('delfzijlrp_port:server:startJob', input[1], input[2])
    end
end

local function openActiveJob()
    local job = lib.callback.await('delfzijlrp_port:server:getActiveJob', false)
    if not job then
        notify(Config.Text.noCargo, 'inform')
        return
    end

    local terminal = getTerminal(job.terminal_id)
    local cargo = Config.CargoTypes[job.cargo_type]
    local options = {
        { title = 'Actieve opdracht', description = (cargo and cargo.label or job.cargo_type) .. ' | ' .. job.status, icon = 'ship', readOnly = true }
    }

    if terminal then
        options[#options + 1] = { title = 'Waypoint: pickup', icon = 'map-pin', onSelect = function() SetNewWaypoint(terminal.pickup.x, terminal.pickup.y) end }
        options[#options + 1] = { title = 'Waypoint: scan', icon = 'magnifying-glass', onSelect = function() SetNewWaypoint(terminal.scan.x, terminal.scan.y) end }
        options[#options + 1] = { title = 'Waypoint: afleveren', icon = 'flag-checkered', onSelect = function() SetNewWaypoint(terminal.dropoff.x, terminal.dropoff.y) end }
    end

    lib.registerContext({ id = 'delfzijlrp_port_active', title = 'Havenopdracht', options = options })
    lib.showContext('delfzijlrp_port_active')
end

local function openStats()
    local stats = lib.callback.await('delfzijlrp_port:server:getStats', false)
    lib.registerContext({
        id = 'delfzijlrp_port_stats',
        title = 'Havenstatistieken',
        options = {
            { title = 'Afgeronde opdrachten', description = tostring(stats and stats.jobs or 0), icon = 'clipboard-check', readOnly = true },
            { title = 'Totaal verdiend', description = '€' .. tostring(stats and stats.earned or 0), icon = 'euro-sign', readOnly = true }
        }
    })
    lib.showContext('delfzijlrp_port_stats')
end

local function openPortOffice()
    lib.registerContext({
        id = 'delfzijlrp_port_office',
        title = Config.PortOffice.label,
        options = {
            { title = 'Nieuwe havenopdracht', icon = 'plus', onSelect = startJobDialog },
            { title = 'Actieve opdracht', icon = 'truck-ramp-box', onSelect = openActiveJob },
            { title = 'Mijn havenstatistieken', icon = 'chart-line', onSelect = openStats },
            { title = 'Meldkamer openen', icon = 'tower-broadcast', onSelect = function() ExecuteCommand('meldkamer') end }
        }
    })
    lib.showContext('delfzijlrp_port_office')
end

local function pickupAtTerminal(terminal)
    local job = lib.callback.await('delfzijlrp_port:server:getActiveJob', false)
    if not job or job.terminal_id ~= terminal.id then notify(Config.Text.noCargo, 'error') return end
    if progress('Lading ophalen...', Config.Job.pickupDuration) then
        TriggerServerEvent('delfzijlrp_port:server:pickupCargo', job.id)
        SetNewWaypoint(terminal.scan.x, terminal.scan.y)
    end
end

local function scanAtTerminal(terminal)
    local job = lib.callback.await('delfzijlrp_port:server:getActiveJob', false)
    if not job or job.terminal_id ~= terminal.id then notify(Config.Text.noCargo, 'error') return end
    if progress('Lading scannen...', Config.Job.scanDuration) then
        local coords = GetEntityCoords(PlayerPedId())
        TriggerServerEvent('delfzijlrp_port:server:scanCargo', job.id, { x = coords.x, y = coords.y, z = coords.z })
        SetNewWaypoint(terminal.dropoff.x, terminal.dropoff.y)
    end
end

local function deliverAtTerminal(terminal)
    local job = lib.callback.await('delfzijlrp_port:server:getActiveJob', false)
    if not job or job.terminal_id ~= terminal.id then notify(Config.Text.noCargo, 'error') return end
    if progress('Lading afleveren...', Config.Job.deliverDuration) then
        TriggerServerEvent('delfzijlrp_port:server:deliverCargo', job.id)
    end
end

CreateThread(function()
    Wait(1500)

    if Config.PortOffice.blip then
        local blip = AddBlipForCoord(Config.PortOffice.coords.x, Config.PortOffice.coords.y, Config.PortOffice.coords.z)
        SetBlipSprite(blip, Config.PortOffice.blip.sprite)
        SetBlipColour(blip, Config.PortOffice.blip.color)
        SetBlipScale(blip, Config.PortOffice.blip.scale)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(Config.PortOffice.label)
        EndTextCommandSetBlipName(blip)
    end

    exports.ox_target:addSphereZone({
        coords = Config.PortOffice.coords,
        radius = Config.PortOffice.radius,
        debug = Config.Debug,
        options = {{ name = 'port_office', icon = 'fa-solid fa-ship', label = Config.Text.openOffice, onSelect = openPortOffice }}
    })

    for _, terminal in ipairs(Config.Terminals) do
        exports.ox_target:addSphereZone({
            coords = terminal.pickup,
            radius = terminal.radius,
            debug = Config.Debug,
            options = {{ name = 'port_pickup_' .. terminal.id, icon = 'fa-solid fa-box', label = 'Lading ophalen', onSelect = function() pickupAtTerminal(terminal) end }}
        })
        exports.ox_target:addSphereZone({
            coords = terminal.scan,
            radius = terminal.radius,
            debug = Config.Debug,
            options = {{ name = 'port_scan_' .. terminal.id, icon = 'fa-solid fa-magnifying-glass', label = 'Lading scannen', onSelect = function() scanAtTerminal(terminal) end }}
        })
        exports.ox_target:addSphereZone({
            coords = terminal.dropoff,
            radius = terminal.radius,
            debug = Config.Debug,
            options = {{ name = 'port_deliver_' .. terminal.id, icon = 'fa-solid fa-flag-checkered', label = 'Lading afleveren', onSelect = function() deliverAtTerminal(terminal) end }}
        })
    end
end)

RegisterCommand(Config.Command, openPortOffice, false)
RegisterCommand(Config.JobCommand, openActiveJob, false)

RegisterNetEvent('delfzijlrp_port:client:setJobWaypoint', function(coords)
    SetNewWaypoint(coords.x, coords.y)
end)
