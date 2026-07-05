local ESX = exports['es_extended']:getSharedObject()

local function notify(src, text, kind)
    TriggerClientEvent('ox_lib:notify', src, { title = 'Delfzijl Papieren', description = text, type = kind or 'inform' })
end

local function pay(xPlayer, amount)
    if amount <= 0 then return true end
    if xPlayer.getMoney() >= amount then xPlayer.removeMoney(amount) return true end
    local bank = xPlayer.getAccount('bank')
    if bank and bank.money >= amount then xPlayer.removeAccountMoney('bank', amount) return true end
    return false
end

local function addPaper(src, itemName, metadata)
    if not exports.ox_inventory:Items(itemName) then
        notify(src, Config.Text.missingItem .. ' (' .. itemName .. ')', 'error')
        return false
    end
    local ok, reason = exports.ox_inventory:AddItem(src, itemName, 1, metadata or {})
    if not ok then notify(src, reason or 'Inventory vol.', 'error') return false end
    notify(src, Config.Text.given, 'success')
    return true
end

local function fullName(identifier, fallback)
    local row = MySQL.single.await('SELECT firstname, lastname, dateofbirth FROM users WHERE identifier = ? LIMIT 1', { identifier })
    if row then
        return (row.firstname or '') .. ' ' .. (row.lastname or ''), row.dateofbirth
    end
    row = MySQL.single.await('SELECT firstname, lastname, dateofbirth FROM delfzijlrp_identities WHERE identifier = ? LIMIT 1', { identifier })
    if row then
        return (row.firstname or '') .. ' ' .. (row.lastname or ''), row.dateofbirth
    end
    return fallback, nil
end

RegisterCommand(Config.Commands.giveId, function(src)
    local xPlayer = ESX.GetPlayerFromId(src); if not xPlayer then return end
    if not pay(xPlayer, Config.Prices.idkaart) then notify(src, Config.Text.noMoney, 'error') return end
    local name, dob = fullName(xPlayer.identifier, GetPlayerName(src))
    addPaper(src, Config.Items.idkaart, { naam = name, geboortedatum = dob or 'onbekend', identifier = xPlayer.identifier })
end, false)

RegisterCommand(Config.Commands.giveLicense, function(src)
    local xPlayer = ESX.GetPlayerFromId(src); if not xPlayer then return end
    if not pay(xPlayer, Config.Prices.rijbewijs) then notify(src, Config.Text.noMoney, 'error') return end
    local name, dob = fullName(xPlayer.identifier, GetPlayerName(src))
    addPaper(src, Config.Items.rijbewijs, { naam = name, geboortedatum = dob or 'onbekend', categorie = 'B', identifier = xPlayer.identifier })
end, false)

RegisterCommand(Config.Commands.giveBusTicket, function(src)
    local xPlayer = ESX.GetPlayerFromId(src); if not xPlayer then return end
    if not pay(xPlayer, Config.Prices.buskaartje) then notify(src, Config.Text.noMoney, 'error') return end
    addPaper(src, Config.Items.buskaartje, { geldig = os.date('%Y-%m-%d'), soort = 'Dagkaart Delfzijl' })
end, false)

local function giveVehiclePapers(src, plate)
    local xPlayer = ESX.GetPlayerFromId(src); if not xPlayer then return false end
    plate = plate and plate:gsub('^%s*(.-)%s*$', '%1'):upper() or ''
    if plate == '' then notify(src, Config.Text.invalid, 'error') return false end

    local row = MySQL.single.await('SELECT * FROM delfzijlrp_rdw_registry WHERE plate = ? LIMIT 1', { plate })
    if not row then row = MySQL.single.await('SELECT plate, owner, model FROM owned_vehicles WHERE plate = ? LIMIT 1', { plate }) end
    if not row then notify(src, Config.Text.noVehicle, 'error') return false end
    if row.owner ~= xPlayer.identifier then notify(src, Config.Text.noOwner, 'error') return false end

    addPaper(src, Config.Items.autosleutel, { kenteken = plate, eigenaar = GetPlayerName(src), type = 'owner' })
    addPaper(src, Config.Items.kentekenbewijs, { kenteken = plate, eigenaar = GetPlayerName(src), model = row.model or 'voertuig', vin = row.vin or 'onbekend' })
    addPaper(src, Config.Items.verzekeringsbewijs, { kenteken = plate, type = row.insurance_type or 'none', geldig_tot = row.insurance_until or 'onbekend' })
    return true
end

RegisterCommand(Config.Commands.giveVehicleDocs, function(src, args)
    giveVehiclePapers(src, table.concat(args or {}, ' '))
end, false)

RegisterNetEvent('delfzijlrp_v2_papieren:server:giveVehiclePapers', function(plate)
    giveVehiclePapers(source, plate)
end)

exports('GiveVehiclePapers', giveVehiclePapers)
exports('GivePaperItem', function(src, itemName, metadata)
    return addPaper(src, itemName, metadata)
end)
