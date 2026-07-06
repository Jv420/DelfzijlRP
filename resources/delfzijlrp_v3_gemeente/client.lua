local function request(kind)
    TriggerServerEvent('delfzijlrp_v3_gemeente:server:request', kind)
end

local function item(title, kind)
    return { title = title, description = '€' .. Config.Prices[kind], onSelect = function() request(kind) end }
end

local function openMenu()
    lib.registerContext({
        id = 'drp_gemeente_main',
        title = 'Gemeente Delfzijl',
        options = {
            item('ID-kaart aanvragen', 'idkaart'),
            item('Paspoort aanvragen', 'paspoort'),
            item('Rijbewijs B aanvragen', 'rijbewijs'),
            item('Motorrijbewijs A aanvragen', 'motorrijbewijs'),
            item('Vrachtwagenrijbewijs C aanvragen', 'vrachtwagenrijbewijs'),
            item('Busrijbewijs D aanvragen', 'busrijbewijs'),
            item('Vaarbewijs aanvragen', 'vaarbewijs'),
            item('Buskaartje kopen', 'buskaartje'),
            item('Visvergunning aanvragen', 'visvergunning'),
            item('Werkvergunning aanvragen', 'werkvergunning'),
            item('Bouwvergunning aanvragen', 'bouwvergunning'),
            item('Marktvergunning aanvragen', 'marktvergunning'),
            item('Uittreksel BRP aanvragen', 'uittreksel'),
            item('Geboorteakte aanvragen', 'geboorteakte'),
            item('Verhuisverklaring aanvragen', 'verhuisverklaring'),
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
