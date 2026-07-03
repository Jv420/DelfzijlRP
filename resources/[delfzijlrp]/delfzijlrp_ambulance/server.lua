local ESX = exports['es_extended']:getSharedObject()

local function getPlayer(source)
    return ESX.GetPlayerFromId(source)
end

local function getIdentifier(source)
    local xPlayer = getPlayer(source)
    return xPlayer and xPlayer.identifier or nil
end

local function notify(source, message, type)
    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Delfzijl RP Ambulance',
        description = message,
        type = type or 'inform'
    })
end

local function isAmbulance(source)
    local xPlayer = getPlayer(source)
    return xPlayer and xPlayer.job and xPlayer.job.name == Config.JobName
end

local function pay(source, amount)
    local xPlayer = getPlayer(source)
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

local function getIdentityName(identifier, fallback)
    if not identifier then return fallback end
    local identity = MySQL.single.await('SELECT firstname, lastname FROM delfzijlrp_identities WHERE identifier = ? LIMIT 1', { identifier })
    if identity then return identity.firstname .. ' ' .. identity.lastname end
    return fallback
end

local function addMedicalRecord(patientSource, medicSource, recordType, notes)
    local patient = getPlayer(patientSource)
    local medic = medicSource and getPlayer(medicSource) or nil
    local patientIdentifier = patient and patient.identifier or nil
    local medicIdentifier = medic and medic.identifier or nil

    MySQL.insert.await([[INSERT INTO delfzijlrp_medical_records
        (patient_identifier, patient_name, medic_identifier, medic_name, record_type, notes)
        VALUES (?, ?, ?, ?, ?, ?)]], {
        patientIdentifier,
        getIdentityName(patientIdentifier, GetPlayerName(patientSource)),
        medicIdentifier,
        medicSource and GetPlayerName(medicSource) or 'Ziekenhuis',
        recordType,
        notes
    })
end

lib.callback.register('delfzijlrp_ambulance:server:isAmbulance', function(source)
    return isAmbulance(source)
end)

lib.callback.register('delfzijlrp_ambulance:server:getRecords', function(source, targetId)
    if not isAmbulance(source) then return {} end
    local target = getPlayer(tonumber(targetId))
    if not target then return {} end

    return MySQL.query.await('SELECT * FROM delfzijlrp_medical_records WHERE patient_identifier = ? ORDER BY created_at DESC LIMIT 30', {
        target.identifier
    }) or {}
end)

RegisterNetEvent('delfzijlrp_ambulance:server:toggleDuty', function()
    local source = source
    local identifier = getIdentifier(source)
    if not identifier or not isAmbulance(source) then return end

    local current = MySQL.scalar.await('SELECT on_duty FROM delfzijlrp_ambulance_duty WHERE identifier = ? LIMIT 1', { identifier })
    local newState = current == 1 and 0 or 1

    MySQL.insert.await([[INSERT INTO delfzijlrp_ambulance_duty (identifier, on_duty) VALUES (?, ?)
        ON DUPLICATE KEY UPDATE on_duty = VALUES(on_duty)]], { identifier, newState })

    notify(source, newState == 1 and 'Je bent in dienst.' or 'Je bent uit dienst.', 'success')
end)

RegisterNetEvent('delfzijlrp_ambulance:server:revivePlayer', function(targetId)
    local source = source
    if not isAmbulance(source) then return end
    targetId = tonumber(targetId)
    if not targetId or not GetPlayerName(targetId) then
        notify(source, Config.Text.playerNotFound, 'error')
        return
    end

    TriggerClientEvent('esx_ambulancejob:revive', targetId)
    addMedicalRecord(targetId, source, 'revive', 'Reanimatie uitgevoerd door ambulance.')
    notify(source, Config.Text.revived, 'success')
    notify(targetId, 'Je bent gereanimeerd door de ambulance.', 'success')
end)

RegisterNetEvent('delfzijlrp_ambulance:server:healPlayer', function(targetId)
    local source = source
    if not isAmbulance(source) then return end
    targetId = tonumber(targetId)
    if not targetId or not GetPlayerName(targetId) then
        notify(source, Config.Text.playerNotFound, 'error')
        return
    end

    TriggerClientEvent('delfzijlrp_ambulance:client:heal', targetId)
    addMedicalRecord(targetId, source, 'treatment', 'Medische behandeling uitgevoerd.')
    notify(source, Config.Text.healed, 'success')
    notify(targetId, 'Je bent behandeld door de ambulance.', 'success')
end)

RegisterNetEvent('delfzijlrp_ambulance:server:addRecord', function(targetId, recordType, notes)
    local source = source
    if not isAmbulance(source) then return end
    targetId = tonumber(targetId)
    if not targetId or not GetPlayerName(targetId) then
        notify(source, Config.Text.playerNotFound, 'error')
        return
    end

    addMedicalRecord(targetId, source, recordType or 'note', notes or '')
    notify(source, Config.Text.recordCreated, 'success')
end)

RegisterNetEvent('delfzijlrp_ambulance:server:checkIn', function()
    local source = source
    if not pay(source, Config.Services.checkinPrice) then
        notify(source, Config.Text.noMoney, 'error')
        return
    end

    TriggerClientEvent('delfzijlrp_ambulance:client:hospitalHeal', source, Config.Services.checkinDuration)
    addMedicalRecord(source, nil, 'hospital_checkin', 'Zelf ingecheckt bij ziekenhuis.')
end)

RegisterNetEvent('delfzijlrp_ambulance:server:openStorage', function(hospitalId)
    local source = source
    if not isAmbulance(source) then return end
    local stashId = ('ambulance_storage_%s'):format(hospitalId or 'main')
    exports.ox_inventory:RegisterStash(stashId, 'Ambulance Opslag', 80, 150000)
    TriggerClientEvent('delfzijlrp_ambulance:client:openStash', source, stashId)
end)
