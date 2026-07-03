CreateThread(function()
    Wait(1000)

    for shopType, shop in pairs(Config.Shops) do
        exports.ox_inventory:RegisterShop(shopType, {
            name = shop.label,
            inventory = shop.items,
            locations = shop.locations,
            groups = shop.job
        })

        print(('[delfzijlrp_shops] Shop geregistreerd: %s'):format(shop.label))
    end
end)
