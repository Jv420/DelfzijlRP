local ESX = exports['es_extended']:getSharedObject()

local function getPlayer(source)
    return ESX.GetPlayerFromId(source)
end

local function getIdentifier(source)
    local xPlayer = getPlayer(source)
    return xPlayer and xPlayer.identifier or nil
end

local function registerVisit(source)
    local identifier = getIdentifier(source)
    if not identifier then return end

    MySQL.insert.await([[INSERT INTO delfzijlrp_cityhub_visits (identifier, visits)
        VALUES (?, 1)
        ON DUPLICATE KEY UPDATE visits = visits + 1]], { identifier })
end

lib.callback.register('delfzijlrp_cityhub:server:getData', function(source)
    registerVisit(source)

    local xPlayer = getPlayer(source)
    local identifier = getIdentifier(source)
    local identity = identifier and MySQL.single.await('SELECT firstname, lastname, delfzijl_id FROM delfzijlrp_identities WHERE identifier = ? LIMIT 1', { identifier }) or nil
    local visits = identifier and MySQL.scalar.await('SELECT visits FROM delfzijlrp_cityhub_visits WHERE identifier = ? LIMIT 1', { identifier }) or 0

    return {
        server = Config.Server,
        player = {
            name = GetPlayerName(source),
            job = xPlayer and xPlayer.job and xPlayer.job.label or 'Onbekend',
            group = xPlayer and xPlayer.getGroup and xPlayer.getGroup() or 'user',
            visits = visits or 0
        },
        identity = identity,
        online = #GetPlayers(),
        rules = Config.Rules,
        starterTips = Config.StarterTips,
        locations = Config.Locations,
        shortcuts = Config.Shortcuts
    }
end)
