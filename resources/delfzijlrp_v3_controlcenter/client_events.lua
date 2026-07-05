local function n(t,k) lib.notify({title='DRCC Events',description=t,type=k or 'inform'}) end

RegisterNetEvent('delfzijlrp_v3_controlcenter:client:setWeather', function(weather)
    ClearOverrideWeather()
    ClearWeatherTypePersist()
    SetWeatherTypePersist(weather)
    SetWeatherTypeNow(weather)
    SetWeatherTypeNowPersist(weather)
end)

RegisterNetEvent('delfzijlrp_v3_controlcenter:client:setTime', function(hour)
    NetworkOverrideClockTime(hour, 0, 0)
end)

local function presets()
    return lib.callback.await('delfzijlrp_v3_controlcenter:server:getPresets', false) or {}
end

local function giveawayMenu()
    local p = presets()
    local choices = {}
    for _, pr in ipairs(p) do choices[#choices+1] = { value = pr.id, label = pr.label } end
    local i = lib.inputDialog('Giveaway starten', {
        { type='input', label='Titel', required=true, placeholder='Weekend Giveaway' },
        { type='select', label='Pakket', required=true, options=choices },
        { type='number', label='Duur in seconden', required=true, min=10, default=300 }
    })
    if i then TriggerServerEvent('delfzijlrp_v3_controlcenter:server:startGiveaway', i[1], i[2], i[3]) end
end

local function weatherMenu()
    local i = lib.inputDialog('Weer aanpassen', {{ type='select', label='Weer', required=true, options={
        {value='CLEAR',label='Helder'}, {value='EXTRASUNNY',label='Zonnig'}, {value='CLOUDS',label='Bewolkt'},
        {value='RAIN',label='Regen'}, {value='THUNDER',label='Onweer'}, {value='FOGGY',label='Mist'}, {value='SNOW',label='Sneeuw'}
    }}})
    if i then TriggerServerEvent('delfzijlrp_v3_controlcenter:server:setWeather', i[1]) end
end

local function timeMenu()
    local i = lib.inputDialog('Tijd aanpassen', {{ type='number', label='Uur 0-23', required=true, min=0, max=23, default=12 }})
    if i then TriggerServerEvent('delfzijlrp_v3_controlcenter:server:setTime', i[1]) end
end

local function getPlayers()
    return lib.callback.await('delfzijlrp_v3_controlcenter:server:getPlayers', false) or {}
end

local function noteMenu()
    local players = getPlayers()
    local opts = {}
    for _, p in ipairs(players) do
        opts[#opts+1] = { title=p.name, description='ID: '..p.id, onSelect=function()
            local i = lib.inputDialog('Staff note voor '..p.name, {{ type='textarea', label='Notitie', required=true, min=3, max=1000 }})
            if i then TriggerServerEvent('delfzijlrp_v3_controlcenter:server:addNote', p.id, i[1]) end
        end }
    end
    if #opts == 0 then opts[1] = { title='Geen spelers online', readOnly=true } end
    lib.registerContext({ id='drcc_notes', title='Staff notes', menu='drcc100', options=opts })
    lib.showContext('drcc_notes')
end

local function serverCheck()
    local checks = lib.callback.await('delfzijlrp_v3_controlcenter:server:serverCheck', false) or {}
    local opts = {}
    for _, c in ipairs(checks) do opts[#opts+1] = { title=c.label, description=tostring(c.value), readOnly=true } end
    lib.registerContext({ id='drcc_check', title='Servercheck', menu='drcc100', options=opts })
    lib.showContext('drcc_check')
end

local function menu100()
    local ok = lib.callback.await('delfzijlrp_v3_controlcenter:server:canOpen', false)
    if not ok then n(Config.Text.noAccess,'error') return end
    lib.registerContext({ id='drcc100', title='DRCC 100% Tools', options={
        { title='Giveaway starten', description='Automatische winnaar + pakket', onSelect=giveawayMenu },
        { title='Weer aanpassen', description='Zon, regen, mist, sneeuw', onSelect=weatherMenu },
        { title='Tijd aanpassen', description='Dag/nacht instellen', onSelect=timeMenu },
        { title='Staff note toevoegen', description='Notitie bij speler opslaan', onSelect=noteMenu },
        { title='Servercheck', description='Check belangrijke resources', onSelect=serverCheck },
        { title='Premium tools', description='Gebruik /drccplus voor heal/bring/freeze/logs', readOnly=true },
        { title='Basis panel', description='Gebruik /drcc voor speler gifts/codes', readOnly=true }
    }})
    lib.showContext('drcc100')
end

RegisterCommand('drcc100', menu100, false)
