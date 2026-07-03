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
        title = 'Delfzijl RP Groups',
        description = message,
        type = type or 'inform'
    })
end

local function slugify(name)
    return (name or ''):lower():gsub('[^%w%s%-]', ''):gsub('%s+', '-'):sub(1, 96)
end

local function pay(source, amount)
    local xPlayer = getPlayer(source)
    if not xPlayer then return false end
    if xPlayer.getMoney() >= amount then xPlayer.removeMoney(amount) return true end
    if xPlayer.getAccount('bank').money >= amount then xPlayer.removeAccountMoney('bank', amount) return true end
    return false
end

local function getMember(source, groupId)
    local identifier = getIdentifier(source)
    if not identifier then return nil end
    return MySQL.single.await('SELECT * FROM delfzijlrp_group_members WHERE group_id = ? AND identifier = ? LIMIT 1', { groupId, identifier })
end

local function rankLevel(rank)
    return Config.Ranks[rank] and Config.Ranks[rank].level or 0
end

local function canManage(source, groupId)
    local member = getMember(source, groupId)
    return member and rankLevel(member.rank) >= 60
end

local function canLead(source, groupId)
    local member = getMember(source, groupId)
    return member and rankLevel(member.rank) >= 80
end

local function logGroup(groupId, source, action, details)
    MySQL.insert.await('INSERT INTO delfzijlrp_group_logs (group_id, actor_identifier, action, details) VALUES (?, ?, ?, ?)', {
        groupId,
        getIdentifier(source),
        action,
        details
    })
end

lib.callback.register('delfzijlrp_groups:server:getMyGroups', function(source)
    local identifier = getIdentifier(source)
    if not identifier then return {} end

    return MySQL.query.await([[SELECT g.*, m.rank
        FROM delfzijlrp_groups g
        JOIN delfzijlrp_group_members m ON m.group_id = g.id
        WHERE m.identifier = ? AND g.active = 1
        ORDER BY g.name ASC]], { identifier }) or {}
end)

lib.callback.register('delfzijlrp_groups:server:getGroup', function(source, groupId)
    groupId = tonumber(groupId)
    if not groupId then return nil end
    local member = getMember(source, groupId)
    if not member then return nil end

    local group = MySQL.single.await('SELECT * FROM delfzijlrp_groups WHERE id = ? LIMIT 1', { groupId })
    local members = MySQL.query.await([[SELECT m.*, i.firstname, i.lastname, i.delfzijl_id
        FROM delfzijlrp_group_members m
        LEFT JOIN delfzijlrp_identities i ON i.identifier = m.identifier
        WHERE m.group_id = ? ORDER BY m.rank ASC]], { groupId }) or {}

    return { group = group, members = members, rank = member.rank }
end)

RegisterNetEvent('delfzijlrp_groups:server:createGroup', function(data)
    local source = source
    local identifier = getIdentifier(source)
    if not identifier or type(data) ~= 'table' then return end

    local name = tostring(data.name or '')
    local groupType = data.group_type or 'other'
    if #name < 3 or not Config.GroupTypes[groupType] then
        notify(source, Config.Text.invalidInput, 'error')
        return
    end

    if not pay(source, Config.CreatePrice) then
        notify(source, Config.Text.noMoney, 'error')
        return
    end

    local slug = slugify(name)
    if MySQL.scalar.await('SELECT id FROM delfzijlrp_groups WHERE slug = ? LIMIT 1', { slug }) then
        slug = slug .. '-' .. tostring(math.random(100, 999))
    end

    local groupId = MySQL.insert.await('INSERT INTO delfzijlrp_groups (name, slug, group_type, owner_identifier) VALUES (?, ?, ?, ?)', {
        name,
        slug,
        groupType,
        identifier
    })

    MySQL.insert.await('INSERT INTO delfzijlrp_group_members (group_id, identifier, rank) VALUES (?, ?, ?)', { groupId, identifier, 'owner' })
    logGroup(groupId, source, 'create_group', name)
    notify(source, Config.Text.created, 'success')
end)

RegisterNetEvent('delfzijlrp_groups:server:addMember', function(groupId, targetId, rank)
    local source = source
    groupId = tonumber(groupId)
    targetId = tonumber(targetId)
    if not groupId or not targetId or not canManage(source, groupId) then
        notify(source, Config.Text.notManager, 'error')
        return
    end

    local target = getPlayer(targetId)
    if not target then
        notify(source, Config.Text.playerNotFound, 'error')
        return
    end

    if not Config.Ranks[rank] then rank = 'member' end
    MySQL.insert.await('INSERT IGNORE INTO delfzijlrp_group_members (group_id, identifier, rank) VALUES (?, ?, ?)', { groupId, target.identifier, rank })
    logGroup(groupId, source, 'add_member', target.identifier .. ':' .. rank)
    notify(source, Config.Text.memberAdded, 'success')
    notify(target.source, Config.Text.memberAdded, 'success')
end)

RegisterNetEvent('delfzijlrp_groups:server:removeMember', function(groupId, identifier)
    local source = source
    groupId = tonumber(groupId)
    if not groupId or not canLead(source, groupId) then
        notify(source, Config.Text.notManager, 'error')
        return
    end

    MySQL.update.await('DELETE FROM delfzijlrp_group_members WHERE group_id = ? AND identifier = ? AND rank != ?', { groupId, identifier, 'owner' })
    logGroup(groupId, source, 'remove_member', identifier)
    notify(source, Config.Text.memberRemoved, 'success')
end)

RegisterNetEvent('delfzijlrp_groups:server:deposit', function(groupId, amount)
    local source = source
    groupId = tonumber(groupId)
    amount = tonumber(amount) or 0
    if amount <= 0 or not getMember(source, groupId) then return end

    if not pay(source, amount) then
        notify(source, Config.Text.noMoney, 'error')
        return
    end

    MySQL.update.await('UPDATE delfzijlrp_groups SET balance = balance + ? WHERE id = ?', { amount, groupId })
    logGroup(groupId, source, 'deposit', tostring(amount))
    notify(source, Config.Text.deposited, 'success')
end)

RegisterNetEvent('delfzijlrp_groups:server:withdraw', function(groupId, amount)
    local source = source
    local xPlayer = getPlayer(source)
    groupId = tonumber(groupId)
    amount = tonumber(amount) or 0
    if not xPlayer or amount <= 0 or not canManage(source, groupId) then
        notify(source, Config.Text.notManager, 'error')
        return
    end

    local balance = MySQL.scalar.await('SELECT balance FROM delfzijlrp_groups WHERE id = ? LIMIT 1', { groupId }) or 0
    if balance < amount then
        notify(source, Config.Text.noMoney, 'error')
        return
    end

    MySQL.update.await('UPDATE delfzijlrp_groups SET balance = balance - ? WHERE id = ?', { amount, groupId })
    xPlayer.addAccountMoney('bank', amount)
    logGroup(groupId, source, 'withdraw', tostring(amount))
    notify(source, Config.Text.withdrawn, 'success')
end)

RegisterNetEvent('delfzijlrp_groups:server:openStash', function(groupId)
    local source = source
    groupId = tonumber(groupId)
    if not groupId or not getMember(source, groupId) then
        notify(source, Config.Text.noAccess, 'error')
        return
    end

    local group = MySQL.single.await('SELECT * FROM delfzijlrp_groups WHERE id = ? LIMIT 1', { groupId })
    if not group then return end

    local stashId = ('group_%s'):format(groupId)
    exports.ox_inventory:RegisterStash(stashId, group.name .. ' Opslag', Config.Stash.slots, Config.Stash.weight)
    TriggerClientEvent('delfzijlrp_groups:client:openStash', source, stashId)
end)
