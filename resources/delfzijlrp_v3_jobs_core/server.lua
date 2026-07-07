local ESX = exports['es_extended']:getSharedObject()

local function notify(src, text, kind)
    TriggerClientEvent('ox_lib:notify', src, { title = 'Jobs Core', description = text, type = kind or 'inform' })
end

CreateThread(function()
    MySQL.query.await([[CREATE TABLE IF NOT EXISTS delfzijlrp_jobs_employees (
        id int NOT NULL AUTO_INCREMENT,
        business_id varchar(64) NOT NULL,
        identifier varchar(64) NOT NULL,
        player_name varchar(128) NOT NULL,
        role varchar(32) NOT NULL DEFAULT 'employee',
        pay_per_minute int NOT NULL DEFAULT 35,
        active tinyint NOT NULL DEFAULT 1,
        created_at timestamp NOT NULL DEFAULT current_timestamp(),
        PRIMARY KEY(id),
        UNIQUE KEY business_identifier (business_id, identifier)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]])

    MySQL.query.await([[CREATE TABLE IF NOT EXISTS delfzijlrp_jobs_shifts (
        id int NOT NULL AUTO_INCREMENT,
        business_id varchar(64) NOT NULL,
        identifier varchar(64) NOT NULL,
        player_name varchar(128) NOT NULL,
        role varchar(32) NOT NULL DEFAULT 'employee',
        started_at timestamp NOT NULL DEFAULT current_timestamp(),
        ended_at timestamp NULL DEFAULT NULL,
        minutes_worked int NOT NULL DEFAULT 0,
        payout int NOT NULL DEFAULT 0,
        status varchar(32) NOT NULL DEFAULT 'active',
        PRIMARY KEY(id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]])
end)

local function getBusiness(id)
    return exports['delfzijlrp_v3_business_core']:GetBusiness(id)
end

local function getEmployee(identifier, businessId)
    return MySQL.single.await('SELECT * FROM delfzijlrp_jobs_employees WHERE identifier = ? AND business_id = ? AND active = 1 LIMIT 1', { identifier, businessId })
end

local function getActiveShift(identifier)
    return MySQL.single.await('SELECT * FROM delfzijlrp_jobs_shifts WHERE identifier = ? AND status = ? LIMIT 1', { identifier, 'active' })
end

lib.callback.register('delfzijlrp_v3_jobs_core:server:getMine', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return {} end
    return MySQL.query.await('SELECT business_id, role, pay_per_minute FROM delfzijlrp_jobs_employees WHERE identifier = ? AND active = 1 ORDER BY business_id ASC', { xPlayer.identifier }) or {}
end)

lib.callback.register('delfzijlrp_v3_jobs_core:server:getShift', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return nil end
    return getActiveShift(xPlayer.identifier)
end)

RegisterNetEvent('delfzijlrp_v3_jobs_core:server:clockIn', function(businessId)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    businessId = tostring(businessId or ''):lower()
    if not getBusiness(businessId) then notify(src, Config.Text.noBusiness, 'error') return end
    local emp = getEmployee(xPlayer.identifier, businessId)
    if not emp then notify(src, Config.Text.noAccess, 'error') return end
    if getActiveShift(xPlayer.identifier) then notify(src, Config.Text.alreadyOnDuty, 'error') return end
    MySQL.insert.await('INSERT INTO delfzijlrp_jobs_shifts (business_id, identifier, player_name, role, status) VALUES (?, ?, ?, ?, ?)', {
        businessId, xPlayer.identifier, GetPlayerName(src), emp.role, 'active'
    })
    exports['delfzijlrp_v3_business_core']:AddLog(businessId, 'clock_in', 0, emp.role, GetPlayerName(src))
    notify(src, Config.Text.clockedIn, 'success')
end)

RegisterNetEvent('delfzijlrp_v3_jobs_core:server:clockOut', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    local shift = getActiveShift(xPlayer.identifier)
    if not shift then notify(src, Config.Text.notOnDuty, 'error') return end
    local emp = getEmployee(xPlayer.identifier, shift.business_id)
    local payRate = emp and emp.pay_per_minute or Config.DefaultPayPerMinute
    local minutes = math.floor(os.difftime(os.time(), os.time(os.date('!*t', os.time()))) / 60)
    local row = MySQL.single.await('SELECT TIMESTAMPDIFF(MINUTE, started_at, NOW()) AS mins FROM delfzijlrp_jobs_shifts WHERE id = ?', { shift.id })
    minutes = math.min(tonumber(row and row.mins or 0) or 0, Config.MaxShiftMinutes or 240)
    if minutes < 1 then minutes = 1 end
    local payout = minutes * payRate
    xPlayer.addAccountMoney('bank', payout)
    MySQL.update.await('UPDATE delfzijlrp_jobs_shifts SET ended_at = NOW(), minutes_worked = ?, payout = ?, status = ? WHERE id = ?', { minutes, payout, 'closed', shift.id })
    exports['delfzijlrp_v3_business_core']:AddLog(shift.business_id, 'clock_out', payout, tostring(minutes) .. ' minuten', GetPlayerName(src))
    notify(src, Config.Text.clockedOut .. ' +' .. payout .. ' bank', 'success')
end)

RegisterNetEvent('delfzijlrp_v3_jobs_core:server:hire', function(businessId, targetId, role, payPerMinute)
    local src = source
    local boss = ESX.GetPlayerFromId(src)
    local target = ESX.GetPlayerFromId(tonumber(targetId))
    if not boss or not target then notify(src, Config.Text.invalid, 'error') return end
    businessId = tostring(businessId or ''):lower()
    role = tostring(role or 'employee')
    payPerMinute = tonumber(payPerMinute) or Config.DefaultPayPerMinute
    local bossEmp = getEmployee(boss.identifier, businessId)
    if not bossEmp or (bossEmp.role ~= 'owner' and bossEmp.role ~= 'manager') then notify(src, Config.Text.noAccess, 'error') return end
    MySQL.insert.await('INSERT INTO delfzijlrp_jobs_employees (business_id, identifier, player_name, role, pay_per_minute, active) VALUES (?, ?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE role = VALUES(role), pay_per_minute = VALUES(pay_per_minute), active = 1, player_name = VALUES(player_name)', {
        businessId, target.identifier, GetPlayerName(targetId), role, payPerMinute, 1
    })
    exports['delfzijlrp_v3_business_core']:AddLog(businessId, 'hire', payPerMinute, GetPlayerName(targetId) .. ' als ' .. role, GetPlayerName(src))
    notify(src, Config.Text.hired, 'success')
    notify(target.source, 'Je bent aangenomen bij ' .. businessId .. ' als ' .. role, 'success')
end)

RegisterNetEvent('delfzijlrp_v3_jobs_core:server:fire', function(businessId, targetIdentifier)
    local src = source
    local boss = ESX.GetPlayerFromId(src)
    if not boss then return end
    businessId = tostring(businessId or ''):lower()
    local bossEmp = getEmployee(boss.identifier, businessId)
    if not bossEmp or (bossEmp.role ~= 'owner' and bossEmp.role ~= 'manager') then notify(src, Config.Text.noAccess, 'error') return end
    MySQL.update.await('UPDATE delfzijlrp_jobs_employees SET active = 0 WHERE business_id = ? AND identifier = ?', { businessId, targetIdentifier })
    exports['delfzijlrp_v3_business_core']:AddLog(businessId, 'fire', 0, targetIdentifier, GetPlayerName(src))
    notify(src, Config.Text.fired, 'success')
end)

exports('IsEmployee', function(identifier, businessId)
    return getEmployee(identifier, businessId) ~= nil
end)

exports('GetEmployee', function(identifier, businessId)
    return getEmployee(identifier, businessId)
end)
