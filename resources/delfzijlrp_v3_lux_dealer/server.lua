local ESX = exports['es_extended']:getSharedObject()

local function notify(src, text, kind)
    TriggerClientEvent('ox_lib:notify', src, { title = 'Piricars', description = text, type = kind or 'inform' })
end

local function findCar(model)
    for _, car in ipairs(Config.Cars) do
        if car.model == model then return car end
    end
    return nil
end

local function makePlate()
    local letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    local a = letters:sub(math.random(1, 26), math.random(1, 26))
    if #a ~= 1 then a = 'D' end
    local b = letters:sub(math.random(1, 26), math.random(1, 26))
    if #b ~= 1 then b = 'R' end
    return ('%s%s-%03d-%s'):format(a, b, math.random(100, 999), 'NL')
end

RegisterNetEvent('delfzijlrp_v3_lux_dealer:server:buy', function(model)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    local car = findCar(model)
    if not car then notify(src, Config.Text.invalid, 'error') return end

    local bank = xPlayer.getAccount('bank')
    if not bank or bank.money < car.price then notify(src, Config.Text.noMoney, 'error') return end
    xPlayer.removeAccountMoney('bank', car.price)

    local plate = makePlate()
    exports['delfzijlrp_v3_rdw_premium']:RegisterVehicle(src, plate, car.model)
    exports['delfzijlrp_v3_veh_eco']:EnsureProfile(plate, GetPlayerName(src))
    exports['delfzijlrp_v3_veh_eco']:AddHistory(plate, 'dealer_sale', 'Gekocht bij Piricars: ' .. car.label, GetPlayerName(src))

    MySQL.update.await('UPDATE delfzijlrp_businesses SET balance = balance + ?, turnover = turnover + ? WHERE id = ?', { car.price, car.price, Config.BusinessId })
    exports['delfzijlrp_v3_business_core']:AddLog(Config.BusinessId, 'sale', car.price, car.label .. ' | ' .. plate, GetPlayerName(src))

    notify(src, Config.Text.bought .. ' Kenteken: ' .. plate, 'success')
end)
