local function notify(message, type)
    lib.notify({ title = 'Delfzijl RP CrimePlus', description = message, type = type or 'inform' })
end

local function startIncident(incidentType, locationId, coords)
    local incident = Config.Incidents[incidentType]
    if not incident then return end

    local canStart, reason = lib.callback.await('delfzijlrp_crimeplus:server:canStart', false, incidentType, locationId)
    if not canStart then
        notify(reason or Config.Text.failed, 'error')
        return
    end

    local success = lib.progressCircle({
        duration = incident.duration,
        label = incident.label .. '...',
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = { car = true, move = true, combat = true },
        anim = { dict = 'missheistfbisetup1', clip = 'hassle_intro_loop_f' }
    })

    if not success then
        notify(Config.Text.cancelled, 'error')
        return
    end

    TriggerServerEvent('delfzijlrp_crimeplus:server:completeIncident', incidentType, locationId, coords)
end

CreateThread(function()
    Wait(1500)

    for incidentType, incident in pairs(Config.Incidents) do
        if incident.locations then
            for _, location in ipairs(incident.locations) do
                exports.ox_target:addSphereZone({
                    coords = location.coords,
                    radius = location.radius or 2.0,
                    debug = Config.Debug,
                    options = {
                        {
                            name = ('crimeplus_%s_%s'):format(incidentType, location.id),
                            icon = 'fa-solid fa-triangle-exclamation',
                            label = incident.label,
                            distance = 2.0,
                            onSelect = function()
                                startIncident(incidentType, location.id, { x = location.coords.x, y = location.coords.y, z = location.coords.z })
                            end
                        }
                    }
                })
            end
        end

        if incident.models then
            exports.ox_target:addModel(incident.models, {
                {
                    name = 'crimeplus_atm_incident',
                    icon = 'fa-solid fa-credit-card',
                    label = incident.label,
                    distance = 1.8,
                    onSelect = function(data)
                        local coords = GetEntityCoords(data.entity)
                        local locationId = ('atm_%s_%s'):format(math.floor(coords.x), math.floor(coords.y))
                        startIncident(incidentType, locationId, { x = coords.x, y = coords.y, z = coords.z })
                    end
                }
            })
        end
    end
end)
