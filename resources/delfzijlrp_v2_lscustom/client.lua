local ESX = exports['es_extended']:getSharedObject()

local function msg(text, kind)
    lib.notify({ title = 'LS Customs', description = text, type = kind or 'inform' })
end

local function plate(vehicle)
    return GetVehicleNumberPlateText(vehicle):gsub('^%s*(.-)%s*$', '%1'):upper()
end

local function driverVehicle()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh == 0 or GetPedInVehicleSeat(veh, -1) ~= ped then
        msg(Config.Text.noVehicle, 'error')
        return nil
    end
    return veh
end

local function save(veh)
    local props = ESX.Game.GetVehicleProperties(veh)
    props.plate = plate(veh)
    local ok, text = lib.callback.await('delfzijlrp_v2_lscustom:server:saveVehicle', false, props.plate, props)
    msg(text or Config.Text.saved, ok and 'success' or 'error')
end

local function pay(price)
    local ok = lib.callback.await('delfzijlrp_v2_lscustom:server:pay', false, price)
    if not ok then msg(Config.Text.noMoney, 'error') end
    return ok
end

local function applyMod(veh, modType, modIndex, price)
    if not pay(price) then return end
    SetVehicleModKit(veh, 0)
    SetVehicleMod(veh, modType, modIndex, false)
    save(veh)
    msg(Config.Text.paid, 'success')
end

local function colorMenu(veh)
    local opts = {}
    for _, c in ipairs(Config.Colors) do
        opts[#opts + 1] = {
            title = c.label,
            description = 'Prijs: ' .. Config.Prices.color,
            onSelect = function()
                if not pay(Config.Prices.color) then return end
                SetVehicleColours(veh, c.primary, c.secondary)
                save(veh)
                msg(Config.Text.paid, 'success')
            end
        }
    end
    lib.registerContext({ id = 'drp_lsc_color', title = 'Kleur kiezen', options = opts })
    lib.showContext('drp_lsc_color')
end

local function openMenu()
    local veh = driverVehicle()
    if not veh then return end

    lib.registerContext({
        id = 'drp_lsc_main',
        title = 'LS Customs Delfzijl',
        options = {
            { title = 'Repareren', description = 'Prijs: ' .. Config.Prices.repair, onSelect = function()
                if not pay(Config.Prices.repair) then return end
                SetVehicleFixed(veh)
                SetVehicleDeformationFixed(veh)
                SetVehicleEngineHealth(veh, 1000.0)
                SetVehicleBodyHealth(veh, 1000.0)
                save(veh)
                msg(Config.Text.paid, 'success')
            end },
            { title = 'Wassen', description = 'Prijs: ' .. Config.Prices.clean, onSelect = function()
                if not pay(Config.Prices.clean) then return end
                SetVehicleDirtLevel(veh, 0.0)
                save(veh)
                msg(Config.Text.paid, 'success')
            end },
            { title = 'Motor 1', description = 'Prijs: ' .. Config.Prices.engine1, onSelect = function() applyMod(veh, 11, 0, Config.Prices.engine1) end },
            { title = 'Motor 2', description = 'Prijs: ' .. Config.Prices.engine2, onSelect = function() applyMod(veh, 11, 1, Config.Prices.engine2) end },
            { title = 'Remmen 1', description = 'Prijs: ' .. Config.Prices.brakes1, onSelect = function() applyMod(veh, 12, 0, Config.Prices.brakes1) end },
            { title = 'Remmen 2', description = 'Prijs: ' .. Config.Prices.brakes2, onSelect = function() applyMod(veh, 12, 1, Config.Prices.brakes2) end },
            { title = 'Transmissie 1', description = 'Prijs: ' .. Config.Prices.transmission1, onSelect = function() applyMod(veh, 13, 0, Config.Prices.transmission1) end },
            { title = 'Transmissie 2', description = 'Prijs: ' .. Config.Prices.transmission2, onSelect = function() applyMod(veh, 13, 1, Config.Prices.transmission2) end },
            { title = 'Kleur wijzigen', description = 'Prijs: ' .. Config.Prices.color, onSelect = function() colorMenu(veh) end },
            { title = 'Opslaan', onSelect = function() save(veh) end }
        }
    })
    lib.showContext('drp_lsc_main')
end

CreateThread(function()
    Wait(1500)
    for i, loc in ipairs(Config.Locations) do
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
            options = {{ name = 'drp_lsc_' .. i, label = Config.Text.open, onSelect = openMenu }}
        })
    end
end)

RegisterCommand(Config.Command, openMenu, false)
