local ESX = exports['es_extended']:getSharedObject()
local previewVehicle = nil

local function notify(message, type)
    lib.notify({ title = 'Delfzijl Dealer', description = message, type = type or 'inform' })
end

local function clearPreview()
    if previewVehicle and DoesEntityExist(previewVehicle) then DeleteEntity(previewVehicle) end
    previewVehicle = nil
end

local function spawnPreview(model)
    clearPreview()
    local hash = joaat(model)
    lib.requestModel(hash)
    local p = Config.Shop.preview
    previewVehicle = CreateVehicle(hash, p.x, p.y, p.z, p.w, false, false)
    SetVehicleDoorsLocked(previewVehicle, 2)
    FreezeEntityPosition(previewVehicle, true)
    SetEntityInvincible(previewVehicle, true)
    SetModelAsNoLongerNeeded(hash)
end

local function spawnBought(model, data)
    local hash = joaat(model)
    lib.requestModel(hash)
    local s = Config.Shop.spawn
    local vehicle = CreateVehicle(hash, s.x, s.y, s.z, s.w, true, false)
    if data and data.props then ESX.Game.SetVehicleProperties(vehicle, data.props) end
    SetVehicleNumberPlateText(vehicle, data.plate)
    SetVehicleOnGroundProperly(vehicle)
    SetPedIntoVehicle(PlayerPedId(), vehicle, -1)
    SetModelAsNoLongerNeeded(hash)
end

local function buyVehicle(vehicle)
    local input = lib.alertDialog({
        header = 'Voertuig kopen',
        content = ('%s kopen voor €%s?\n\nRDW-kenteken wordt automatisch aangemaakt.'):format(vehicle.label, vehicle.price),
        centered = true,
        cancel = true
    })
    if input ~= 'confirm' then return end

    local props = { model = joaat(vehicle.model) }
    local ok, result = lib.callback.await('delfzijlrp_v2_dealer:server:buyVehicle', false, vehicle.model, props)
    if not ok then notify(result or Config.Text.invalid, 'error') return end
    clearPreview()
    spawnBought(vehicle.model, result)
end

local function openCategory(category)
    local options = {}
    for _, vehicle in ipairs(Config.Vehicles) do
        if vehicle.category == category then
            options[#options + 1] = {
                title = vehicle.label,
                description = '€' .. vehicle.price,
                icon = 'car',
                onSelect = function()
                    spawnPreview(vehicle.model)
                    lib.registerContext({
                        id = 'delfzijlrp_v2_dealer_vehicle',
                        title = vehicle.label,
                        menu = 'delfzijlrp_v2_dealer_' .. category,
                        options = {
                            { title = 'Voorbeeld bekijken', icon = 'eye', onSelect = function() spawnPreview(vehicle.model) end },
                            { title = 'Kopen + RDW registreren', icon = 'cart-shopping', onSelect = function() buyVehicle(vehicle) end }
                        }
                    })
                    lib.showContext('delfzijlrp_v2_dealer_vehicle')
                end
            }
        end
    end
    lib.registerContext({ id = 'delfzijlrp_v2_dealer_' .. category, title = Config.Categories[category], menu = 'delfzijlrp_v2_dealer_main', options = options })
    lib.showContext('delfzijlrp_v2_dealer_' .. category)
end

local function openDealer()
    local options = {}
    for id, label in pairs(Config.Categories) do
        options[#options + 1] = { title = label, icon = 'car-side', onSelect = function() openCategory(id) end }
    end
    options[#options + 1] = { title = 'Preview sluiten', icon = 'xmark', onSelect = clearPreview }
    lib.registerContext({ id = 'delfzijlrp_v2_dealer_main', title = Config.Shop.label, options = options })
    lib.showContext('delfzijlrp_v2_dealer_main')
end

CreateThread(function()
    Wait(1500)
    if Config.Shop.blip then
        local blip = AddBlipForCoord(Config.Shop.coords.x, Config.Shop.coords.y, Config.Shop.coords.z)
        SetBlipSprite(blip, Config.Shop.blip.sprite)
        SetBlipColour(blip, Config.Shop.blip.color)
        SetBlipScale(blip, Config.Shop.blip.scale)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(Config.Shop.label)
        EndTextCommandSetBlipName(blip)
    end
    exports.ox_target:addSphereZone({
        coords = Config.Shop.coords,
        radius = Config.Shop.radius,
        debug = Config.Debug,
        options = {{ name = 'delfzijlrp_v2_dealer_open', icon = 'fa-solid fa-car', label = Config.Text.open, onSelect = openDealer }}
    })
end)

RegisterCommand(Config.Command, openDealer, false)
AddEventHandler('onResourceStop', function(resource) if resource == GetCurrentResourceName() then clearPreview() end end)
