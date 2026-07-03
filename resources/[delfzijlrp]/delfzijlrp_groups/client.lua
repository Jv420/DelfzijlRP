local function notify(message, type)
    lib.notify({ title = 'Delfzijl RP Groups', description = message, type = type or 'inform' })
end

local function typeOptions()
    local options = {}
    for value, label in pairs(Config.GroupTypes) do
        options[#options + 1] = { value = value, label = label }
    end
    return options
end

local function rankOptions()
    local options = {}
    for value, rank in pairs(Config.Ranks) do
        options[#options + 1] = { value = value, label = rank.label }
    end
    return options
end

local function createGroupDialog()
    local input = lib.inputDialog('Groep aanmaken', {
        { type = 'input', label = 'Groepsnaam', required = true, min = 3, max = 96 },
        { type = 'select', label = 'Type groep', required = true, options = typeOptions() }
    })
    if input then
        TriggerServerEvent('delfzijlrp_groups:server:createGroup', { name = input[1], group_type = input[2] })
    end
end

local function amountDialog(title)
    local input = lib.inputDialog(title, {
        { type = 'number', label = 'Bedrag', required = true, min = 1, max = 10000000 }
    })
    return input and tonumber(input[1]) or nil
end

local function addMemberDialog(groupId)
    local input = lib.inputDialog('Lid toevoegen', {
        { type = 'number', label = 'Speler ID', required = true, min = 1 },
        { type = 'select', label = 'Rang', required = true, options = rankOptions() }
    })
    if input then
        TriggerServerEvent('delfzijlrp_groups:server:addMember', groupId, input[1], input[2])
    end
end

local function openGroup(groupId)
    local data = lib.callback.await('delfzijlrp_groups:server:getGroup', false, groupId)
    if not data then
        notify(Config.Text.noAccess, 'error')
        return
    end

    local group = data.group
    local options = {
        { title = group.name, description = ('%s | Saldo: €%s'):format(Config.GroupTypes[group.group_type] or group.group_type, group.balance), icon = 'people-group', readOnly = true },
        { title = 'Groepsopslag openen', icon = 'box-archive', onSelect = function() TriggerServerEvent('delfzijlrp_groups:server:openStash', group.id) end },
        { title = 'Geld storten', icon = 'money-bill-transfer', onSelect = function()
            local amount = amountDialog('Geld storten')
            if amount then TriggerServerEvent('delfzijlrp_groups:server:deposit', group.id, amount) end
        end },
        { title = 'Geld opnemen', icon = 'money-bill-wave', onSelect = function()
            local amount = amountDialog('Geld opnemen')
            if amount then TriggerServerEvent('delfzijlrp_groups:server:withdraw', group.id, amount) end
        end },
        { title = 'Lid toevoegen', icon = 'user-plus', onSelect = function() addMemberDialog(group.id) end }
    }

    for _, member in ipairs(data.members or {}) do
        local name = member.firstname and (member.firstname .. ' ' .. member.lastname) or member.identifier
        options[#options + 1] = {
            title = name,
            description = ('Rang: %s'):format(Config.Ranks[member.rank] and Config.Ranks[member.rank].label or member.rank),
            icon = 'user',
            readOnly = true
        }
    end

    lib.registerContext({ id = 'delfzijlrp_group_detail', title = group.name, options = options })
    lib.showContext('delfzijlrp_group_detail')
end

local function openMyGroups()
    local groups = lib.callback.await('delfzijlrp_groups:server:getMyGroups', false) or {}
    if #groups == 0 then
        notify(Config.Text.noGroups, 'inform')
        return
    end

    local options = {}
    for _, group in ipairs(groups) do
        options[#options + 1] = {
            title = group.name,
            description = ('%s | %s'):format(Config.GroupTypes[group.group_type] or group.group_type, Config.Ranks[group.rank] and Config.Ranks[group.rank].label or group.rank),
            icon = 'people-group',
            onSelect = function() openGroup(group.id) end
        }
    end

    lib.registerContext({ id = 'delfzijlrp_my_groups', title = 'Mijn groepen', options = options })
    lib.showContext('delfzijlrp_my_groups')
end

local function openOffice()
    lib.registerContext({
        id = 'delfzijlrp_groups_office',
        title = Config.Office.label,
        options = {
            { title = ('Groep aanmaken (€%s)'):format(Config.CreatePrice), icon = 'users-gear', onSelect = createGroupDialog },
            { title = 'Mijn groepen', icon = 'people-group', onSelect = openMyGroups }
        }
    })
    lib.showContext('delfzijlrp_groups_office')
end

CreateThread(function()
    Wait(1500)

    if Config.Office.blip then
        local blip = AddBlipForCoord(Config.Office.coords.x, Config.Office.coords.y, Config.Office.coords.z)
        SetBlipSprite(blip, Config.Office.blip.sprite)
        SetBlipColour(blip, Config.Office.blip.color)
        SetBlipScale(blip, Config.Office.blip.scale)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(Config.Office.label)
        EndTextCommandSetBlipName(blip)
    end

    exports.ox_target:addSphereZone({
        coords = Config.Office.coords,
        radius = Config.Office.radius,
        debug = Config.Debug,
        options = {{ name = 'groups_office', icon = 'fa-solid fa-people-group', label = Config.Text.openOffice, onSelect = openOffice }}
    })

    for _, location in ipairs(Config.Locations) do
        exports.ox_target:addSphereZone({
            coords = location.coords,
            radius = location.radius,
            debug = Config.Debug,
            options = {{ name = 'groups_location_' .. location.id, icon = 'fa-solid fa-location-dot', label = Config.Text.openLocation, onSelect = openMyGroups }}
        })
    end
end)

RegisterCommand(Config.Command, openMyGroups, false)
RegisterNetEvent('delfzijlrp_groups:client:openStash', function(stashId)
    exports.ox_inventory:openInventory('stash', stashId)
end)
