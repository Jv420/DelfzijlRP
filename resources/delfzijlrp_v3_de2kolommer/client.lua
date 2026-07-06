local function askPlate(title, eventName)
    local input = lib.inputDialog(title, {
        { type = 'input', label = 'Kenteken/plaat', required = true }
    })
    if input then TriggerServerEvent(eventName, input[1]) end
end

local function openMenu()
    lib.registerContext({
        id = 'de2kolommer_main',
        title = 'De2Kolommer Delfzijl',
        options = {
            { title = 'APK keuren', description = '€' .. Config.Prices.apk, onSelect = function() askPlate('APK keuren', 'delfzijlrp_v3_de2kolommer:server:apk') end },
            { title = 'Repareren', description = '€' .. Config.Prices.repair, onSelect = function() askPlate('Repareren', 'delfzijlrp_v3_de2kolommer:server:repair') end },
            { title = 'Onderhoudsbeurt', description = '€' .. Config.Prices.service, onSelect = function() askPlate('Onderhoudsbeurt', 'delfzijlrp_v3_de2kolommer:server:service') end },
            { title = 'Tracker plaatsen', description = '€' .. Config.Prices.tracker, onSelect = function() askPlate('Tracker plaatsen', 'delfzijlrp_v3_de2kolommer:server:tracker') end },
            { title = 'Sleepdienst', description = 'Binnenkort: melding en sleepwagens', readOnly = true }
        }
    })
    lib.showContext('de2kolommer_main')
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
        options = {{ name = 'de2kolommer_open', label = Config.Text.open, onSelect = openMenu }}
    })
end)

RegisterCommand(Config.Command, openMenu, false)
