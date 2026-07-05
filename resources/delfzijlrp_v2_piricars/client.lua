local ESX = exports['es_extended']:getSharedObject()
local preview = nil

local function msg(text, kind)
    lib.notify({ title = 'Piricars', description = text, type = kind or 'inform' })
end

local function clearPreview()
    if preview and DoesEntityExist(preview) then DeleteEntity(preview) end
    preview = nil
end

local function showPreview(model)
    clearPreview()
    local hash = joaat(model)
    lib.requestModel(hash)
    local p = Config.Shop.preview
    preview = CreateVehicle(hash, p.x, p.y, p.z, p.w, false, false)
    SetVehicleDoorsLocked(preview, 2)
    FreezeEntityPosition(preview, true)
    SetEntityInvincible(preview, true)
    SetModelAsNoLongerNeeded(hash)
end

local function spawnBought(model, data)
    local hash = joaat(model)
    lib.requestModel(hash)
    local s = Config.Shop.spawn
    local veh = CreateVehicle(hash, s.x, s.y, s.z, s.w, true, false)
    if data and data.props then ESX.Game.SetVehicleProperties(veh, data.props) end
    SetVehicleNumberPlateText(veh, data.plate)
    SetVehicleOnGroundProperly(veh)
    SetPedIntoVehicle(PlayerPedId(), veh, -1)
    SetModelAsNoLongerNeeded(hash)
end

local function buy(vehicle)
    local answer = lib.alertDialog({
        header = vehicle.label,
        content = 'Kopen voor €' .. vehicle.price .. '? RDW registreert automatisch een kenteken.',
        centered = true,
        cancel = true
    })
    if answer ~= 'confirm' then return end

    local ok, result = lib.callback.await('delfzijlrp_v2_piricars:server:buyVehicle', false, vehicle.model, { model = joaat(vehicle.model) })
    if not ok then msg(result or Config.Text.invalid, 'error') return end
    clearPreview()
    spawnBought(vehicle.model, result)
    msg(Config.Text.bought .. ' Kenteken: ' .. result.plate, 'success')
end

local function openMenu()
    local opts = {}
    for _, vehicle in ipairs(Config.Vehicles) do
        opts[#opts + 1] = {
            title = vehicle.label,
            description = 'Prijs: €' .. vehicle.price,
            onSelect = function()
                showPreview(vehicle.model)
                lib.registerContext({
                    id = 'piricars_vehicle',
                    title = vehicle.label,
                    menu = 'piricars_main',
                    options = {
                        { title = 'Voorbeeld bekijken', onSelect = function() showPreview(vehicle.model) end },
                        { title = 'Kopen + RDW registreren', onSelect = function() buy(vehicle) end }
                    }
                })
                lib.showContext('piricars_vehicle')
            end
        }
    end
    opts[#opts + 1] = { title = 'Preview sluiten', onSelect = clearPreview }
    lib.registerContext({ id = 'piricars_main', title = Config.Shop.label, options = opts })
    lib.showContext('piricars_main')
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
        options = {{ name = 'piricars_open', label = Config.Text.open, onSelect = openMenu }}
    })
end)

RegisterCommand(Config.Command, openMenu, false)
AddEventHandler('onResourceStop', function(res) if res == GetCurrentResourceName() then clearPreview() end end)
