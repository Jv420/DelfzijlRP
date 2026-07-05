local buckled = false
local lastVeh = 0
local lastSpeed = 0.0

local function notify(text, kind)
    if Config.Notify then
        lib.notify({ title = 'Delfzijl Gordel', description = text, type = kind or 'inform' })
    end
end

local function inVehicle()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh == 0 then return false, ped, veh end
    if IsThisModelABike(GetEntityModel(veh)) or IsThisModelABicycle(GetEntityModel(veh)) or IsThisModelABoat(GetEntityModel(veh)) or IsThisModelAHeli(GetEntityModel(veh)) or IsThisModelAPlane(GetEntityModel(veh)) then
        return false, ped, veh
    end
    return true, ped, veh
end

local function toggleSeatbelt()
    local ok = inVehicle()
    if not ok then return end
    buckled = not buckled
    notify(buckled and Config.Text.on or Config.Text.off, buckled and 'success' or 'warning')
end

RegisterCommand(Config.Command, toggleSeatbelt, false)
RegisterKeyMapping(Config.Command, 'Gordel aan/uit', 'keyboard', Config.DefaultKey)

CreateThread(function()
    while true do
        Wait(0)
        local ok, ped, veh = inVehicle()
        if ok then
            if Config.DisableExitWhenBuckled and buckled then
                DisableControlAction(0, 75, true)
                DisableControlAction(27, 75, true)
            end
        else
            if buckled then buckled = false end
            Wait(500)
        end
    end
end)

CreateThread(function()
    while true do
        Wait(150)
        local ok, ped, veh = inVehicle()
        if not ok then
            lastVeh = 0
            lastSpeed = 0.0
            Wait(500)
        else
            local speed = GetEntitySpeed(veh) * 3.6
            if Config.EjectCheck and not buckled and lastVeh == veh then
                local drop = lastSpeed - speed
                if lastSpeed > Config.MinEjectSpeedKmh and drop > Config.SpeedDropForEject and HasEntityCollidedWithAnything(veh) then
                    local coords = GetEntityCoords(ped)
                    local forward = GetEntityForwardVector(veh)
                    SetEntityCoords(ped, coords.x + forward.x * 2.0, coords.y + forward.y * 2.0, coords.z + 0.8, true, true, true, false)
                    SetPedToRagdoll(ped, 3500, 3500, 0, false, false, false)
                    SetEntityVelocity(ped, forward.x * 8.0, forward.y * 8.0, 4.0)
                end
            end
            lastVeh = veh
            lastSpeed = speed
        end
    end
end)
