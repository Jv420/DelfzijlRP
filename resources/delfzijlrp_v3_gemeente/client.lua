local function request(kind)
    TriggerServerEvent('delfzijlrp_v3_gemeente:server:request', kind)
end

local function openMenu()
    lib.registerContext({
        id = 'drp_gemeente_main',
        title = 'Gemeente Delfzijl',
        options = {
            { title = 'ID-kaart aanvragen', description = '€' .. Config.Prices.idkaart, onSelect = function() request('idkaart') end },
            { title = 'Rijbewijs B aanvragen', description = '€' .. Config.Prices.rijbewijs, onSelect = function() request('rijbewijs') end },
            { title = 'Buskaartje kopen', description = '€' .. Config.Prices.buskaartje, onSelect = function() request('buskaartje') end },
            { title = 'Visvergunning aanvragen', description = '€' .. Config.Prices.visvergunning, onSelect = function() request('visvergunning') end },
            { title = 'Werkvergunning aanvragen', description = '€' .. Config.Prices.werkvergunning, onSelect = function() request('werkvergunning') end },
            { title = 'Uittreksel BRP aanvragen', description = '€' .. Config.Prices.uittreksel, onSelect = function() request('uittreksel') end },
            { title = 'Stadsinformatie', description = 'Delfzijl RP Living Netherlands', readOnly = true }
        }
    })
    lib.showContext('drp_gemeente_main')
end

CreateThread(function()
    Wait(1500)
    local loc = Config.Location
    if loc.blip then
        local blip = AddBlipForCoord(loc.coords.x, loc.coords.y, loc.coords.z)
        SetBlipSprite(blip, loc.blip.sprite)
        SetBlipColour(blip, loc.blip.color)
        SetBlipScale(blip, loc.blip.scale)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(loc.label)
        EndTextCommandSetBlipName(blip)
    end
    exports.ox_target:addSphereZone({
        coords = loc.coords,
        radius = loc.radius,
        debug = Config.Debug,
        options = {{ name = 'drp_gemeente_open', label = Config.Text.open, onSelect = openMenu }}
    })
end)

RegisterCommand(Config.Command, openMenu, false)
