local function notify(text, kind)
    lib.notify({ title = 'Fanta Queue', description = text, type = kind or 'inform' })
end

local function decodeLabel(row)
    local ok, data = pcall(json.decode, row.reward_data or '{}')
    data = ok and data or {}
    if row.reward_type == 'money' then
        return ('%s | €%s %s'):format(row.player_name, data.amount or 0, data.account or 'bank')
    end
    if row.reward_type == 'item' then
        return ('%s | %sx %s'):format(row.player_name, data.count or 1, data.item or 'item')
    end
    return row.player_name .. ' | ' .. row.reward_type
end

local function openAdmin()
    local rows = lib.callback.await('delfzijlrp_v3_fanta_inbox:server:listPending', false) or {}
    local options = {}
    for _, row in ipairs(rows) do
        options[#options + 1] = {
            title = '#' .. row.id .. ' ' .. decodeLabel(row),
            description = 'Aangemaakt door: ' .. (row.created_by or 'fanta'),
            onSelect = function()
                lib.registerContext({
                    id = 'fanta_queue_item_' .. row.id,
                    title = 'Queue #' .. row.id,
                    menu = 'fanta_queue_admin',
                    options = {
                        { title = 'Goedkeuren', onSelect = function() TriggerServerEvent('delfzijlrp_v3_fanta_inbox:server:approve', row.id) end },
                        { title = 'Weigeren', onSelect = function() TriggerServerEvent('delfzijlrp_v3_fanta_inbox:server:deny', row.id) end }
                    }
                })
                lib.showContext('fanta_queue_item_' .. row.id)
            end
        }
    end
    if #options == 0 then options[1] = { title = Config.Text.empty, readOnly = true } end
    lib.registerContext({ id = 'fanta_queue_admin', title = 'Fanta Reward Queue', options = options })
    lib.showContext('fanta_queue_admin')
end

local function openMine()
    local rows = lib.callback.await('delfzijlrp_v3_fanta_inbox:server:listMine', false) or {}
    local options = {}
    for _, row in ipairs(rows) do
        options[#options + 1] = {
            title = '#' .. row.id .. ' ' .. decodeLabel(row),
            description = 'Klik om te claimen',
            onSelect = function() TriggerServerEvent('delfzijlrp_v3_fanta_inbox:server:claim', row.id) end
        }
    end
    if #options == 0 then options[1] = { title = Config.Text.empty, readOnly = true } end
    lib.registerContext({ id = 'fanta_queue_mine', title = 'Mijn Fanta beloningen', options = options })
    lib.showContext('fanta_queue_mine')
end

RegisterCommand(Config.Commands.admin, openAdmin, false)
RegisterCommand(Config.Commands.claim, openMine, false)
