local function msg(text, kind)
    lib.notify({ title = 'Action Delfzijl', description = text, type = kind or 'inform' })
end

local function openShop()
    local options = {}
    for _, item in ipairs(Config.Items) do
        options[#options + 1] = {
            title = item.label,
            description = 'Prijs: €' .. item.price,
            onSelect = function()
                local input = lib.inputDialog(item.label, {
                    { type = 'number', label = 'Aantal', default = 1, required = true, min = 1, max = 25 }
                })
                if not input then return end
                local ok, text = lib.callback.await('delfzijlrp_v2_action:server:buy', false, item.name, input[1])
                msg(text or Config.Text.invalid, ok and 'success' or 'error')
            end
        }
    end
    lib.registerContext({ id = 'delfzijlrp_action_shop', title = Config.Shop.label, options = options })
    lib.showContext('delfzijlrp_action_shop')
end

CreateThread(function()
    Wait(1500)
    local shop = Config.Shop
    if shop.blip then
        local blip = AddBlipForCoord(shop.coords.x, shop.coords.y, shop.coords.z)
        SetBlipSprite(blip, shop.blip.sprite)
        SetBlipColour(blip, shop.blip.color)
        SetBlipScale(blip, shop.blip.scale)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(shop.label)
        EndTextCommandSetBlipName(blip)
    end
    exports.ox_target:addSphereZone({
        coords = shop.coords,
        radius = shop.radius,
        debug = Config.Debug,
        options = {{ name = 'delfzijlrp_action_open', label = Config.Text.open, onSelect = openShop }}
    })
end)

RegisterCommand(Config.Command, openShop, false)
