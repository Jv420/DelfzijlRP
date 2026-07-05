local selectedPlayer = nil

local function msg(text, kind)
    lib.notify({ title = 'DRCC', description = text, type = kind or 'inform' })
end

local function openPlayerActions(player)
    selectedPlayer = player
    lib.registerContext({
        id = 'drcc_player_actions',
        title = player.name .. ' #' .. player.id,
        menu = 'drcc_players',
        options = {
            {
                title = 'Geld geven',
                description = 'Cash of bank',
                onSelect = function()
                    local input = lib.inputDialog('Geld geven aan ' .. player.name, {
                        { type = 'select', label = 'Account', required = true, options = {
                            { value = 'money', label = 'Contant' },
                            { value = 'bank', label = 'Bank' }
                        }},
                        { type = 'number', label = 'Bedrag', required = true, min = 1 }
                    })
                    if not input then return end
                    TriggerServerEvent('delfzijlrp_v3_controlcenter:server:money', player.id, input[1], input[2])
                end
            },
            {
                title = 'Item geven',
                description = 'ox_inventory item',
                onSelect = function()
                    local input = lib.inputDialog('Item geven aan ' .. player.name, {
                        { type = 'input', label = 'Item naam', required = true, placeholder = 'repairkit' },
                        { type = 'number', label = 'Aantal', required = true, min = 1, default = 1 }
                    })
                    if not input then return end
                    TriggerServerEvent('delfzijlrp_v3_controlcenter:server:item', player.id, input[1], input[2])
                end
            },
            {
                title = 'Voertuig cadeau geven',
                description = 'Met RDW, garage en sleutel',
                onSelect = function()
                    local input = lib.inputDialog('Voertuig geven aan ' .. player.name, {
                        { type = 'input', label = 'Spawnnaam model', required = true, placeholder = 'sultan' },
                        { type = 'input', label = 'Label', required = false, placeholder = 'Sultan Cadeau' }
                    })
                    if not input then return end
                    TriggerServerEvent('delfzijlrp_v3_controlcenter:server:vehicle', player.id, input[1], input[2])
                end
            }
        }
    })
    lib.showContext('drcc_player_actions')
end

local function openPlayers()
    local players = lib.callback.await('delfzijlrp_v3_controlcenter:server:getPlayers', false) or {}
    local options = {}
    for _, player in ipairs(players) do
        options[#options + 1] = {
            title = player.name,
            description = 'ID: ' .. player.id,
            onSelect = function() openPlayerActions(player) end
        }
    end
    if #options == 0 then
        options[1] = { title = 'Geen spelers online', readOnly = true }
    end
    lib.registerContext({ id = 'drcc_players', title = 'Spelers', menu = 'drcc_main', options = options })
    lib.showContext('drcc_players')
end

local function announce()
    local input = lib.inputDialog('Stadsbericht', {
        { type = 'textarea', label = 'Bericht', required = true, min = 3, max = 500 }
    })
    if not input then return end
    TriggerServerEvent('delfzijlrp_v3_controlcenter:server:announce', input[1])
end

local function openMain()
    local allowed = lib.callback.await('delfzijlrp_v3_controlcenter:server:canOpen', false)
    if not allowed then msg(Config.Text.noAccess, 'error') return end

    lib.registerContext({
        id = 'drcc_main',
        title = 'Delfzijl RP Control Center',
        options = {
            { title = 'Spelers beheren', description = 'Geld, items en voertuigen geven', onSelect = openPlayers },
            { title = 'Stadsbericht sturen', description = 'Melding naar alle spelers', onSelect = announce },
            { title = 'Giveaways', description = 'Basis klaar, volgende build', readOnly = true },
            { title = 'Discord logging', description = 'Stel webhook in config.lua in', readOnly = true }
        }
    })
    lib.showContext('drcc_main')
end

RegisterCommand(Config.Command, openMain, false)
