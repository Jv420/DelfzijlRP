local function msg(text, kind)
    lib.notify({ title = 'De2Kolommer', description = text, type = kind or 'inform' })
end

local function closestVehicle()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh ~= 0 then return veh end
    local coords = GetEntityCoords(ped)
    veh = GetClosestVehicle(coords.x, coords.y, coords.z, 6.0, 0, 71)
    if veh == 0 then msg(Config.Text.noVehicle, 'error') return nil end
    return veh
end

local function plate(veh)
    return GetVehicleNumberPlateText(veh):gsub('^%s*(.-)%s*$', '%1'):upper()
end

local function pay(price)
    local ok = lib.callback.await('delfzijlrp_v2_kolommer:server:pay', false, price)
    if not ok then msg(Config.Text.noMoney, 'error') end
    return ok
end

local function repair()
    local veh = closestVehicle()
    if not veh then return end
    if not pay(Config.Prices.repair) then return end
    lib.progressCircle({ duration = 6500, label = 'Voertuig repareren...', position = 'bottom', canCancel = true })
    SetVehicleFixed(veh)
    SetVehicleDeformationFixed(veh)
    SetVehicleEngineHealth(veh, 1000.0)
    SetVehicleBodyHealth(veh, 1000.0)
    msg(Config.Text.repaired, 'success')
end

local function clean()
    local veh = closestVehicle()
    if not veh then return end
    if not pay(Config.Prices.clean) then return end
    SetVehicleDirtLevel(veh, 0.0)
    msg(Config.Text.cleaned, 'success')
end

local function apk()
    local veh = closestVehicle()
    if not veh then return end
    TriggerServerEvent('delfzijlrp_v2_kolommer:server:renewApk', plate(veh))
end

local function tow()
    local veh = closestVehicle()
    if not veh then return end
    if not pay(Config.Prices.tow) then return end
    local t = Config.Location.tow
    SetEntityCoords(veh, t.x, t.y, t.z, false, false, false, false)
    SetVehicleOnGroundProperly(veh)
    msg(Config.Text.towed, 'success')
end

local function openMenu()
    lib.registerContext({
        id = 'de2kolommer_main',
        title = Config.Location.label,
        options = {
            { title = 'Repareren', description = 'Prijs: €' .. Config.Prices.repair, onSelect = repair },
            { title = 'Wassen', description = 'Prijs: €' .. Config.Prices.clean, onSelect = clean },
            { title = 'APK keuren', description = 'Alleen garage/ANWB medewerker', onSelect = apk },
            { title = 'Sleepdienst', description = 'Prijs: €' .. Config.Prices.tow, onSelect = tow },
            { title = 'Werkplaats opslag', onSelect = function() TriggerServerEvent('delfzijlrp_v2_kolommer:server:openStorage') end }
        }
    })
    lib.showContext('de2kolommer_main')
end

CreateThread(function()
    Wait(1500)
    local loc = Config.Location
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
        options = {{ name = 'de2kolommer_open', label = Config.Text.open, onSelect = openMenu }}
    })
    exports.ox_target:addSphereZone({
        coords = loc.storage,
        radius = 2.0,
        debug = Config.Debug,
        options = {{ name = 'de2kolommer_storage', label = Config.Text.storage, onSelect = function() TriggerServerEvent('delfzijlrp_v2_kolommer:server:openStorage') end }}
    })
end)

RegisterCommand(Config.Command, openMenu, false)

RegisterNetEvent('delfzijlrp_v2_kolommer:client:openStorage', function()
    exports.ox_inventory:openInventory('stash', 'de2kolommer_storage')
end)
