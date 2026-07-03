local ESX = exports['es_extended']:getSharedObject()
local recentSearches = {}

local function rollReward()
    local total = 0
    for _, reward in ipairs(Config.VehicleTheft.rewards) do
        total += reward.chance
    end

    local roll = math.random(1, total)
    local current = 0

    for _, reward in ipairs(Config.VehicleTheft.rewards) do
        current += reward.chance
        if roll <= current then
            return reward
        end
    end

    return { name = 'nothing', min = 0, max = 0, chance = 100 }
end

local function countPolice()
    local count = 0
    local players = ESX.GetExtendedPlayers('job', 'police')

    for _, _ in pairs(players) do
        count += 1
    end

    return count
end

lib.callback.register('delfzijlrp_crime:server:hasLockpick', function(source)
    local normal = exports.ox_inventory:GetItemCount(source, Config.VehicleTheft.requiredItem) or 0
    local advanced = exports.ox_inventory:GetItemCount(source, Config.VehicleTheft.advancedItem) or 0

    return normal > 0 or advanced > 0
end)

CreateThread(function()
    Wait(1000)

    if Config.BlackMarket.enabled then
        exports.ox_inventory:RegisterShop('delfzijlrp_blackmarket', {
            name = Config.BlackMarket.label,
            inventory = Config.BlackMarket.items,
            locations = { Config.BlackMarket.location }
        })

        print('[delfzijlrp_crime] Blackmarket geregistreerd.')
    end
end)

RegisterNetEvent('delfzijlrp_crime:server:searchVehicle', function(netId, coords)
    local source = source
    if not Config.VehicleTheft.enabled then return end

    if countPolice() < Config.VehicleTheft.minPolice then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Delfzijl RP',
            description = 'Er is momenteel te weinig politie in dienst.',
            type = 'error'
        })
        return
    end

    local hasNormal = (exports.ox_inventory:GetItemCount(source, Config.VehicleTheft.requiredItem) or 0) > 0
    local hasAdvanced = (exports.ox_inventory:GetItemCount(source, Config.VehicleTheft.advancedItem) or 0) > 0

    if not hasNormal and not hasAdvanced then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Delfzijl RP',
            description = Config.Notifications.noItem,
            type = 'error'
        })
        return
    end

    local searchKey = tostring(netId)
    local now = os.time()
    if recentSearches[searchKey] and recentSearches[searchKey] > now then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Delfzijl RP',
            description = Config.Notifications.alreadySearched,
            type = 'error'
        })
        return
    end

    recentSearches[searchKey] = now + 20 * 60

    if math.random(1, 100) <= Config.VehicleTheft.consumeChance and hasNormal then
        exports.ox_inventory:RemoveItem(source, Config.VehicleTheft.requiredItem, 1)
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Delfzijl RP',
            description = Config.Notifications.failed,
            type = 'warning'
        })
    end

    if math.random(1, 100) <= Config.VehicleTheft.policeAlertChance then
        local policePlayers = ESX.GetExtendedPlayers('job', 'police')
        for _, xPlayer in pairs(policePlayers) do
            TriggerClientEvent('delfzijlrp_crime:client:policeAlert', xPlayer.source, coords)
        end
    end

    local reward = rollReward()

    if reward.name == 'nothing' then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Delfzijl RP',
            description = 'Je hebt niets bruikbaars gevonden.',
            type = 'inform'
        })
        return
    end

    local amount = math.random(reward.min, reward.max)

    if reward.name == 'money' then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            xPlayer.addMoney(amount)
        end
    else
        exports.ox_inventory:AddItem(source, reward.name, amount)
    end

    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Delfzijl RP',
        description = Config.Notifications.success,
        type = 'success'
    })
end)
