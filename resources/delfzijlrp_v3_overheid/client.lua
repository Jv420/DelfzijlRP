local function openMain()
    lib.registerContext({
        id = 'drp_ov_main',
        title = 'Delfzijl Overheid',
        options = {
            { title = 'Gemeente', description = 'Burgerzaken en documenten', onSelect = function() ExecuteCommand('gemeente') end },
            { title = 'RDW', description = 'Voertuigen en kentekens', onSelect = function() ExecuteCommand('rdw') end },
            { title = 'KVK', description = 'Bedrijven', onSelect = function() ExecuteCommand('kvk') end },
            { title = 'Kadaster', description = 'Woningen en vastgoed', onSelect = function() ExecuteCommand('kadaster') end },
            { title = 'Belastingdienst', description = 'Binnenkort beschikbaar', readOnly = true },
            { title = 'CJIB', description = 'Binnenkort beschikbaar', readOnly = true }
        }
    })
    lib.showContext('drp_ov_main')
end

CreateThread(function()
    Wait(1500)
    local loc = Config.Location
    if loc.blip then
        local b = AddBlipForCoord(loc.coords.x, loc.coords.y, loc.coords.z)
        SetBlipSprite(b, loc.blip.sprite)
        SetBlipColour(b, loc.blip.color)
        SetBlipScale(b, loc.blip.scale)
        SetBlipAsShortRange(b, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(loc.label)
        EndTextCommandSetBlipName(b)
    end
    exports.ox_target:addSphereZone({
        coords = loc.coords,
        radius = loc.radius,
        debug = Config.Debug,
        options = {{ name = 'drp_ov_open', label = Config.Text.open, onSelect = openMain }}
    })
end)

RegisterCommand(Config.Commands.overheid, openMain, false)
