local blackMarketPed = nil
local searchedVehicles = {}

local function notify(description, type)
    lib.notify({
        title = 'Delfzijl RP',
        description = description,
        type = type or 'inform'
    })
end

local function loadModel(model)
    local hash = joaat(model)

    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(50)
    end

    return hash
end

local function setupBlackMarket()
    if not Config.BlackMarket.enabled then return end

    local cfg = Config.BlackMarket
    local coords = cfg.location
    local model = loadModel(cfg.ped)

    blackMarketPed = CreatePed(0, model, coords.x, coords.y, coords.z - 1.0, coords.w, false, true)
    SetEntityInvincible(blackMarketPed, true)
    SetBlockingOfNonTemporaryEvents(blackMarketPed, true)
    FreezeEntityPosition(blackMarketPed, true)

    exports.ox_target:addLocalEntity(blackMarketPed, {
        {
            name = 'delfzijlrp_blackmarket_open',
            icon = cfg.icon,
            label = ('Open %s'):format(cfg.label),
            distance = 2.0,
            onSelect = function()
                exports.ox_inventory:openInventory('shop', { type = 'delfzijlrp_blackmarket' })
            end
        }
    })

    SetModelAsNoLongerNeeded(model)
end

local function getVehicleKey(vehicle)
    local plate = GetVehicleNumberPlateText(vehicle)
    return plate and plate:gsub('%s+', '') or tostring(vehicle)
end

local function trySearchVehicle(vehicle)
    if not Config.VehicleTheft.enabled then return end
    if not vehicle or vehicle == 0 then
        notify(Config.Notifications.noVehicle, 'error')
        return
    end

    local key = getVehicleKey(vehicle)
    if searchedVehicles[key] and searchedVehicles[key] > GetGameTimer() then
        notify(Config.Notifications.alreadySearched, 'error')
        return
    end

    local hasItem = lib.callback.await('delfzijlrp_crime:server:hasLockpick', false)
    if not hasItem then
        notify(Config.Notifications.noItem, 'error')
        return
    end

    local success = lib.progressCircle({
        duration = Config.VehicleTheft.searchDuration,
        label = 'Voertuig doorzoeken...',
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true
        },
        anim = {
            dict = 'mini@repair',
            clip = 'fixing_a_ped'
        }
    })

    if not success then
        notify(Config.Notifications.cancelled, 'error')
        return
    end

    searchedVehicles[key] = GetGameTimer() + 20 * 60 * 1000
    TriggerServerEvent('delfzijlrp_crime:server:searchVehicle', VehToNet(vehicle), GetEntityCoords(PlayerPedId()))
end

CreateThread(function()
    Wait(1500)
    setupBlackMarket()

    exports.ox_target:addGlobalVehicle({
        {
            name = 'delfzijlrp_search_vehicle',
            icon = 'fa-solid fa-car-side',
            label = 'Voertuig doorzoeken',
            distance = 2.0,
            bones = { 'boot', 'door_dside_f', 'door_pside_f' },
            onSelect = function(data)
                trySearchVehicle(data.entity)
            end
        }
    })
end)

RegisterNetEvent('delfzijlrp_crime:client:policeAlert', function(coords)
    if not coords then return end

    -- Later koppelen aan dispatch/phone. Voor nu alleen lokale notificatie voor politiejobs via serverevent mogelijk.
    notify(Config.Notifications.policeAlert, 'warning')
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    if blackMarketPed and DoesEntityExist(blackMarketPed) then
        DeleteEntity(blackMarketPed)
    end
end)
