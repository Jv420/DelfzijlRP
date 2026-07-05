local function msg(text, kind)
    lib.notify({ title = 'Delfzijl Toegang', description = text, type = kind or 'inform' })
end

local function teleportPed(target)
    local ped = PlayerPedId()
    DoScreenFadeOut(350)
    Wait(450)
    SetEntityCoords(ped, target.x, target.y, target.z, false, false, false, false)
    SetEntityHeading(ped, target.w or 0.0)
    Wait(250)
    DoScreenFadeIn(350)
    msg(Config.Text.teleported, 'success')
end

local function teleportVehicle(target)
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh == 0 then
        teleportPed(target)
        return
    end
    DoScreenFadeOut(350)
    Wait(450)
    SetEntityCoords(veh, target.x, target.y, target.z, false, false, false, false)
    SetEntityHeading(veh, target.w or 0.0)
    SetVehicleOnGroundProperly(veh)
    Wait(250)
    DoScreenFadeIn(350)
    msg(Config.Text.teleported, 'success')
end

local function openAccessMenu()
    local options = {}
    for _, p in ipairs(Config.Points) do
        options[#options + 1] = {
            title = p.label,
            description = Config.Text.enter,
            onSelect = function() teleportPed(p.inside) end
        }
    end
    for _, p in ipairs(Config.VehiclePoints) do
        options[#options + 1] = {
            title = p.label,
            description = Config.Text.vehicleEnter,
            onSelect = function() teleportVehicle(p.inside) end
        }
    end
    lib.registerContext({ id = 'delfzijlrp_access_main', title = Config.Text.menu, options = options })
    lib.showContext('delfzijlrp_access_main')
end

CreateThread(function()
    Wait(1500)

    for i, p in ipairs(Config.Points) do
        exports.ox_target:addSphereZone({
            coords = vector3(p.outside.x, p.outside.y, p.outside.z),
            radius = p.radius,
            debug = Config.Debug,
            options = {{ name = 'access_in_' .. p.id, label = p.label .. ' - ' .. Config.Text.enter, onSelect = function() teleportPed(p.inside) end }}
        })
        exports.ox_target:addSphereZone({
            coords = vector3(p.inside.x, p.inside.y, p.inside.z),
            radius = p.radius,
            debug = Config.Debug,
            options = {{ name = 'access_out_' .. p.id, label = p.label .. ' - ' .. Config.Text.exit, onSelect = function() teleportPed(p.outside) end }}
        })
    end

    for i, p in ipairs(Config.VehiclePoints) do
        exports.ox_target:addSphereZone({
            coords = vector3(p.outside.x, p.outside.y, p.outside.z),
            radius = p.radius,
            debug = Config.Debug,
            options = {{ name = 'access_vehicle_in_' .. p.id, label = p.label .. ' - ' .. Config.Text.vehicleEnter, onSelect = function() teleportVehicle(p.inside) end }}
        })
        exports.ox_target:addSphereZone({
            coords = vector3(p.inside.x, p.inside.y, p.inside.z),
            radius = p.radius,
            debug = Config.Debug,
            options = {{ name = 'access_vehicle_out_' .. p.id, label = p.label .. ' - ' .. Config.Text.vehicleExit, onSelect = function() teleportVehicle(p.outside) end }}
        })
    end
end)

RegisterCommand(Config.Command, openAccessMenu, false)
