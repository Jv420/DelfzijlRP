local function msg(text, kind)
    lib.notify({ title = 'Voertuigslot', description = text, type = kind or 'inform' })
end

local function trimPlate(plate)
    return plate and plate:gsub('^%s*(.-)%s*$', '%1'):upper() or ''
end

local function nearestVehicle()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh ~= 0 then return veh end
    local coords = GetEntityCoords(ped)
    veh = GetClosestVehicle(coords.x, coords.y, coords.z, Config.Range, 0, 71)
    if veh == 0 then return nil end
    return veh
end

local function hasKey(veh)
    local plate = trimPlate(GetVehicleNumberPlateText(veh))
    return lib.callback.await('delfzijlrp_v2_vehiclelock:server:hasKey', false, plate), plate
end

local function feedback(veh)
    if Config.FlashLights then
        SetVehicleLights(veh, 2)
        Wait(150)
        SetVehicleLights(veh, 0)
        Wait(150)
        SetVehicleLights(veh, 2)
        Wait(150)
        SetVehicleLights(veh, 0)
    end
    if Config.HornSound then
        StartVehicleHorn(veh, 120, `HELDDOWN`, false)
    end
end

local function toggleLock()
    local veh = nearestVehicle()
    if not veh then msg(Config.Text.noVehicle, 'error') return end
    local allowed = hasKey(veh)
    if not allowed then msg(Config.Text.noKey, 'error') return end

    local status = GetVehicleDoorLockStatus(veh)
    if status == 1 or status == 0 then
        SetVehicleDoorsLocked(veh, 2)
        SetVehicleDoorsLockedForAllPlayers(veh, true)
        msg(Config.Text.locked, 'success')
    else
        SetVehicleDoorsLocked(veh, 1)
        SetVehicleDoorsLockedForAllPlayers(veh, false)
        msg(Config.Text.unlocked, 'success')
    end
    feedback(veh)
end

local function toggleTrunk()
    local veh = nearestVehicle()
    if not veh then msg(Config.Text.noVehicle, 'error') return end
    local allowed = hasKey(veh)
    if not allowed then msg(Config.Text.noKey, 'error') return end

    if GetVehicleDoorAngleRatio(veh, 5) > 0.1 then
        SetVehicleDoorShut(veh, 5, false)
        msg(Config.Text.trunkClosed, 'success')
    else
        SetVehicleDoorOpen(veh, 5, false, false)
        msg(Config.Text.trunkOpen, 'success')
    end
end

RegisterCommand(Config.LockCommand, toggleLock, false)
RegisterCommand(Config.TrunkCommand, toggleTrunk, false)
RegisterKeyMapping(Config.LockCommand, 'Voertuig op slot/open', 'keyboard', Config.LockKey)
RegisterKeyMapping(Config.TrunkCommand, 'Kofferbak open/dicht', 'keyboard', Config.TrunkKey)
