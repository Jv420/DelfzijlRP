local ESX = exports['es_extended']:getSharedObject()

local function notify(source, message, type)
    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Gemeente Delfzijl',
        description = message,
        type = type or 'inform'
    })
end

local function getIdentifier(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    return xPlayer and xPlayer.identifier or nil
end

local function randomDigits(length)
    local value = ''
    for _ = 1, length do
        value = value .. tostring(math.random(0, 9))
    end
    return value
end

local function createDelfzijlId()
    local year = os.date('%Y')
    local id
    repeat
        id = ('%s-%s-%s'):format(Config.Identity.delfzijlIdPrefix, year, randomDigits(6))
    until not MySQL.scalar.await('SELECT delfzijl_id FROM delfzijlrp_identities WHERE delfzijl_id = ? LIMIT 1', { id })
    return id
end

local function createDocumentNumber(documentType)
    local prefix = documentType:upper():sub(1, 3)
    local number
    repeat
        number = ('%s-%s-%s'):format(prefix, os.date('%Y'), randomDigits(7))
    until not MySQL.scalar.await('SELECT document_number FROM delfzijlrp_documents WHERE document_number = ? LIMIT 1', { number })
    return number
end

local function pay(source, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end

    if xPlayer.getMoney() >= amount then
        xPlayer.removeMoney(amount)
        return true
    end

    if xPlayer.getAccount('bank').money >= amount then
        xPlayer.removeAccountMoney('bank', amount)
        return true
    end

    return false
end

exports('GetIdentity', function(source)
    local identifier = getIdentifier(source)
    if not identifier then return nil end
    return MySQL.single.await('SELECT * FROM delfzijlrp_identities WHERE identifier = ? LIMIT 1', { identifier })
end)

exports('GetIdentityByIdentifier', function(identifier)
    return MySQL.single.await('SELECT * FROM delfzijlrp_identities WHERE identifier = ? LIMIT 1', { identifier })
end)

lib.callback.register('delfzijlrp_identity:server:getProfile', function(source)
    local identifier = getIdentifier(source)
    if not identifier then return nil end
    return MySQL.single.await('SELECT * FROM delfzijlrp_identities WHERE identifier = ? LIMIT 1', { identifier })
end)

RegisterNetEvent('delfzijlrp_identity:server:createProfile', function(data)
    local source = source
    local identifier = getIdentifier(source)
    if not identifier then return end

    local exists = MySQL.scalar.await('SELECT identifier FROM delfzijlrp_identities WHERE identifier = ? LIMIT 1', { identifier })
    if exists then
        notify(source, Config.Text.profileExists, 'error')
        return
    end

    if type(data) ~= 'table' or not data.firstname or not data.lastname or not data.dateofbirth or not data.sex then
        notify(source, Config.Text.invalidInput, 'error')
        return
    end

    local delfzijlId = createDelfzijlId()

    MySQL.insert.await([[INSERT INTO delfzijlrp_identities
        (identifier, delfzijl_id, firstname, lastname, dateofbirth, sex, height, nationality, birthplace)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)]], {
        identifier,
        delfzijlId,
        data.firstname,
        data.lastname,
        data.dateofbirth,
        data.sex,
        tonumber(data.height) or 180,
        data.nationality or 'Nederlands',
        data.birthplace or 'Delfzijl'
    })

    notify(source, Config.Text.profileCreated, 'success')
end)

RegisterNetEvent('delfzijlrp_identity:server:issueDocument', function(documentType)
    local source = source
    local identifier = getIdentifier(source)
    if not identifier then return end

    local profile = MySQL.single.await('SELECT * FROM delfzijlrp_identities WHERE identifier = ? LIMIT 1', { identifier })
    if not profile then
        notify(source, Config.Text.profileMissing, 'error')
        return
    end

    local price = Config.Prices[documentType]
    local item = Config.Items[documentType]
    if not price or not item then
        notify(source, Config.Text.invalidInput, 'error')
        return
    end

    if not pay(source, price) then
        notify(source, Config.Text.noMoney, 'error')
        return
    end

    local documentNumber = createDocumentNumber(documentType)
    local expiresAt = os.date('%Y-%m-%d %H:%M:%S', os.time() + (365 * 86400))

    MySQL.insert.await('INSERT INTO delfzijlrp_documents (identifier, document_type, document_number, expires_at) VALUES (?, ?, ?, ?)', {
        identifier,
        documentType,
        documentNumber,
        expiresAt
    })

    local metadata = {
        document_number = documentNumber,
        delfzijl_id = profile.delfzijl_id,
        firstname = profile.firstname,
        lastname = profile.lastname,
        dateofbirth = profile.dateofbirth,
        sex = profile.sex,
        nationality = profile.nationality,
        birthplace = profile.birthplace,
        expires_at = expiresAt
    }

    exports.ox_inventory:AddItem(source, item, 1, metadata)
    notify(source, Config.Text.documentIssued, 'success')
end)
