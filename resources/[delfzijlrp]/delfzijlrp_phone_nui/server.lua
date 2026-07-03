local ESX = exports['es_extended']:getSharedObject()

local function getPlayer(source)
    return ESX.GetPlayerFromId(source)
end

local function getIdentifier(source)
    local xPlayer = getPlayer(source)
    return xPlayer and xPlayer.identifier or nil
end

local function hasPhone(source)
    if not Config.RequireItem then return true end
    return (exports.ox_inventory:GetItemCount(source, Config.PhoneItem) or 0) > 0
end

local function ensureSettings(identifier)
    local settings = MySQL.single.await('SELECT * FROM delfzijlrp_phone_settings WHERE identifier = ? LIMIT 1', { identifier })
    if settings then return settings end

    MySQL.insert.await('INSERT INTO delfzijlrp_phone_settings (identifier) VALUES (?)', { identifier })
    return { identifier = identifier, wallpaper = 'delfzijl', accent = 'yellow' }
end

lib.callback.register('delfzijlrp_phone_nui:server:getData', function(source)
    if not hasPhone(source) then
        return { allowed = false, reason = Config.Text.noPhone }
    end

    local xPlayer = getPlayer(source)
    local identifier = getIdentifier(source)
    if not xPlayer or not identifier then return { allowed = false } end

    local profile = MySQL.single.await('SELECT * FROM delfzijlrp_identities WHERE identifier = ? LIMIT 1', { identifier })
    local bank = MySQL.single.await('SELECT * FROM delfzijlrp_bank_accounts WHERE identifier = ? LIMIT 1', { identifier })
    local transactions = MySQL.query.await('SELECT * FROM delfzijlrp_bank_transactions WHERE identifier = ? ORDER BY created_at DESC LIMIT 5', { identifier }) or {}
    local settings = ensureSettings(identifier)

    return {
        allowed = true,
        brand = Config.Brand,
        apps = Config.Apps,
        player = {
            name = GetPlayerName(source),
            cash = xPlayer.getMoney(),
            bank = xPlayer.getAccount('bank').money
        },
        profile = profile,
        bankAccount = bank,
        transactions = transactions,
        settings = settings
    }
end)

RegisterNetEvent('delfzijlrp_phone_nui:server:saveSettings', function(settings)
    local source = source
    local identifier = getIdentifier(source)
    if not identifier or type(settings) ~= 'table' then return end

    MySQL.insert.await([[INSERT INTO delfzijlrp_phone_settings (identifier, wallpaper, accent)
        VALUES (?, ?, ?)
        ON DUPLICATE KEY UPDATE wallpaper = VALUES(wallpaper), accent = VALUES(accent)]], {
        identifier,
        settings.wallpaper or 'delfzijl',
        settings.accent or 'yellow'
    })
end)
