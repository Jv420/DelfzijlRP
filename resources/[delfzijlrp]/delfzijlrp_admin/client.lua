local function notify(message, type)
    lib.notify({ title = 'Delfzijl RP Staff', description = message, type = type or 'inform' })
end

local function openReports()
    local reports = lib.callback.await('delfzijlrp_admin:server:getReports', false) or {}
    local options = {}

    for _, report in ipairs(reports) do
        options[#options + 1] = {
            title = ('#%s | %s'):format(report.id, report.player_name or 'Onbekend'),
            description = report.message,
            icon = 'flag',
            onSelect = function()
                lib.registerContext({
                    id = 'delfzijlrp_admin_report_detail',
                    title = ('Report #%s'):format(report.id),
                    options = {
                        { title = 'Speler', description = report.player_name or 'Onbekend', icon = 'user', readOnly = true },
                        { title = 'Bericht', description = report.message, icon = 'message', readOnly = true },
                        { title = 'Afsluiten', icon = 'check', onSelect = function() TriggerServerEvent('delfzijlrp_admin:server:closeReport', report.id) end }
                    }
                })
                lib.showContext('delfzijlrp_admin_report_detail')
            end
        }
    end

    if #options == 0 then
        options[#options + 1] = { title = 'Geen open reports', icon = 'circle-info', readOnly = true }
    end

    lib.registerContext({ id = 'delfzijlrp_admin_reports', title = 'Reports', options = options })
    lib.showContext('delfzijlrp_admin_reports')
end

local function openPlayerActions(player)
    lib.registerContext({
        id = 'delfzijlrp_admin_player_actions',
        title = ('%s [%s]'):format(player.name, player.id),
        options = {
            { title = 'Teleport naar speler', icon = 'location-arrow', onSelect = function() TriggerServerEvent('delfzijlrp_admin:server:teleportToPlayer', player.id) end },
            { title = 'Breng speler naar mij', icon = 'person-walking-arrow-right', onSelect = function() TriggerServerEvent('delfzijlrp_admin:server:bringPlayer', player.id) end },
            { title = 'Heal speler', icon = 'heart-pulse', onSelect = function() TriggerServerEvent('delfzijlrp_admin:server:healPlayer', player.id) end },
            { title = 'Revive speler', icon = 'kit-medical', onSelect = function() TriggerServerEvent('delfzijlrp_admin:server:revivePlayer', player.id) end },
            { title = 'Freeze toggle', icon = 'snowflake', onSelect = function() TriggerServerEvent('delfzijlrp_admin:server:freezePlayer', player.id) end }
        }
    })

    lib.showContext('delfzijlrp_admin_player_actions')
end

local function openPlayers()
    local players = lib.callback.await('delfzijlrp_admin:server:getPlayers', false) or {}
    local options = {}

    for _, player in ipairs(players) do
        options[#options + 1] = {
            title = ('%s [%s]'):format(player.name, player.id),
            description = ('Group: %s'):format(player.group or 'user'),
            icon = 'user',
            onSelect = function() openPlayerActions(player) end
        }
    end

    lib.registerContext({ id = 'delfzijlrp_admin_players', title = 'Online spelers', options = options })
    lib.showContext('delfzijlrp_admin_players')
end

local function openVehicleTools()
    lib.registerContext({
        id = 'delfzijlrp_admin_vehicle_tools',
        title = 'Voertuigtools',
        options = {
            { title = 'Repareer voertuig', icon = 'screwdriver-wrench', onSelect = function()
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                if vehicle ~= 0 then
                    SetVehicleFixed(vehicle)
                    SetVehicleDirtLevel(vehicle, 0.0)
                    notify(Config.Text.actionDone, 'success')
                end
            end },
            { title = 'Maak voertuig schoon', icon = 'soap', onSelect = function()
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                if vehicle ~= 0 then
                    SetVehicleDirtLevel(vehicle, 0.0)
                    notify(Config.Text.actionDone, 'success')
                end
            end },
            { title = 'Verwijder voertuig', icon = 'trash', onSelect = function()
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                if vehicle == 0 then
                    local coords = GetEntityCoords(PlayerPedId())
                    vehicle = ESX.Game.GetClosestVehicle(coords)
                end
                if vehicle and vehicle ~= 0 then
                    DeleteEntity(vehicle)
                    notify(Config.Text.actionDone, 'success')
                end
            end }
        }
    })

    lib.showContext('delfzijlrp_admin_vehicle_tools')
end

local function openStaffMenu()
    local staff = lib.callback.await('delfzijlrp_admin:server:isStaff', false)
    if not staff then
        notify(Config.Text.noAccess, 'error')
        return
    end

    lib.registerContext({
        id = 'delfzijlrp_admin_main',
        title = 'Delfzijl RP Staffmenu',
        options = {
            { title = 'Reports', icon = 'flag', onSelect = openReports },
            { title = 'Online spelers', icon = 'users', onSelect = openPlayers },
            { title = 'Voertuigtools', icon = 'car', onSelect = openVehicleTools }
        }
    })

    lib.showContext('delfzijlrp_admin_main')
end

RegisterCommand(Config.Command, openStaffMenu, false)
RegisterCommand(Config.ReportCommand, function()
    local input = lib.inputDialog('Report maken', {
        { type = 'textarea', label = 'Wat is er aan de hand?', required = true, min = 3, max = 500 }
    })
    if input then
        TriggerServerEvent('delfzijlrp_admin:server:createReport', input[1])
    end
end, false)

RegisterNetEvent('delfzijlrp_admin:client:teleport', function(coords)
    SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, false, false, false, false)
end)

RegisterNetEvent('delfzijlrp_admin:client:heal', function()
    local ped = PlayerPedId()
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    ClearPedBloodDamage(ped)
end)

RegisterNetEvent('delfzijlrp_admin:client:setFrozen', function(state)
    FreezeEntityPosition(PlayerPedId(), state == true)
end)
