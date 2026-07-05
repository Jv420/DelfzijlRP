local ESX = exports['es_extended']:getSharedObject()
local doorOpen = false
local doorObj = nil

local function msg(text, kind)
    lib.notify({ title = 'De2Kolommer', description = text, type = kind or 'inform' })
end

local function closestVehicle()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh ~= 0 then return veh end
    local coords = GetEntityCoords(ped)
    veh = GetClosestVehicle(coords.x, coords.y, coords.z, 8.0, 0, 71)
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

local function saveVehicle(veh)
    local props = ESX.Game.GetVehicleProperties(veh)
    props.plate = plate(veh)
    lib.callback.await('delfzijlrp_v2_lscustom:server:saveVehicle', false, props.plate, props)
end

local function tuneMod(veh, modType, modIndex, price)
    if not pay(price) then return end
    SetVehicleModKit(veh, 0)
    SetVehicleMod(veh, modType, modIndex, false)
    saveVehicle(veh)
    msg(Config.Text.tuned, 'success')
end

local function colorMenu(veh)
    local opts = {}
    for _, color in ipairs(Config.Colors) do
        opts[#opts + 1] = {
            title = color.label,
            description = 'Prijs: €' .. Config.Prices.color,
            onSelect = function()
                if not pay(Config.Prices.color) then return end
                SetVehicleColours(veh, color.primary, color.secondary)
                saveVehicle(veh)
                msg(Config.Text.tuned, 'success')
            end
        }
    end
    lib.registerContext({ id = 'kolommer_colors', title = 'Kleur kiezen', menu = 'kolommer_tuning', options = opts })
    lib.showContext('kolommer_colors')
end

local function tuningMenu()
    local veh = closestVehicle()
    if not veh then return end
    lib.registerContext({
        id = 'kolommer_tuning',
        title = 'De2Kolommer Tuning',
        menu = 'de2kolommer_main',
        options = {
            { title = 'Motor upgrade 1', description = '€' .. Config.Prices.engine1, onSelect = function() tuneMod(veh, 11, 0, Config.Prices.engine1) end },
            { title = 'Motor upgrade 2', description = '€' .. Config.Prices.engine2, onSelect = function() tuneMod(veh, 11, 1, Config.Prices.engine2) end },
            { title = 'Remmen upgrade 1', description = '€' .. Config.Prices.brakes1, onSelect = function() tuneMod(veh, 12, 0, Config.Prices.brakes1) end },
            { title = 'Remmen upgrade 2', description = '€' .. Config.Prices.brakes2, onSelect = function() tuneMod(veh, 12, 1, Config.Prices.brakes2) end },
            { title = 'Transmissie 1', description = '€' .. Config.Prices.transmission1, onSelect = function() tuneMod(veh, 13, 0, Config.Prices.transmission1) end },
            { title = 'Transmissie 2', description = '€' .. Config.Prices.transmission2, onSelect = function() tuneMod(veh, 13, 1, Config.Prices.transmission2) end },
            { title = 'Kleur wijzigen', description = '€' .. Config.Prices.color, onSelect = function() colorMenu(veh) end }
        }
    })
    lib.showContext('kolommer_tuning')
end

local function setYellow(veh)
    SetVehicleColours(veh, 88, 88)
    SetVehicleExtraColours(veh, 88, 88)
end

local function spawnServiceVehicle(data)
    local hash = joaat(data.model)
    lib.requestModel(hash)
    local s = Config.Location.towSpawn
    local veh = CreateVehicle(hash, s.x, s.y, s.z, s.w, true, false)
    SetVehicleNumberPlateText(veh, 'DK-' .. math.random(100, 999))
    setYellow(veh)
    SetVehicleOnGroundProperly(veh)
    SetPedIntoVehicle(PlayerPedId(), veh, -1)
    SetModelAsNoLongerNeeded(hash)
    msg(Config.Text.spawned, 'success')
end

local function towVehicleMenu()
    local opts = {}
    for _, data in ipairs(Config.TowVehicles) do
        opts[#opts + 1] = { title = data.label, onSelect = function() spawnServiceVehicle(data) end }
    end
    lib.registerContext({ id = 'kolommer_towcars', title = 'Sleepvoertuigen', menu = 'de2kolommer_main', options = opts })
    lib.showContext('kolommer_towcars')
end

local function ensureDoor()
    if not Config.Door.enabled then return end
    if doorObj and DoesEntityExist(doorObj) then return end
    local hash = joaat(Config.Door.prop)
    lib.requestModel(hash)
    local d = Config.Location.door
    doorObj = CreateObject(hash, d.x, d.y, Config.Door.closedZ, false, false, false)
    SetEntityHeading(doorObj, Config.Door.heading)
    FreezeEntityPosition(doorObj, true)
    SetModelAsNoLongerNeeded(hash)
end

local function toggleDoor()
    ensureDoor()
    if not doorObj or not DoesEntityExist(doorObj) then return end
    doorOpen = not doorOpen
    local d = Config.Location.door
    local z = doorOpen and Config.Door.openZ or Config.Door.closedZ
    SetEntityCoords(doorObj, d.x, d.y, z, false, false, false, false)
    FreezeEntityPosition(doorObj, true)
    msg(doorOpen and 'Loodsdeur open.' or 'Loodsdeur dicht.', 'success')
end

local function openMenu()
    lib.registerContext({
        id = 'de2kolommer_main',
        title = Config.Location.label,
        options = {
            { title = 'Loodsdeur open/dicht', onSelect = toggleDoor },
            { title = 'Repareren', description = 'Prijs: €' .. Config.Prices.repair, onSelect = repair },
            { title = 'Wassen', description = 'Prijs: €' .. Config.Prices.clean, onSelect = clean },
            { title = 'APK keuren', description = 'Alleen garage/ANWB medewerker', onSelect = apk },
            { title = 'Tuning', description = 'Motor, remmen, transmissie, kleur', onSelect = tuningMenu },
            { title = 'Sleepdienst', description = 'Prijs: €' .. Config.Prices.tow, onSelect = tow },
            { title = 'Gele sleepvoertuigen', onSelect = towVehicleMenu },
            { title = 'Werkplaats opslag', onSelect = function() TriggerServerEvent('delfzijlrp_v2_kolommer:server:openStorage') end }
        }
    })
    lib.showContext('de2kolommer_main')
end

CreateThread(function()
    Wait(1500)
    local loc = Config.Location
    ensureDoor()
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
    exports.ox_target:addSphereZone({
        coords = loc.door,
        radius = 2.0,
        debug = Config.Debug,
        options = {{ name = 'de2kolommer_door', label = Config.Text.door, onSelect = toggleDoor }}
    })
end)

RegisterCommand(Config.Command, openMenu, false)

RegisterNetEvent('delfzijlrp_v2_kolommer:client:openStorage', function()
    exports.ox_inventory:openInventory('stash', 'de2kolommer_storage')
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() and doorObj and DoesEntityExist(doorObj) then
        DeleteEntity(doorObj)
    end
end)
