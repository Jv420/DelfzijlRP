local spawnedPeds = {}

local function debugPrint(message)
    if Config.Debug then
        print(('[delfzijlrp_shops] %s'):format(message))
    end
end

local function loadModel(model)
    local hash = joaat(model)

    if not IsModelInCdimage(hash) then
        print(('[delfzijlrp_shops] Ongeldig ped model: %s'):format(model))
        return nil
    end

    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(50)
    end

    return hash
end

local function createShopBlip(shop, coords)
    if not Config.UseBlips or not shop.blip then return end

    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, shop.blip.sprite or 52)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, shop.blip.scale or 0.75)
    SetBlipColour(blip, shop.blip.color or 2)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(shop.label)
    EndTextCommandSetBlipName(blip)
end

local function createShopPed(shopType, shop, coords)
    if not Config.UsePeds then return end

    local model = shop.ped or Config.PedModel
    local hash = loadModel(model)
    if not hash then return end

    local ped = CreatePed(0, hash, coords.x, coords.y, coords.z - 1.0, coords.w, false, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)

    table.insert(spawnedPeds, ped)

    exports.ox_target:addLocalEntity(ped, {
        {
            name = ('delfzijlrp_shop_%s'):format(shopType),
            icon = shop.icon or 'fa-solid fa-shop',
            label = ('Open %s'):format(shop.label),
            distance = 2.0,
            groups = shop.job,
            onSelect = function()
                exports.ox_inventory:openInventory('shop', { type = shopType })
            end
        }
    })

    SetModelAsNoLongerNeeded(hash)
end

CreateThread(function()
    Wait(1500)

    for shopType, shop in pairs(Config.Shops) do
        for _, coords in ipairs(shop.locations) do
            createShopBlip(shop, coords)
            createShopPed(shopType, shop, coords)
            debugPrint(('Shop geladen: %s'):format(shopType))
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    for _, ped in ipairs(spawnedPeds) do
        if DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
    end
end)
