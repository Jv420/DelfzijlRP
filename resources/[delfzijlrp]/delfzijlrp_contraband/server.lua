local ESX = exports['es_extended']:getSharedObject()

local function notify(source, description, type)
    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Delfzijl RP',
        description = description,
        type = type or 'inform'
    })
end

local function countPolice()
    local count = 0
    local players = ESX.GetExtendedPlayers('job', 'police')

    for _, _ in pairs(players) do
        count += 1
    end

    return count
end

local function alertPolice(coords)
    if math.random(1, 100) > Config.PoliceAlertChance then return end

    local policePlayers = ESX.GetExtendedPlayers('job', 'police')
    for _, xPlayer in pairs(policePlayers) do
        TriggerClientEvent('delfzijlrp_contraband:client:policeAlert', xPlayer.source, coords)
    end
end

RegisterNetEvent('delfzijlrp_contraband:server:completeAction', function(zoneType)
    local source = source
    local zone = Config.Zones[zoneType]
    if not zone then return end

    if countPolice() < Config.MinPoliceOnline then
        notify(source, Config.Notifications.noPolice, 'error')
        return
    end

    if zone.input then
        local count = exports.ox_inventory:GetItemCount(source, zone.input.item) or 0
        if count < zone.input.amount then
            notify(source, Config.Notifications.noItem, 'error')
            return
        end

        exports.ox_inventory:RemoveItem(source, zone.input.item, zone.input.amount)
    end

    if zone.reward then
        local amount = math.random(zone.reward.min, zone.reward.max)
        exports.ox_inventory:AddItem(source, zone.reward.item, amount)

        if zoneType == 'collect' then
            notify(source, Config.Notifications.successCollect, 'success')
        else
            notify(source, Config.Notifications.successProcess, 'success')
        end
    end

    if zone.payout then
        local amount = math.random(zone.payout.min, zone.payout.max)
        local xPlayer = ESX.GetPlayerFromId(source)

        if xPlayer then
            xPlayer.addAccountMoney(zone.payout.account, amount)
        end

        notify(source, Config.Notifications.successSell, 'success')
        alertPolice(zone.coords)
    end
end)
