local function notify(message, type)
    lib.notify({ title = Config.Server.name, description = message, type = type or 'inform' })
end

local function setWaypoint(coords)
    SetNewWaypoint(coords.x, coords.y)
    notify(Config.Text.waypointSet, 'success')
end

local function openList(title, rows, icon)
    local options = {}
    for index, text in ipairs(rows or {}) do
        options[#options + 1] = {
            title = tostring(index) .. '. ' .. text,
            icon = icon or 'circle-info',
            readOnly = true
        }
    end
    if #options == 0 then
        options[#options + 1] = { title = Config.Text.noData, icon = 'circle-info', readOnly = true }
    end
    lib.registerContext({ id = 'delfzijlrp_cityhub_list', title = title, options = options })
    lib.showContext('delfzijlrp_cityhub_list')
end

local function openLocations(locations)
    local options = {}
    for _, location in ipairs(locations or {}) do
        options[#options + 1] = {
            title = location.label,
            description = 'Waypoint zetten of systeem openen',
            icon = 'location-dot',
            onSelect = function()
                lib.registerContext({
                    id = 'delfzijlrp_cityhub_location',
                    title = location.label,
                    options = {
                        { title = 'Waypoint zetten', icon = 'map-pin', onSelect = function() setWaypoint(location.coords) end },
                        { title = 'Command openen', description = '/' .. location.command, icon = 'terminal', onSelect = function() ExecuteCommand(location.command) end }
                    }
                })
                lib.showContext('delfzijlrp_cityhub_location')
            end
        }
    end
    lib.registerContext({ id = 'delfzijlrp_cityhub_locations', title = 'Belangrijke locaties', options = options })
    lib.showContext('delfzijlrp_cityhub_locations')
end

local function openShortcuts(shortcuts)
    local options = {}
    for _, shortcut in ipairs(shortcuts or {}) do
        options[#options + 1] = {
            title = shortcut.label,
            description = '/' .. shortcut.command,
            icon = shortcut.icon or 'bolt',
            onSelect = function() ExecuteCommand(shortcut.command) end
        }
    end
    lib.registerContext({ id = 'delfzijlrp_cityhub_shortcuts', title = 'Snelkoppelingen', options = options })
    lib.showContext('delfzijlrp_cityhub_shortcuts')
end

local function openCityHub()
    local data = lib.callback.await('delfzijlrp_cityhub:server:getData', false)
    if not data then return end

    local identityLine = data.identity and (data.identity.firstname .. ' ' .. data.identity.lastname .. ' | ' .. data.identity.delfzijl_id) or 'Nog geen Delfzijl ID'

    lib.registerContext({
        id = 'delfzijlrp_cityhub_main',
        title = data.server.name,
        options = {
            { title = data.server.description, description = ('Online: %s | Job: %s'):format(data.online or 0, data.player.job), icon = 'city', readOnly = true },
            { title = 'Mijn profiel', description = identityLine, icon = 'id-card', readOnly = true },
            { title = 'Startertips', icon = 'lightbulb', onSelect = function() openList('Startertips', data.starterTips, 'lightbulb') end },
            { title = 'Serverregels', icon = 'scale-balanced', onSelect = function() openList('Serverregels', data.rules, 'scale-balanced') end },
            { title = 'Belangrijke locaties', icon = 'map-location-dot', onSelect = function() openLocations(data.locations) end },
            { title = 'Snelkoppelingen', icon = 'bolt', onSelect = function() openShortcuts(data.shortcuts) end },
            { title = 'Discord', description = data.server.discord, icon = 'comments', readOnly = true },
            { title = 'Website', description = data.server.website, icon = 'globe', readOnly = true }
        }
    })

    lib.showContext('delfzijlrp_cityhub_main')
end

CreateThread(function()
    Wait(1500)

    if Config.Hub.blip then
        local blip = AddBlipForCoord(Config.Hub.coords.x, Config.Hub.coords.y, Config.Hub.coords.z)
        SetBlipSprite(blip, Config.Hub.blip.sprite)
        SetBlipColour(blip, Config.Hub.blip.color)
        SetBlipScale(blip, Config.Hub.blip.scale)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(Config.Hub.label)
        EndTextCommandSetBlipName(blip)
    end

    exports.ox_target:addSphereZone({
        coords = Config.Hub.coords,
        radius = Config.Hub.radius,
        debug = Config.Debug,
        options = {
            {
                name = 'delfzijlrp_cityhub_open',
                icon = 'fa-solid fa-circle-info',
                label = Config.Text.openHub,
                distance = 2.0,
                onSelect = openCityHub
            }
        }
    })
end)

RegisterCommand(Config.Command, openCityHub, false)
RegisterCommand(Config.HelpCommand, openCityHub, false)
