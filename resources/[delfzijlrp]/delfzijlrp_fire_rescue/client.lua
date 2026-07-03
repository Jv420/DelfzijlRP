local function notify(message, type)
    lib.notify({ title = 'Brandweer Delfzijl', description = message, type = type or 'inform' })
end

local function isFire()
    local ok = lib.callback.await('delfzijlrp_fire_rescue:server:isFire', false)
    if not ok then notify(Config.Text.noAccess, 'error') end
    return ok
end

local function spawnVehicle(station, model)
    if not isFire() then return end
    local hash = joaat(model)
    lib.requestModel(hash)
    local spawn = station.spawn
    local vehicle = CreateVehicle(hash, spawn.x, spawn.y, spawn.z, spawn.w, true, false)
    SetPedIntoVehicle(PlayerPedId(), vehicle, -1)
    SetVehicleEngineOn(vehicle, true, true, false)
    SetVehicleLivery(vehicle, 0)
    SetModelAsNoLongerNeeded(hash)
end

local function openGarage(station)
    local options = {}
    for _, vehicle in ipairs(Config.Vehicles) do
        options[#options + 1] = {
            title = vehicle.label,
            icon = 'truck-medical',
            onSelect = function() spawnVehicle(station, vehicle.model) end
        }
    end
    lib.registerContext({ id = 'delfzijlrp_fire_garage', title = 'Brandweer Garage', options = options })
    lib.showContext('delfzijlrp_fire_garage')
end

local function incidentOptions()
    local options = {}
    for incidentType, incident in pairs(Config.Incidents) do
        for _, location in ipairs(incident.locations or {}) do
            options[#options + 1] = {
                title = incident.label,
                description = location.id,
                icon = 'fire-flame-curved',
                onSelect = function()
                    SetNewWaypoint(location.coords.x, location.coords.y)
                    TriggerServerEvent('delfzijlrp_fire_rescue:server:startIncident', incidentType, location.id, { x = location.coords.x, y = location.coords.y, z = location.coords.z })
                end
            }
        end
    end
    return options
end

local function completeActiveIncident()
    if not isFire() then return end
    local active = lib.callback.await('delfzijlrp_fire_rescue:server:getActiveIncident', false)
    if not active then notify(Config.Text.noIncident, 'error') return end

    local incident = Config.Incidents[active.incident_type]
    local success = lib.progressCircle({
        duration = incident and incident.duration or 10000,
        label = 'Incident veiligstellen...',
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = { car = true, move = true, combat = true },
        anim = { dict = 'amb@world_human_welding@male@base', clip = 'base' }
    })

    if success then
        TriggerServerEvent('delfzijlrp_fire_rescue:server:completeIncident', active.id)
    end
end

local function openFireMenu()
    if not isFire() then return end
    local stats = lib.callback.await('delfzijlrp_fire_rescue:server:getStats', false)
    lib.registerContext({
        id = 'delfzijlrp_fire_menu',
        title = 'Brandweer Delfzijl',
        options = {
            { title = 'Meldkamer openen', icon = 'tower-broadcast', onSelect = function() ExecuteCommand('meldkamer') end },
            { title = 'Nieuw incident kiezen', icon = 'fire', onSelect = function()
                lib.registerContext({ id = 'delfzijlrp_fire_incidents', title = 'Incidenten', options = incidentOptions() })
                lib.showContext('delfzijlrp_fire_incidents')
            end },
            { title = 'Actief incident afronden', icon = 'check', onSelect = completeActiveIncident },
            { title = 'Statistieken', description = stats and ('Incidenten: %s | Verdiend: €%s'):format(stats.incidents, stats.earned) or 'Geen data', icon = 'chart-line', readOnly = true }
        }
    })
    lib.showContext('delfzijlrp_fire_menu')
end

local function handleIncidentPoint(incidentType, location)
    if not isFire() then return end
    local active = lib.callback.await('delfzijlrp_fire_rescue:server:getActiveIncident', false)
    if not active or active.location_id ~= location.id then
        notify(Config.Text.noIncident, 'error')
        return
    end
    completeActiveIncident()
end

CreateThread(function()
    Wait(1500)

    for _, station in ipairs(Config.Stations) do
        if station.blip then
            local blip = AddBlipForCoord(station.duty.x, station.duty.y, station.duty.z)
            SetBlipSprite(blip, station.blip.sprite)
            SetBlipColour(blip, station.blip.color)
            SetBlipScale(blip, station.blip.scale)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(station.label)
            EndTextCommandSetBlipName(blip)
        end

        exports.ox_target:addSphereZone({
            coords = station.duty,
            radius = 1.5,
            debug = Config.Debug,
            options = {{ name = 'fire_duty_' .. station.id, icon = 'fa-solid fa-fire-extinguisher', label = Config.Text.duty, onSelect = function() TriggerServerEvent('delfzijlrp_fire_rescue:server:toggleDuty') end }}
        })

        exports.ox_target:addSphereZone({
            coords = station.garage,
            radius = 2.0,
            debug = Config.Debug,
            options = {{ name = 'fire_garage_' .. station.id, icon = 'fa-solid fa-truck', label = Config.Text.garage, onSelect = function() openGarage(station) end }}
        })

        exports.ox_target:addSphereZone({
            coords = station.storage,
            radius = 1.5,
            debug = Config.Debug,
            options = {{ name = 'fire_storage_' .. station.id, icon = 'fa-solid fa-box-archive', label = Config.Text.storage, onSelect = function() TriggerServerEvent('delfzijlrp_fire_rescue:server:openStorage', station.id) end }}
        })
    end

    for incidentType, incident in pairs(Config.Incidents) do
        for _, location in ipairs(incident.locations or {}) do
            exports.ox_target:addSphereZone({
                coords = location.coords,
                radius = location.radius or 3.0,
                debug = Config.Debug,
                options = {{ name = 'fire_incident_' .. location.id, icon = 'fa-solid fa-fire', label = incident.label .. ' afhandelen', onSelect = function() handleIncidentPoint(incidentType, location) end }}
            })
        end
    end
end)

RegisterCommand(Config.Command, openFireMenu, false)

RegisterNetEvent('delfzijlrp_fire_rescue:client:openStash', function(stashId)
    exports.ox_inventory:openInventory('stash', stashId)
end)
