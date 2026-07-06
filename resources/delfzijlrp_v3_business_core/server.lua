local ESX = exports['es_extended']:getSharedObject()

local function notify(src, text, kind)
    TriggerClientEvent('ox_lib:notify', src, { title = 'Business Core', description = text, type = kind or 'inform' })
end

CreateThread(function()
    MySQL.query.await([[CREATE TABLE IF NOT EXISTS delfzijlrp_businesses (
        id varchar(64) NOT NULL,
        label varchar(128) NOT NULL,
        type varchar(32) NOT NULL,
        owner_identifier varchar(64) DEFAULT NULL,
        owner_name varchar(128) DEFAULT NULL,
        balance int NOT NULL DEFAULT 0,
        turnover int NOT NULL DEFAULT 0,
        tax_rate int NOT NULL DEFAULT 21,
        active tinyint NOT NULL DEFAULT 1,
        created_at timestamp NOT NULL DEFAULT current_timestamp(),
        updated_at timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
        PRIMARY KEY(id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]])

    MySQL.query.await([[CREATE TABLE IF NOT EXISTS delfzijlrp_business_employees (
        id int NOT NULL AUTO_INCREMENT,
        business_id varchar(64) NOT NULL,
        identifier varchar(64) NOT NULL,
        player_name varchar(128) NOT NULL,
        role varchar(32) NOT NULL DEFAULT 'employee',
        salary int NOT NULL DEFAULT 0,
        active tinyint NOT NULL DEFAULT 1,
        created_at timestamp NOT NULL DEFAULT current_timestamp(),
        PRIMARY KEY(id),
        UNIQUE KEY business_employee (business_id, identifier)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]])

    MySQL.query.await([[CREATE TABLE IF NOT EXISTS delfzijlrp_business_stock (
        id int NOT NULL AUTO_INCREMENT,
        business_id varchar(64) NOT NULL,
        item varchar(64) NOT NULL,
        label varchar(128) DEFAULT NULL,
        amount int NOT NULL DEFAULT 0,
        price int NOT NULL DEFAULT 0,
        PRIMARY KEY(id),
        UNIQUE KEY business_item (business_id, item)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]])

    MySQL.query.await([[CREATE TABLE IF NOT EXISTS delfzijlrp_business_logs (
        id int NOT NULL AUTO_INCREMENT,
        business_id varchar(64) NOT NULL,
        action varchar(64) NOT NULL,
        amount int DEFAULT 0,
        details text NULL,
        created_by varchar(128) DEFAULT NULL,
        created_at timestamp NOT NULL DEFAULT current_timestamp(),
        PRIMARY KEY(id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]])

    for _, b in ipairs(Config.DefaultBusinesses) do
        MySQL.insert.await('INSERT IGNORE INTO delfzijlrp_businesses (id, label, type, balance, tax_rate) VALUES (?, ?, ?, ?, ?)', {
            b.id, b.label, b.type, Config.DefaultBalance, Config.DefaultTaxRate
        })
    end
end)

local function getBusiness(id)
    id = tostring(id or ''):lower()
    if id == '' then return nil end
    return MySQL.single.await('SELECT * FROM delfzijlrp_businesses WHERE id = ? LIMIT 1', { id })
end

local function isMember(identifier, businessId)
    local row = MySQL.single.await('SELECT * FROM delfzijlrp_business_employees WHERE business_id = ? AND identifier = ? AND active = 1 LIMIT 1', { businessId, identifier })
    return row
end

local function addLog(businessId, action, amount, details, by)
    MySQL.insert.await('INSERT INTO delfzijlrp_business_logs (business_id, action, amount, details, created_by) VALUES (?, ?, ?, ?, ?)', {
        businessId, action, amount or 0, details or '', by or 'system'
    })
end

lib.callback.register('delfzijlrp_v3_business_core:server:list', function(source)
    return MySQL.query.await('SELECT id, label, type, owner_name, balance, turnover, active FROM delfzijlrp_businesses ORDER BY label ASC') or {}
end)

lib.callback.register('delfzijlrp_v3_business_core:server:get', function(source, id)
    local business = getBusiness(id)
    if not business then return nil end
    business.employees = MySQL.query.await('SELECT player_name, role, salary, active FROM delfzijlrp_business_employees WHERE business_id = ? ORDER BY role DESC, player_name ASC', { business.id }) or {}
    business.stock = MySQL.query.await('SELECT item, label, amount, price FROM delfzijlrp_business_stock WHERE business_id = ? ORDER BY label ASC', { business.id }) or {}
    business.logs = MySQL.query.await('SELECT action, amount, details, created_by, created_at FROM delfzijlrp_business_logs WHERE business_id = ? ORDER BY id DESC LIMIT 10', { business.id }) or {}
    return business
end)

RegisterNetEvent('delfzijlrp_v3_business_core:server:claimOwner', function(businessId)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    local business = getBusiness(businessId)
    if not business then notify(src, Config.Text.notFound, 'error') return end
    if business.owner_identifier and business.owner_identifier ~= '' then notify(src, 'Dit bedrijf heeft al een eigenaar.', 'error') return end
    local identity = exports['delfzijlrp_v3_identity_engine']:EnsureIdentity(src)
    MySQL.update.await('UPDATE delfzijlrp_businesses SET owner_identifier = ?, owner_name = ? WHERE id = ?', {
        xPlayer.identifier, identity and identity.display_name or GetPlayerName(src), business.id
    })
    MySQL.insert.await('INSERT IGNORE INTO delfzijlrp_business_employees (business_id, identifier, player_name, role, salary) VALUES (?, ?, ?, ?, ?)', {
        business.id, xPlayer.identifier, GetPlayerName(src), 'owner', 0
    })
    addLog(business.id, 'owner_claim', 0, 'Eigenaar ingesteld', GetPlayerName(src))
    exports['delfzijlrp_v3_core']:AddLog(xPlayer.identifier, GetPlayerName(src), 'business_owner', business.id)
    notify(src, Config.Text.updated, 'success')
end)

RegisterNetEvent('delfzijlrp_v3_business_core:server:addMoney', function(businessId, amount)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    amount = tonumber(amount) or 0
    if amount <= 0 then notify(src, Config.Text.invalid, 'error') return end
    local member = isMember(xPlayer.identifier, businessId)
    if not member then notify(src, Config.Text.noAccess, 'error') return end
    if xPlayer.getMoney() < amount then notify(src, 'Niet genoeg contant geld.', 'error') return end
    xPlayer.removeMoney(amount)
    MySQL.update.await('UPDATE delfzijlrp_businesses SET balance = balance + ?, turnover = turnover + ? WHERE id = ?', { amount, amount, businessId })
    addLog(businessId, 'deposit', amount, 'Inleg in bedrijfskas', GetPlayerName(src))
    notify(src, Config.Text.updated, 'success')
end)

exports('GetBusiness', function(id) return getBusiness(id) end)
exports('AddLog', function(businessId, action, amount, details, by) addLog(businessId, action, amount, details, by) end)
exports('IsMember', function(identifier, businessId) return isMember(identifier, businessId) end)
