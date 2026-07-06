local function openProfile()
    local profile = lib.callback.await('delfzijlrp_v3_core:server:getProfile', false)
    if not profile then
        lib.notify({ title = 'DRP Core', description = Config.Text.noProfile, type = 'error' })
        return
    end
    lib.registerContext({
        id = 'drp_core_profile',
        title = 'Mijn Delfzijl profiel',
        options = {
            { title = 'Burgernummer', description = profile.citizen_id or 'onbekend', readOnly = true },
            { title = 'Reputatie', description = tostring(profile.reputation or 0), readOnly = true },
            { title = 'Vertrouwen', description = tostring(profile.trust_score or 50) .. '/100', readOnly = true },
            { title = 'Aangemaakt', description = tostring(profile.created_at or ''), readOnly = true }
        }
    })
    lib.showContext('drp_core_profile')
end

CreateThread(function()
    Wait(5000)
    TriggerServerEvent('delfzijlrp_v3_core:server:ensureProfile')
end)

RegisterCommand(Config.Command, openProfile, false)
