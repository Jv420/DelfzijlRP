local function openMenu()
    local opts = {}
    for _, car in ipairs(Config.Cars) do
        opts[#opts + 1] = {
            title = car.label,
            description = '€' .. car.price,
            onSelect = function()
                lib.registerContext({
                    id = 'lux_dealer_car_' .. car.model,
                    title = car.label,
                    menu = 'lux_dealer_main',
                    options = {
                        { title = 'Kopen', description = 'Bankbetaling + registratie', onSelect = function() TriggerServerEvent('delfzijlrp_v3_lux_dealer:server:buy', car.model) end },
                        { title = 'Proefrit', description = Config.Text.testdrive, readOnly = true },
                        { title = 'Lease / financiering', description = 'Binnenkort beschikbaar', readOnly = true }
                    }
                })
                lib.showContext('lux_dealer_car_' .. car.model)
            end
        }
    end
    lib.registerContext({ id = 'lux_dealer_main', title = 'Piricars Showroom', options = opts })
    lib.showContext('lux_dealer_main')
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
        options = {{ name = 'lux_dealer_open', label = Config.Text.open, onSelect = openMenu }}
    })
end)

RegisterCommand(Config.Command, openMenu, false)
