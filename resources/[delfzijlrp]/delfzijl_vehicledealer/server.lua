local ESX = exports['es_extended']:getSharedObject()

local function randomLetter()
    local index = math.random(1, #Config.DutchPlate.letters)
    return Config.DutchPlate.letters:sub(index, index)
end

local function generatePlateFromPattern(pattern)
    local plate = ''
    for i = 1, #pattern do
        local char = pattern:sub(i, i)
        if char == '9' then
            plate = plate .. tostring(math.random(0, 9))
        elseif char == 'X' then
            plate = plate .. randomLetter()
        else
            plate = plate .. char
        end
    end
    return plate
end

local function generateDutchPlate()
    local patterns = Config.DutchPlate.patterns
    local pattern = patterns[math.random(1, #patterns)]
    return generatePlateFromPattern(pattern)
end

local function plateExists(plate)
    local found = MySQL.scalar.await('SELECT plate FROM owned_vehicles WHERE plate = ? LIMIT 1', { plate })
    return found ~= nil
end

exports('GenerateDutchPlate', function()
    local plate
    repeat
        plate = generateDutchPlate()
    until not plateExists(plate)
    return plate
end)

exports('RegisterOwnedVehicle', function(source, model, props, vehicleType)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end

    local plate
    repeat
        plate = generateDutchPlate()
    until not plateExists(plate)

    props = props or {}
    props.model = props.model or joaat(model)
    props.plate = plate

    MySQL.insert.await('INSERT INTO owned_vehicles (owner, plate, vehicle, type, stored) VALUES (?, ?, ?, ?, ?)', {
        xPlayer.identifier,
        plate,
        json.encode(props),
        vehicleType or 'car',
        Config.DefaultStored
    })

    return plate
end)

RegisterCommand('geefauto', function(source, args)
    if source == 0 then return end
    local model = args[1]
    if not model then return end

    local plate = exports[GetCurrentResourceName()]:RegisterOwnedVehicle(source, model, { model = joaat(model) }, 'car')
    if plate then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Delfzijl RP Dealer',
            description = ('Voertuig %s gekocht met kenteken %s.'):format(model, plate),
            type = 'success'
        })
    end
end, false)
