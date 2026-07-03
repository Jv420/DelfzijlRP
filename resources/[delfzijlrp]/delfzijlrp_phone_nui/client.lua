local phoneOpen = false

local function notify(message, type)
    lib.notify({ title = Config.Brand.name, description = message, type = type or 'inform' })
end

local function closePhone()
    phoneOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'setVisible', visible = false })
end

local function openPhone()
    local data = lib.callback.await('delfzijlrp_phone_nui:server:getData', false)
    if not data or not data.allowed then
        notify(data and data.reason or Config.Text.noPhone, 'error')
        return
    end

    phoneOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'setData', data = data })
    SendNUIMessage({ action = 'setVisible', visible = true })
end

RegisterCommand(Config.Command, openPhone, false)
RegisterCommand(Config.AltCommand, openPhone, false)
RegisterKeyMapping(Config.Command, 'Delfzijl RP NUI telefoon openen', 'keyboard', Config.OpenKey)

RegisterNUICallback('close', function(_, cb)
    closePhone()
    cb({ ok = true })
end)

RegisterNUICallback('runCommand', function(data, cb)
    closePhone()
    if data and data.command then
        ExecuteCommand(data.command)
    end
    cb({ ok = true })
end)

RegisterNUICallback('refresh', function(_, cb)
    local data = lib.callback.await('delfzijlrp_phone_nui:server:getData', false)
    cb(data or { allowed = false })
end)

RegisterNUICallback('saveSettings', function(data, cb)
    TriggerServerEvent('delfzijlrp_phone_nui:server:saveSettings', data or {})
    cb({ ok = true })
end)

CreateThread(function()
    while true do
        Wait(0)
        if phoneOpen and IsControlJustReleased(0, 177) then
            closePhone()
        end
    end
end)
