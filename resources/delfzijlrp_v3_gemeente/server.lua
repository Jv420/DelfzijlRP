local ESX = exports['es_extended']:getSharedObject()

local function notify(src, text, kind)
    TriggerClientEvent('ox_lib:notify', src, { title = 'Gemeente Delfzijl', description = text, type = kind or 'inform' })
end

local function pay(xPlayer, amount)
    if xPlayer.getMoney() >= amount then xPlayer.removeMoney(amount) return true end
    local bank = xPlayer.getAccount('bank')
    if bank and bank.money >= amount then xPlayer.removeAccountMoney('bank', amount) return true end
    return false
end

CreateThread(function()
    MySQL.query.await([[CREATE TABLE IF NOT EXISTS delfzijlrp_gemeente_logs (
        id int NOT NULL AUTO_INCREMENT,
        identifier varchar(64) NOT NULL,
        player_name varchar(128) NOT NULL,
        action varchar(64) NOT NULL,
        price int NOT NULL DEFAULT 0,
        created_at timestamp NOT NULL DEFAULT current_timestamp(),
        PRIMARY KEY (id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]])
end)

local function docNumber(kind)
    return ('DRP-%s-%06d'):format(tostring(kind or 'DOC'):upper(), math.random(100000, 999999))
end

local function addDoc(src, item, meta)
    if not exports.ox_inventory:Items(item) then
        notify(src, Config.Text.missingItem .. ' (' .. item .. ')', 'error')
        return false
    end
    local ok, reason = exports.ox_inventory:AddItem(src, item, 1, meta or {})
    if not ok then notify(src, reason or Config.Text.invalid, 'error') return false end
    return true
end

RegisterNetEvent('delfzijlrp_v3_gemeente:server:request', function(kind)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local price = Config.Prices[kind]
    local item = Config.Items[kind]
    if not price or not item then notify(src, Config.Text.invalid, 'error') return end
    if not pay(xPlayer, price) then notify(src, Config.Text.noMoney, 'error') return end

    local identity = nil
    if GetResourceState('delfzijlrp_v3_identity_engine') == 'started' then
        identity = exports['delfzijlrp_v3_identity_engine']:EnsureIdentity(src)
    end

    local number = docNumber(kind)
    local meta = {
        naam = identity and identity.display_name or GetPlayerName(src),
        burgernummer = identity and identity.citizen_id or 'onbekend',
        telefoon = identity and identity.phone_number or 'onbekend',
        adres = identity and identity.address or 'onbekend',
        gemeente = 'Delfzijl',
        datum = os.date('%Y-%m-%d'),
        documentnummer = number,
        soort = Config.Labels[kind] or kind
    }

    if kind == 'rijbewijs' then meta.categorie = 'B' end
    if kind == 'motorrijbewijs' then meta.categorie = 'A' end
    if kind == 'vrachtwagenrijbewijs' then meta.categorie = 'C' end
    if kind == 'busrijbewijs' then meta.categorie = 'D' end
    if kind == 'vaarbewijs' then meta.categorie = 'VB' end
    if kind == 'buskaartje' then meta.soort = 'Dagkaart Delfzijl' end

    if not addDoc(src, item, meta) then
        xPlayer.addMoney(price)
        return
    end

    if identity and GetResourceState('delfzijlrp_v3_identity_engine') == 'started' then
        exports['delfzijlrp_v3_identity_engine']:AddDocumentHistory(xPlayer.identifier, kind, number)
        if kind == 'rijbewijs' then exports['delfzijlrp_v3_identity_engine']:SetDrivingCategory(xPlayer.identifier, 'B', true) end
        if kind == 'motorrijbewijs' then exports['delfzijlrp_v3_identity_engine']:SetDrivingCategory(xPlayer.identifier, 'A', true) end
        if kind == 'vrachtwagenrijbewijs' then exports['delfzijlrp_v3_identity_engine']:SetDrivingCategory(xPlayer.identifier, 'C', true) end
        if kind == 'busrijbewijs' then exports['delfzijlrp_v3_identity_engine']:SetDrivingCategory(xPlayer.identifier, 'D', true) end
    end

    MySQL.insert.await('INSERT INTO delfzijlrp_gemeente_logs (identifier, player_name, action, price) VALUES (?, ?, ?, ?)', {
        xPlayer.identifier, GetPlayerName(src), kind, price
    })
    notify(src, Config.Text.done, 'success')
end)
