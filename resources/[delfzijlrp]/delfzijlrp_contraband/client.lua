local function notify(description, type)
    lib.notify({
        title = 'Delfzijl RP',
        description = description,
        type = type or 'inform'
    })
end

local function doZoneAction(zoneType)
    local zone = Config.Zones[zoneType]
    if not zone then return end

    local success = lib.progressCircle({
        duration = zone.duration,
        label = zone.label .. '...',
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true
        },
        anim = {
            dict = 'amb@prop_human_bum_bin@base',
            clip = 'base'
        }
    })

    if not success then
        notify(Config.Notifications.cancelled, 'error')
        return
    end

    TriggerServerEvent('delfzijlrp_contraband:server:completeAction', zoneType)
end

CreateThread(function()
    Wait(1500)

    for zoneType, zone in pairs(Config.Zones) do
        exports.ox_target:addSphereZone({
            coords = zone.coords,
            radius = zone.radius,
            debug = Config.Debug,
            options = {
                {
                    name = ('delfzijlrp_contraband_%s'):format(zoneType),
                    icon = zone.icon,
                    label = zone.label,
                    distance = 2.0,
                    onSelect = function()
                        doZoneAction(zoneType)
                    end
                }
            }
        })
    end
end)

RegisterNetEvent('delfzijlrp_contraband:client:policeAlert', function(coords)
    notify(Config.Notifications.policeAlert, 'warning')
end)
