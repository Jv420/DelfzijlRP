local ESX = exports['es_extended']:getSharedObject()

local letters = 'ABCDEFGHJKLMNPRSTUVWXYZ'
local numbers = '0123456789'

local function getPlayer(source)
    return ESX.GetPlayerFromId(source)
end

local function getIdentifier(source)
    local xPlayer = getPlayer(source)
    return xPlayer and xPlayer.identifier or nil
end

local function notify(source, message, type)
    TriggerClientEvent('ox_lib:notify', source, { title = 'RDW Delfzijl', description = message, type = type or 'inform' })
end

local function trimPlate(plate)
    return plate and plate:gsub('^%s*(.-)%s*$', '%1'):upper() or ''
end

local function getName(identifier, fallback)
    local row = MySQL.single.await('SELECT firstname, lastname FROM delfzijlrp_identities WHERE identifier = ? LIMIT 1', { identifier })
    if row then return row.firstname .. ' ' .. row.lastname end
    return fallback or identifier
end

local function pay(source, amount)
    local xPlayer = getPlayer(source)
    if not xPlayer then return false end
    if xPlayer.getMoney() >= amount then xPlayer.removeMoney(amount) return true end
    local bank = xPlayer.getAccount('bank')
    if bank and bank.money >= amount then xPlayer.removeAccountMoney('bank', amount) return true end
    return false
end

local function randomChar(kind)
    local src = kind == 'L' and letters or numbers
    local i = math.random(1, #src)
    return src:sub(i, i)
end

local function makePlateFromPattern(pattern)
    local out = {}
    for i = 1, #pattern do
        local c = pattern:sub(i, i)
        if c == 'L' or c == 'N' then out[#out + 1] = randomChar(c) else out[#out + 1] = c end
    end
    return table.concat(out)
end

local function hasBlockedCombo(plate)
    local raw = plate:gsub('%-', '')
    for combo in pairs(Config.Plate.blocked) do
        if raw:find(combo, 1, true) then return true end
    end
    return false
end

local function plateExists(plate)
    return MySQL.scalar.await('SELECT plate FROM delfzijlrp_rdw_registry WHERE plate = ? LIMIT 1', { plate }) ~= nil
        or MySQL.scalar.await('SELECT plate FROM owned_vehicles WHERE plate = ? LIMIT 1', { plate }) ~= nil
end

local function generatePlate()
    for _ = 1, Config.Plate.maxAttempts do
        local pattern = Config.Plate.patterns[math.random(1, #Config.Plate.patterns)]
        local plate = makePlateFromPattern(pattern)
        if not hasBlockedCombo(plate) and not plateExists(plate) then return plate end
    end
    return ('DRP%s'):format(math.random(1000, 9999))
end

local function logRdw(plate, source, action, details)
    MySQL.insert.await('INSERT INTO delfzijlrp_rdw_history (plate, actor_identifier, action, details) VALUES (?, ?, ?, ?)', {
        plate,
        source and getIdentifier(source) or nil,
        action,
        details
    })
end

local function syncVehicle(oldPlate, newPlate, owner, props)
    if oldPlate and oldPlate ~= newPlate then
        MySQL.update.await('UPDATE owned_vehicles SET plate = ? WHERE plate = ?', { newPlate, oldPlate })
        MySQL.update.await('UPDATE delfzijlrp_garage_states SET plate = ? WHERE plate = ?', { newPlate, oldPlate })
        MySQL.update.await('UPDATE delfzijlrp_vehicle_registry SET plate = ? WHERE plate = ?', { newPlate, oldPlate })
        MySQL.update.await('UPDATE delfzijlrp_vehicle_keys SET plate = ? WHERE plate = ?', { newPlate, oldPlate })
    end
    if props then
        MySQL.update.await('UPDATE owned_vehicles SET vehicle = ? WHERE plate = ?', { json.encode(props), newPlate })
        MySQL.update.await('UPDATE delfzijlrp_garage_states SET vehicle_props = ? WHERE plate = ?', { json.encode(props), newPlate })
    end
end

lib.callback.register('delfzijlrp_rdw:server:getMyVehicles', function(source)
    local identifier = getIdentifier(source)
    if not identifier then return {} end
    return MySQL.query.await('SELECT * FROM delfzijlrp_rdw_registry WHERE owner = ? ORDER BY updated_at DESC', { identifier }) or {}
end)

lib.callback.register('delfzijlrp_rdw:server:lookupPlate', function(source, plate)
    plate = trimPlate(plate)
    if plate == '' then return nil end
    local row = MySQL.single.await('SELECT * FROM delfzijlrp_rdw_registry WHERE plate = ? LIMIT 1', { plate })
    if row then logRdw(plate, source, 'lookup', GetPlayerName(source)) end
    return row
end)

RegisterNetEvent('delfzijlrp_rdw:server:registerVehicle', function(oldPlate, model, props)
    local source = source
    local identifier = getIdentifier(source)
    oldPlate = trimPlate(oldPlate)
    if not identifier or oldPlate == '' then notify(source, Config.Text.noVehicle, 'error') return end
    if not pay(source, Config.Prices.register) then notify(source, Config.Text.noMoney, 'error') return end

    if MySQL.scalar.await('SELECT plate FROM delfzijlrp_rdw_registry WHERE plate = ? LIMIT 1', { oldPlate }) then
        notify(source, 'Dit voertuig staat al geregistreerd.', 'error')
        return
    end

    local newPlate = generatePlate()
    local vin = ('DRP%s%s'):format(os.time(), math.random(1000, 9999))
    local apkUntil = os.date('%Y-%m-%d %H:%M:%S', os.time() + (Config.ValidDays.apk * 86400))

    MySQL.insert.await('INSERT INTO delfzijlrp_rdw_registry (plate, old_plate, owner, owner_name, vin, model, vehicle_props, apk_until, insurance_type, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', {
        newPlate,
        oldPlate,
        identifier,
        getName(identifier, GetPlayerName(source)),
        vin,
        tostring(model or 'unknown'),
        props and json.encode(props) or nil,
        apkUntil,
        'none',
        'active'
    })

    syncVehicle(oldPlate, newPlate, identifier, props)
    logRdw(newPlate, source, 'register', oldPlate .. ' -> ' .. newPlate)
    TriggerClientEvent('delfzijlrp_rdw:client:setPlateOnVehicle', source, newPlate)
    notify(source, Config.Text.registered .. ' Kenteken: ' .. newPlate, 'success')
end)

RegisterNetEvent('delfzijlrp_rdw:server:setCustomPlate', function(currentPlate, desiredPlate, props)
    local source = source
    local identifier = getIdentifier(source)
    currentPlate = trimPlate(currentPlate)
    desiredPlate = trimPlate(desiredPlate):gsub('[^A-Z0-9%-]', '')
    if not identifier or #desiredPlate < 3 or #desiredPlate > 8 then notify(source, Config.Text.invalid, 'error') return end

    local row = MySQL.single.await('SELECT * FROM delfzijlrp_rdw_registry WHERE plate = ? LIMIT 1', { currentPlate })
    if not row then notify(source, Config.Text.notFound, 'error') return end
    if row.owner ~= identifier then notify(source, Config.Text.notOwner, 'error') return end
    if plateExists(desiredPlate) then notify(source, 'Dit kenteken bestaat al.', 'error') return end
    if not pay(source, Config.Prices.customPlate) then notify(source, Config.Text.noMoney, 'error') return end

    MySQL.update.await('UPDATE delfzijlrp_rdw_registry SET plate = ?, old_plate = ? WHERE plate = ?', { desiredPlate, currentPlate, currentPlate })
    MySQL.insert.await('INSERT INTO delfzijlrp_rdw_customplates (plate, owner) VALUES (?, ?)', { desiredPlate, identifier })
    syncVehicle(currentPlate, desiredPlate, identifier, props)
    logRdw(desiredPlate, source, 'custom_plate', currentPlate .. ' -> ' .. desiredPlate)
    TriggerClientEvent('delfzijlrp_rdw:client:setPlateOnVehicle', source, desiredPlate)
    notify(source, Config.Text.customSet .. ' ' .. desiredPlate, 'success')
end)

RegisterNetEvent('delfzijlrp_rdw:server:buyInsurance', function(plate, insuranceType)
    local source = source
    local identifier = getIdentifier(source)
    plate = trimPlate(plate)
    local prices = { wa = Config.Prices.insuranceWA, waplus = Config.Prices.insuranceWAPLUS, allrisk = Config.Prices.insuranceAllRisk }
    local price = prices[insuranceType]
    if not identifier or not price then notify(source, Config.Text.invalid, 'error') return end

    local row = MySQL.single.await('SELECT * FROM delfzijlrp_rdw_registry WHERE plate = ? LIMIT 1', { plate })
    if not row then notify(source, Config.Text.notFound, 'error') return end
    if row.owner ~= identifier then notify(source, Config.Text.notOwner, 'error') return end
    if not pay(source, price) then notify(source, Config.Text.noMoney, 'error') return end

    local untilDate = os.date('%Y-%m-%d %H:%M:%S', os.time() + (Config.ValidDays.insurance * 86400))
    MySQL.update.await('UPDATE delfzijlrp_rdw_registry SET insurance_type = ?, insurance_until = ? WHERE plate = ?', { insuranceType, untilDate, plate })
    logRdw(plate, source, 'insurance', insuranceType)
    notify(source, 'Verzekering afgesloten.', 'success')
end)

RegisterNetEvent('delfzijlrp_rdw:server:renewApk', function(plate)
    local source = source
    local xPlayer = getPlayer(source)
    plate = trimPlate(plate)
    if not xPlayer or not xPlayer.job or not Config.AllowedJobs[xPlayer.job.name] then notify(source, 'Geen toegang.', 'error') return end
    local untilDate = os.date('%Y-%m-%d %H:%M:%S', os.time() + (Config.ValidDays.apk * 86400))
    MySQL.update.await('UPDATE delfzijlrp_rdw_registry SET apk_until = ? WHERE plate = ?', { untilDate, plate })
    logRdw(plate, source, 'apk', untilDate)
    notify(source, 'APK bijgewerkt.', 'success')
end)

RegisterNetEvent('delfzijlrp_rdw:server:transferVehicle', function(plate, targetId)
    local source = source
    local identifier = getIdentifier(source)
    local target = getPlayer(tonumber(targetId))
    plate = trimPlate(plate)
    if not identifier or not target then notify(source, Config.Text.invalid, 'error') return end
    local row = MySQL.single.await('SELECT * FROM delfzijlrp_rdw_registry WHERE plate = ? LIMIT 1', { plate })
    if not row then notify(source, Config.Text.notFound, 'error') return end
    if row.owner ~= identifier then notify(source, Config.Text.notOwner, 'error') return end
    if not pay(source, Config.Prices.transfer) then notify(source, Config.Text.noMoney, 'error') return end

    MySQL.update.await('UPDATE delfzijlrp_rdw_registry SET owner = ?, owner_name = ? WHERE plate = ?', { target.identifier, getName(target.identifier, GetPlayerName(target.source)), plate })
    MySQL.update.await('UPDATE owned_vehicles SET owner = ? WHERE plate = ?', { target.identifier, plate })
    MySQL.update.await('UPDATE delfzijlrp_garage_states SET owner = ? WHERE plate = ?', { target.identifier, plate })
    logRdw(plate, source, 'transfer', identifier .. ' -> ' .. target.identifier)
    notify(source, Config.Text.transferred, 'success')
    notify(target.source, 'Voertuig op jouw naam gezet: ' .. plate, 'success')
end)

exports('GeneratePlate', generatePlate)
exports('LookupPlate', function(plate)
    return MySQL.single.await('SELECT * FROM delfzijlrp_rdw_registry WHERE plate = ? LIMIT 1', { trimPlate(plate) })
end)
