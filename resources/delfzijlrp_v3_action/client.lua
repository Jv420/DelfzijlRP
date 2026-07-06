local function openShop()
    local opts = {}
    for _, p in ipairs(Config.Products) do
        opts[#opts + 1] = {
            title = p.label,
            description = '€' .. p.price,
            onSelect = function()
                local input = lib.inputDialog(p.label, {
                    { type = 'number', label = 'Aantal', required = true, min = 1, default = 1 }
                })
                if input then TriggerServerEvent('delfzijlrp_v3_action:server:buy', p.item, input[1]) end
            end
        }
    end
    lib.registerContext({ id = 'drp_action_shop', title = 'Action Delfzijl', options = opts })
    lib.showContext('drp_action_shop')
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
        options = {{ name = 'drp_action_open', label = Config.Text.open, onSelect = openShop }}
    })
end)

RegisterCommand(Config.Command, openShop, false)
