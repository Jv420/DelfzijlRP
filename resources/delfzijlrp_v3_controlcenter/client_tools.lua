local function n(t,k) lib.notify({title='DRCC Premium',description=t,type=k or 'inform'}) end

RegisterNetEvent('delfzijlrp_v3_controlcenter:client:teleport', function(x,y,z)
    local ped = PlayerPedId()
    DoScreenFadeOut(250)
    Wait(300)
    SetEntityCoords(ped, x + 0.0, y + 0.0, z + 0.0, false, false, false, false)
    Wait(200)
    DoScreenFadeIn(250)
end)

RegisterNetEvent('delfzijlrp_v3_controlcenter:client:heal', function()
    local ped = PlayerPedId()
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    ClearPedBloodDamage(ped)
    ResetPedVisibleDamage(ped)
    n('Je bent geheald.', 'success')
end)

RegisterNetEvent('delfzijlrp_v3_controlcenter:client:revive', function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, GetEntityHeading(ped), true, false)
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    ClearPedTasksImmediately(ped)
    ClearPedBloodDamage(ped)
    TriggerEvent('esx_ambulancejob:revive')
    n('Je bent gerevived.', 'success')
end)

RegisterNetEvent('delfzijlrp_v3_controlcenter:client:freeze', function(state)
    local ped = PlayerPedId()
    FreezeEntityPosition(ped, state)
    SetPlayerControl(PlayerId(), not state, 0)
    n(state and 'Je bent tijdelijk bevroren.' or 'Je bent vrijgegeven.', state and 'warning' or 'success')
end)

local function getPlayers()
    return lib.callback.await('delfzijlrp_v3_controlcenter:server:getPlayers', false) or {}
end

local function pickPlayer(title, cb)
    local players = getPlayers()
    local opts = {}
    for _, p in ipairs(players) do
        opts[#opts+1] = { title = p.name, description = 'ID: '..p.id, onSelect = function() cb(p) end }
    end
    if #opts == 0 then opts[1] = { title = 'Geen spelers online', readOnly = true } end
    lib.registerContext({ id = 'drcc_pick_player', title = title, menu = 'drcc_premium', options = opts })
    lib.showContext('drcc_pick_player')
end

local function moneyAll()
    local i = lib.inputDialog('Iedereen geld geven', {
        { type='select', label='Account', required=true, options={{value='bank',label='Bank'},{value='cash',label='Contant'}} },
        { type='number', label='Bedrag', required=true, min=1 }
    })
    if i then TriggerServerEvent('delfzijlrp_v3_controlcenter:server:moneyAll', i[1], i[2]) end
end

local function logsMenu()
    local logs = lib.callback.await('delfzijlrp_v3_controlcenter:server:getLogs', false) or {}
    local opts = {}
    for _, l in ipairs(logs) do
        opts[#opts+1] = { title = l.action .. ' | ' .. l.target_name, description = (l.details or '') .. ' | ' .. tostring(l.created_at), readOnly = true }
    end
    if #opts == 0 then opts[1] = { title = 'Nog geen logs', readOnly = true } end
    lib.registerContext({ id='drcc_logs', title='Laatste DRCC logs', menu='drcc_premium', options=opts })
    lib.showContext('drcc_logs')
end

local function disableCode()
    local i = lib.inputDialog('Claimcode uitschakelen', {{ type='input', label='Code', required=true }})
    if i then TriggerServerEvent('delfzijlrp_v3_controlcenter:server:clearCode', i[1]) end
end

local function premiumMenu()
    local ok = lib.callback.await('delfzijlrp_v3_controlcenter:server:canOpen', false)
    if not ok then n(Config.Text.noAccess, 'error') return end
    lib.registerContext({ id='drcc_premium', title='DRCC Premium Tools', options={
        { title='Heal speler', onSelect=function() pickPlayer('Heal speler', function(p) TriggerServerEvent('delfzijlrp_v3_controlcenter:server:heal', p.id) end) end },
        { title='Revive speler', onSelect=function() pickPlayer('Revive speler', function(p) TriggerServerEvent('delfzijlrp_v3_controlcenter:server:revive', p.id) end) end },
        { title='Bring speler naar jou', onSelect=function() pickPlayer('Bring speler', function(p) TriggerServerEvent('delfzijlrp_v3_controlcenter:server:bring', p.id) end) end },
        { title='Ga naar speler', onSelect=function() pickPlayer('Ga naar speler', function(p) TriggerServerEvent('delfzijlrp_v3_controlcenter:server:goto', p.id) end) end },
        { title='Freeze/unfreeze speler', onSelect=function() pickPlayer('Freeze speler', function(p) TriggerServerEvent('delfzijlrp_v3_controlcenter:server:freeze', p.id) end) end },
        { title='Iedereen geld geven', onSelect=moneyAll },
        { title='Claimcode uitschakelen', onSelect=disableCode },
        { title='DRCC logs bekijken', onSelect=logsMenu }
    }})
    lib.showContext('drcc_premium')
end

RegisterCommand('drccplus', premiumMenu, false)
