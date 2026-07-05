local function notify(text, kind)
    lib.notify({ title = 'Delfzijl Shop', description = text, type = kind or 'inform' })
end

local function openShop(shop)
    local opts = {}
    for _, item in ipairs(shop.items or {}) do
        opts[#opts + 1] = {
            title = item.label,
            description = 'Prijs: €' .. item.price,
            onSelect = function()
                local input = lib.inputDialog(item.label, {
                    { type = 'number', label = 'Aantal', default = 1, required = true, min = 1, max = 25 }
                })
                if not input then return end
                local ok, msg = lib.callback.await('delfzijlrp_v2_shops:server:buyItem', false, shop.id, item.name, input[1])
                notify(msg or (ok and Config.Text.bought or Config.Text.invalid), ok and 'success' or 'error')
            end
        }
    end

    lib.registerContext({ id = 'drp_shop_' .. shop.id, title = shop.label, options = opts })
    lib.showContext('drp_shop_' .. shop.id)
end

CreateThread(function()
    Wait(1500)
    for i, shop in ipairs(Config.Shops) do
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
            options = {{ name = 'drp_shop_' .. i, label = Config.Text.open, onSelect = function() openShop(shop) end }}
        })
    end
end)

RegisterCommand(Config.Command, function()
    openShop(Config.Shops[1])
end, false)
