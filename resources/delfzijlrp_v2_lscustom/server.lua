local ESX = exports['es_extended']:getSharedObject()

local function pay(xPlayer, amount)
    if amount <= 0 then return true end
    if xPlayer.getMoney() >= amount then xPlayer.removeMoney(amount) return true end
    local bank = xPlayer.getAccount('bank')
    if bank and bank.money >= amount then xPlayer.removeAccountMoney('bank', amount) return true end
    return false
end

lib.callback.register('delfzijlrp_v2_lscustom:server:pay', function(source, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end
    return pay(xPlayer, tonumber(amount) or 0)
end)

lib.callback.register('delfzijlrp_v2_lscustom:server:saveVehicle', function(source, plate, props)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or not plate or not props then return false, 'Ongeldig voertuig.' end
    plate = plate:gsub('^%s*(.-)%s*$', '%1'):upper()

    local owner = MySQL.scalar.await('SELECT owner FROM owned_vehicles WHERE plate = ? LIMIT 1', { plate })
    if owner and owner ~= xPlayer.identifier then return false, Config.Text.notOwned end

    local encoded = json.encode(props)
    MySQL.update.await('UPDATE owned_vehicles SET vehicle = ? WHERE plate = ?', { encoded, plate })
    MySQL.update.await('UPDATE delfzijlrp_garage_states SET vehicle_props = ? WHERE plate = ?', { encoded, plate })
    MySQL.update.await('UPDATE delfzijlrp_rdw_registry SET vehicle_props = ? WHERE plate = ?', { encoded, plate })
    return true, Config.Text.saved
end)
