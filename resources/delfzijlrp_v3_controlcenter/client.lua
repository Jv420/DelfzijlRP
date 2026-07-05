local function msg(t,k) lib.notify({title='DRCC',description=t,type=k or 'inform'}) end

local function playersMenu()
    local players=lib.callback.await('delfzijlrp_v3_controlcenter:server:getPlayers',false) or {}
    local opts={}
    for _,p in ipairs(players) do
        opts[#opts+1]={title=p.name,description='ID: '..p.id,onSelect=function()
            lib.registerContext({id='drcc_actions',title=p.name,menu='drcc_players',options={
                {title='Geld geven',onSelect=function()
                    local i=lib.inputDialog('Geld geven',{{type='select',label='Account',required=true,options={{value='money',label='Contant'},{value='bank',label='Bank'}}},{type='number',label='Bedrag',required=true,min=1}})
                    if i then TriggerServerEvent('delfzijlrp_v3_controlcenter:server:money',p.id,i[1],i[2]) end
                end},
                {title='Item geven',onSelect=function()
                    local i=lib.inputDialog('Item geven',{{type='input',label='Item',required=true},{type='number',label='Aantal',required=true,min=1,default=1}})
                    if i then TriggerServerEvent('delfzijlrp_v3_controlcenter:server:item',p.id,i[1],i[2]) end
                end},
                {title='Voertuig geven',onSelect=function()
                    local i=lib.inputDialog('Voertuig geven',{{type='input',label='Model',required=true},{type='input',label='Label',required=false}})
                    if i then TriggerServerEvent('delfzijlrp_v3_controlcenter:server:vehicle',p.id,i[1],i[2]) end
                end},
                {title='Cadeaupakket geven',onSelect=function()
                    local presets=lib.callback.await('delfzijlrp_v3_controlcenter:server:getPresets',false) or {}
                    local po={}
                    for _,pr in ipairs(presets) do po[#po+1]={title=pr.label,description='Bank: €'..(pr.money or 0),onSelect=function() TriggerServerEvent('delfzijlrp_v3_controlcenter:server:preset',p.id,pr.id) end} end
                    lib.registerContext({id='drcc_presets',title='Pakket kiezen',menu='drcc_actions',options=po})
                    lib.showContext('drcc_presets')
                end}
            }})
            lib.showContext('drcc_actions')
        end}
    end
    if #opts==0 then opts[1]={title='Geen spelers online',readOnly=true} end
    lib.registerContext({id='drcc_players',title='Spelers',menu='drcc_main',options=opts})
    lib.showContext('drcc_players')
end

local function giveAllMenu()
    local presets=lib.callback.await('delfzijlrp_v3_controlcenter:server:getPresets',false) or {}
    local opts={}
    for _,pr in ipairs(presets) do
        opts[#opts+1]={title=pr.label,description='Aan iedereen online geven',onSelect=function()
            local c=lib.alertDialog({header='Bevestigen',content='Iedereen online dit pakket geven?',centered=true,cancel=true})
            if c=='confirm' then TriggerServerEvent('delfzijlrp_v3_controlcenter:server:presetAll',pr.id) end
        end}
    end
    lib.registerContext({id='drcc_all',title='Iedereen belonen',menu='drcc_main',options=opts})
    lib.showContext('drcc_all')
end

local function codeMenu()
    local presets=lib.callback.await('delfzijlrp_v3_controlcenter:server:getPresets',false) or {}
    local choices={}
    for _,pr in ipairs(presets) do choices[#choices+1]={value=pr.id,label=pr.label} end
    local i=lib.inputDialog('Claimcode maken',{{type='input',label='Code',required=true},{type='input',label='Label',required=true},{type='select',label='Pakket',required=true,options=choices},{type='number',label='Max claims',required=true,min=1,default=1}})
    if i then TriggerServerEvent('delfzijlrp_v3_controlcenter:server:createCode',i[1],i[2],i[3],i[4]) end
end

local function announce()
    local i=lib.inputDialog('Stadsbericht',{{type='textarea',label='Bericht',required=true,min=3,max=500}})
    if i then TriggerServerEvent('delfzijlrp_v3_controlcenter:server:announce',i[1]) end
end

local function main()
    local ok=lib.callback.await('delfzijlrp_v3_controlcenter:server:canOpen',false)
    if not ok then msg(Config.Text.noAccess,'error') return end
    lib.registerContext({id='drcc_main',title='Delfzijl RP Control Center',options={
        {title='Spelers beheren',description='Geld, items, auto en pakket',onSelect=playersMenu},
        {title='Iedereen online belonen',description='Cadeaupakket voor alle online spelers',onSelect=giveAllMenu},
        {title='Claimcode maken',description='Spelers gebruiken /claimcode CODE',onSelect=codeMenu},
        {title='Stadsbericht sturen',description='Melding naar iedereen',onSelect=announce},
        {title='Giveaways',description='Volgende build',readOnly=true}
    }})
    lib.showContext('drcc_main')
end

RegisterCommand(Config.Command,main,false)
