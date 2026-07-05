CreateThread(function()
    Wait(2500)
    print(Config.Messages.started)
end)

local function closestVehicle()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh ~= 0 then return veh end
    local coords = GetEntityCoords(ped)
    return GetClosestVehicle(coords.x, coords.y, coords.z, 7.0, 0, 71)
end

RegisterCommand(Config.TestCommand, function()
    local veh = closestVehicle()
    if veh == 0 then
        print('^1[Delfzijl RP PlatePack v2]^7 Geen voertuig dichtbij.')
        return
    end

    SetVehicleNumberPlateText(veh, Config.TestPlateText)

    if Config.ForcePlateIndexOnTest then
        SetVehicleNumberPlateTextIndex(veh, 0)
    end

    print('^3[Delfzijl RP PlatePack v2]^7 ' .. Config.Messages.test)
end, false)
